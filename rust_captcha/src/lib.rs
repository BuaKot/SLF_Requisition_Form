use jni::objects::JClass;
use jni::sys::jstring; 
use jni::JNIEnv;

#[no_mangle]
pub extern "system" fn Java_com_example_captcha_CaptchaBridge_generateCaptcha(
    mut env: JNIEnv,
    _class: JClass,
) -> jstring {
    
    
    let output = "ax39b|data:image/png;base64,iVBORw0KGgoAAA..."; 
    
    env.new_string(output).unwrap().into_raw()
}