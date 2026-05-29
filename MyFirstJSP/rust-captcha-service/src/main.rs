use std::collections::HashMap;
use std::env;
use std::hash::{Hash, Hasher};
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, SystemTime, UNIX_EPOCH};

const TTL: Duration = Duration::from_secs(5 * 60);
const MAX_ATTEMPTS: u8 = 3;
static COUNTER: AtomicU64 = AtomicU64::new(1);

type Store = Arc<Mutex<HashMap<String, Challenge>>>;

#[derive(Clone)]
struct Challenge {
    answer_hash: u64,
    expires_at: SystemTime,
    attempts: u8,
}

fn main() -> std::io::Result<()> {
    let bind_addr = env::var("CAPTCHA_BIND_ADDR").unwrap_or_else(|_| "127.0.0.1:8787".to_string());
    let listener = TcpListener::bind(&bind_addr)?;
    let store: Store = Arc::new(Mutex::new(HashMap::new()));
    println!("SLF CAPTCHA service listening on http://{}", bind_addr);
    std::io::stdout().flush()?;

    loop {
        let (stream, _) = match listener.accept() {
            Ok(connection) => connection,
            Err(error) => {
                eprintln!("connection failed: {}", error);
                continue;
            }
        };

        let store = Arc::clone(&store);
        std::thread::spawn(move || {
            if let Err(error) = handle_connection(stream, store) {
                eprintln!("request failed: {}", error);
            }
        });
    }
}

fn handle_connection(mut stream: TcpStream, store: Store) -> std::io::Result<()> {
    let mut buffer = [0; 8192];
    let size = stream.read(&mut buffer)?;
    let request = String::from_utf8_lossy(&buffer[..size]).to_string();

    if request.starts_with("POST /captcha/new ") {
        cleanup_expired(&store);
        let (token, answer) = new_challenge_values();
        let image_data_url = captcha_svg_data_url(&answer);
        let challenge = Challenge {
            answer_hash: hash_answer(&answer),
            expires_at: SystemTime::now() + TTL,
            attempts: 0,
        };
        store.lock().unwrap().insert(token.clone(), challenge);
        let body = format!(
            "{{\"ok\":true,\"token\":\"{}\",\"imageDataUrl\":\"{}\",\"expiresInSeconds\":{}}}",
            json_escape(&token),
            json_escape(&image_data_url),
            TTL.as_secs()
        );
        return write_json(&mut stream, 200, &body);
    }

    if request.starts_with("POST /captcha/verify ") {
        cleanup_expired(&store);
        let body = request.split("\r\n\r\n").nth(1).unwrap_or("");
        let params = parse_form(body);
        let token = params.get("token").cloned().unwrap_or_default();
        let answer = params.get("answer").cloned().unwrap_or_default();
        let ok = verify_answer(&store, &token, &answer);
        let response = if ok { "{\"ok\":true}" } else { "{\"ok\":false}" };
        return write_json(&mut stream, 200, response);
    }

    write_json(&mut stream, 404, "{\"ok\":false,\"error\":\"not_found\"}")
}

fn new_challenge_values() -> (String, String) {
    let id = COUNTER.fetch_add(1, Ordering::SeqCst);
    let now = now_nanos();
    let seed = now ^ id.rotate_left(17);
    let alphabet = b"ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    let mut answer = String::new();
    for index in 0..5 {
        let mixed = seed.rotate_left((index * 11) as u32)
            ^ (index as u64 + 13).wrapping_mul(0x9e3779b97f4a7c15);
        answer.push(alphabet[(mixed as usize) % alphabet.len()] as char);
    }
    let token = format!("{:016x}{:016x}", now, hash_token(seed, id));
    (token, answer)
}

fn verify_answer(store: &Store, token: &str, answer: &str) -> bool {
    if token.trim().is_empty() || answer.trim().is_empty() {
        return false;
    }

    let mut guard = store.lock().unwrap();
    let mut remove = false;
    let ok = if let Some(challenge) = guard.get_mut(token) {
        if SystemTime::now() > challenge.expires_at || challenge.attempts >= MAX_ATTEMPTS {
            remove = true;
            false
        } else {
            challenge.attempts += 1;
            let matched = challenge.answer_hash == hash_answer(answer);
            if matched || challenge.attempts >= MAX_ATTEMPTS {
                remove = true;
            }
            matched
        }
    } else {
        false
    };

    if remove {
        guard.remove(token);
    }
    ok
}

fn cleanup_expired(store: &Store) {
    let now = SystemTime::now();
    store.lock().unwrap().retain(|_, challenge| challenge.expires_at > now);
}

