package com.example.crypto;

public class CryptoBridge {
    static {
        try {
            // 🔒 โหลดไฟล์ Rust DLL
            System.loadLibrary("rust_captcha"); 
        } catch (UnsatisfiedLinkError e) {
            System.err.println("❌ โหลดไฟล์ Rust DLL ไม่สำเร็จ! ตรวจสอบว่าเอาไฟล์ .dll ไปวางไว้ที่โฟลเดอร์หลักของโปรเจกต์แล้วหรือยัง");
            e.printStackTrace();
        }
    }

    public static native String encrypt(String plainText);
    public static native String decrypt(String cipherText);

    // 🌟 ท่อนนี้เอาไว้สำหรับกดกดเทสวิ่งตรงหา Rust จ้า 🌟
    public static void main(String[] args) {
        try {
            System.out.println("Start AES-256-GCM");
            
            String originalText = "Test Begin";
            System.out.println("OriginalText : " + originalText);
            System.out.println("--------------------------------------------------");

            String cipherText1 = CryptoBridge.encrypt(originalText);
            System.out.println("Base64 (2) : " + cipherText1);

            String cipherText2 = CryptoBridge.encrypt(originalText);
            System.out.println("Base64 (3): " + cipherText2);
            System.out.println("--------------------------------------------------");

            String decryptedText = CryptoBridge.decrypt(cipherText1);
            System.out.println("DecryptedText: " + decryptedText);
            
            System.out.println("Summary");
            if (originalText.equals(decryptedText)) {
                System.out.println("Correct");
            } else {
                System.out.println("Error");
            }

        } catch (Exception e) {
            System.err.println("Problem ");
            e.printStackTrace();
        }
    }
}