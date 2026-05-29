package com.example.captcha;

public class CaptchaBridge {

    static {
        // โหลดไฟล์ดึงพลังจาก Rust (ใส่แค่ชื่อระบบจะไปควานหาไฟล์ .dll ที่อยู่ตรง pom.xml เองอัตโนมัติ)
        System.loadLibrary("rust_captcha"); 
    }

    // ประกาศฟังก์ชันให้ตรงกับที่ฝั่ง Rust ตั้งชื่อโครงสร้างไว้
    public static native String generateCaptcha();
}