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
    
    // Encrypt
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
    
    let combined = STANDARD.decode(input_str).expect("Invalid base64 input");

    let (nonce_bytes, ciphertext) = combined.split_at(12);
    
    let key = Key::<Aes256Gcm>::from_slice(SECRET_KEY);
    let cipher = Aes256Gcm::new(key);
    let nonce = Nonce::from_slice(nonce_bytes);

    let decrypted_bytes = cipher.decrypt(nonce, ciphertext).expect("Decryption failed");
    let decrypted_str = String::from_utf8(decrypted_bytes).expect("Invalid UTF-8 sequence");
    
    env.new_string(decrypted_str).unwrap().into_raw()
}