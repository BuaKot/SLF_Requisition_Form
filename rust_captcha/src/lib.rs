use jni::JNIEnv;
use jni::objects::{JClass, JString};
use jni::sys::jstring;
use aes_gcm::{Aes256Gcm, Key, Nonce};
use aes_gcm::aead::{Aead, KeyInit};
use rand::RngCore;
use base64::{Engine as _, engine::general_purpose::STANDARD};

const SECRET_KEY: &[u8; 32] = b"thisis32byteslongsecretkeyforaes";

#[no_mangle]
pub extern "system" fn Java_com_example_crypto_CryptoBridge_encrypt(
    mut env: JNIEnv,
    _class: JClass,
    input: JString,
) -> jstring {
    let input_str: String = env.get_string(&input).unwrap().into();

    let mut nonce_bytes = [0u8; 12];
    rand::thread_rng().fill_bytes(&mut nonce_bytes);

    let key = Key::<Aes256Gcm>::from_slice(SECRET_KEY);
    let cipher = Aes256Gcm::new(key);
    let nonce = Nonce::from_slice(&nonce_bytes);

    let ciphertext = cipher.encrypt(nonce, input_str.as_bytes()).expect("Encryption failed");

    let mut combined = nonce_bytes.to_vec();
    combined.extend(ciphertext);

    let base64_output = STANDARD.encode(combined);

    env.new_string(base64_output).unwrap().into_raw()
}

#[no_mangle]
pub extern "system" fn Java_com_example_crypto_CryptoBridge_decrypt(
    mut env: JNIEnv,
    _class: JClass,
    input: JString,
) -> jstring {
    let input_str: String = env.get_string(&input).unwrap().into();

    // Handle Base64 decoding safely without crashing (Replaced .expect)
    let combined = match STANDARD.decode(input_str) {
        Ok(bytes) => bytes,
        Err(_) => {
            let exception_class = env.find_class("java/lang/IllegalArgumentException").unwrap();
            env.throw_new(exception_class, "Invalid base64 input sequence!").unwrap();
            return std::ptr::null_mut();
        }
    };

    // Verify minimum data length (Must include at least 12 bytes of Nonce)
    if combined.len() < 12 {
        let exception_class = env.find_class("java/lang/IllegalArgumentException").unwrap();
        env.throw_new(exception_class, "Ciphertext data is too short!").unwrap();
        return std::ptr::null_mut();
    }

    let (nonce_bytes, ciphertext) = combined.split_at(12);

    let key = Key::<Aes256Gcm>::from_slice(SECRET_KEY);
    let cipher = Aes256Gcm::new(key);
    let nonce = Nonce::from_slice(nonce_bytes);

    // Handle AES-GCM decryption safely without crashing
    let decrypted_bytes = match cipher.decrypt(&nonce, ciphertext.as_ref()) {
        Ok(bytes) => bytes,
        Err(_) => {
            let exception_class = env.find_class("java/lang/IllegalArgumentException").unwrap();
            env.throw_new(exception_class, "Data has been tampered or decryption failed!").unwrap();
            return std::ptr::null_mut();
        }
    };

    // Handle UTF-8 conversion safely without crashing (Replaced .expect)
    let decrypted_str = match String::from_utf8(decrypted_bytes) {
        Ok(s) => s,
        Err(_) => {
            let exception_class = env.find_class("java/lang/IllegalArgumentException").unwrap();
            env.throw_new(exception_class, "Decrypted data is not a valid UTF-8 string!").unwrap();
            return std::ptr::null_mut();
        }
    };

    env.new_string(decrypted_str).unwrap().into_raw()
}