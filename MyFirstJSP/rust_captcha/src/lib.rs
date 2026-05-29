use jni::JNIEnv;
use jni::objects::{JClass, JString};
use jni::sys::jstring;
use captcha::Captcha;
use captcha::filters::{Noise, Wave};

//ทำเป็นตัวอักษรโดยการใช้ AES เข้าKey
#[unsafe(no_mangle)]
pub extern "system" fn Java_com_example_captcha_CaptchaBridge_generateCaptcha(
    mut env: JNIEnv,
    _class: JClass,
) -> jstring {
    // Bua Random
    let mut captcha = Captcha::new();
    captcha
        .add_chars(5)
        .apply_filter(Noise::new(0.2)) 
        .apply_filter(Wave::new(2.0, 10.0)); 

    let text_answer = captcha.chars_as_string().to_lowercase(); 
    let image_base64 = captcha.as_base64().unwrap(); 

    let result = format!("{}|{}", text_answer, image_base64);

    
    let output = env.new_string(result).expect("Failed to create Java string");
    output.into_raw()
}