fn captcha_svg_data_url(answer: &str) -> String {
    let mut letters = String::new();
    for (index, ch) in answer.chars().enumerate() {
        let x = 22 + index * 30;
        let y = 45 + ((index as i32 % 2) * 7);
        let rotate = if index % 2 == 0 { -8 } else { 7 };
        letters.push_str(&format!(
            "<text x=\"{}\" y=\"{}\" transform=\"rotate({} {} {})\">{}</text>",
            x, y, rotate, x, y, ch
        ));
    }

    let svg = format!(
        "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"190\" height=\"72\" viewBox=\"0 0 190 72\">\
<rect width=\"190\" height=\"72\" rx=\"8\" fill=\"#f6f9fc\"/>\
<path d=\"M8 18 C40 38,70 2,108 24 S160 42,182 20\" fill=\"none\" stroke=\"#8fbce8\" stroke-width=\"3\"/>\
<path d=\"M9 55 C42 30,82 68,124 43 S162 31,184 49\" fill=\"none\" stroke=\"#d8a63a\" stroke-width=\"2\"/>\
<g font-family=\"Consolas,monospace\" font-size=\"32\" font-weight=\"700\" fill=\"#063d73\">{}</g>\
<g stroke=\"#94a3b8\" stroke-width=\"1\">\
<line x1=\"16\" y1=\"12\" x2=\"174\" y2=\"59\"/>\
<line x1=\"10\" y1=\"61\" x2=\"180\" y2=\"10\"/>\
</g>\
</svg>",
        letters
    );
    format!("data:image/svg+xml;base64,{}", base64_encode(svg.as_bytes()))
}

fn parse_form(body: &str) -> HashMap<String, String> {
    let mut params = HashMap::new();
    for pair in body.split('&') {
        let mut parts = pair.splitn(2, '=');
        let key = url_decode(parts.next().unwrap_or(""));
        let value = url_decode(parts.next().unwrap_or(""));
        params.insert(key, value);
    }
    params
}

fn url_decode(value: &str) -> String {
    let mut output = Vec::new();
    let bytes = value.as_bytes();
    let mut index = 0;
    while index < bytes.len() {
        match bytes[index] {
            b'+' => {
                output.push(b' ');
                index += 1;
            }
            b'%' if index + 2 < bytes.len() => {
                if let Ok(hex) = u8::from_str_radix(&value[index + 1..index + 3], 16) {
                    output.push(hex);
                    index += 3;
                } else {
                    output.push(bytes[index]);
                    index += 1;
                }
            }
            byte => {
                output.push(byte);
                index += 1;
            }
        }
    }
    String::from_utf8_lossy(&output).trim().to_string()
}

fn write_json(stream: &mut TcpStream, status: u16, body: &str) -> std::io::Result<()> {
    let status_text = if status == 200 { "OK" } else { "Not Found" };
    let response = format!(
        "HTTP/1.1 {} {}\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: {}\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n{}",
        status,
        status_text,
        body.as_bytes().len(),
        body
    );
    stream.write_all(response.as_bytes())
}

fn hash_answer(answer: &str) -> u64 {
    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    "slf-captcha-answer-v1".hash(&mut hasher);
    answer.trim().to_uppercase().hash(&mut hasher);
    hasher.finish()
}

fn hash_token(seed: u64, id: u64) -> u64 {
    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    seed.hash(&mut hasher);
    id.hash(&mut hasher);
    now_nanos().hash(&mut hasher);
    hasher.finish()
}

fn now_nanos() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos() as u64
}

fn json_escape(value: &str) -> String {
    value.replace('\\', "\\\\").replace('"', "\\\"")
}

fn base64_encode(bytes: &[u8]) -> String {
    const TABLE: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut output = String::new();
    let mut index = 0;
    while index < bytes.len() {
        let b0 = bytes[index];
        let b1 = if index + 1 < bytes.len() { bytes[index + 1] } else { 0 };
        let b2 = if index + 2 < bytes.len() { bytes[index + 2] } else { 0 };
        output.push(TABLE[(b0 >> 2) as usize] as char);
        output.push(TABLE[(((b0 & 0b0000_0011) << 4) | (b1 >> 4)) as usize] as char);
        if index + 1 < bytes.len() {
            output.push(TABLE[(((b1 & 0b0000_1111) << 2) | (b2 >> 6)) as usize] as char);
        } else {
            output.push('=');
        }
        if index + 2 < bytes.len() {
            output.push(TABLE[(b2 & 0b0011_1111) as usize] as char);
        } else {
            output.push('=');
        }
        index += 3;
    }
    output
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_form_decodes_values() {
        let params = parse_form("token=abc%20123&answer=a%2Bb+c");
        assert_eq!(params.get("token").unwrap(), "abc 123");
        assert_eq!(params.get("answer").unwrap(), "a+b c");
    }

    #[test]
    fn verify_answer_accepts_once_only() {
        let store: Store = Arc::new(Mutex::new(HashMap::new()));
        store.lock().unwrap().insert(
            "token-1".to_string(),
            Challenge {
                answer_hash: hash_answer("ABCD1"),
                expires_at: SystemTime::now() + TTL,
                attempts: 0,
            },
        );

        assert!(verify_answer(&store, "token-1", "abcd1"));
        assert!(!verify_answer(&store, "token-1", "abcd1"));
    }

    #[test]
    fn verify_answer_rejects_expired_token() {
        let store: Store = Arc::new(Mutex::new(HashMap::new()));
        store.lock().unwrap().insert(
            "token-2".to_string(),
            Challenge {
                answer_hash: hash_answer("ABCD1"),
                expires_at: SystemTime::now() - Duration::from_secs(1),
                attempts: 0,
            },
        );

        assert!(!verify_answer(&store, "token-2", "ABCD1"));
    }

    #[test]
    fn captcha_image_is_svg_data_url() {
        let image = captcha_svg_data_url("ABCD1");
        assert!(image.starts_with("data:image/svg+xml;base64,"));
        assert!(image.len() > 100);
    }
}
