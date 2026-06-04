package com.example.crypto;

public class CryptoBridge {
    static {
        try {
            //โหลดไฟล์ Rust DLL
           System.load("C:/Users/buako/OneDrive/เอกสาร/GitHub/SLF_Requisition_Form/MyFirstJSP/rust_captcha/target/release/rust_captcha.dll");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Download file error");
            e.printStackTrace();
        }
    }

    public static native String encrypt(String plainText);
    public static native String decrypt(String cipherText);

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
