# CryptoBridge & Rust Captcha Web Security System

> **A high-performance, polyglot web security framework** bridging Java (JSP/Maven) with Rust (FFI Dynamic Link Library) to deliver secure password hashing, cryptographic operations, and automated CAPTCHA verification.

---

## Executive Summary

This project integrates low-level Rust systems programming into a enterprise-grade Java web application environment. By compiling custom Rust modules into dynamic link libraries (`rust_captcha.dll`) and linking them via Java FFI / Crypto Bridge interfaces, the system delivers memory-safe, ultra-fast CAPTCHA generation and hardened cryptographic mechanisms (such as secure password hashing over plaintext storage) for modern web applications.

---

## System Architecture & Workflow
┌────────────────────────┐      ┌─────────────────────────┐      ┌─────────────────────────┐
│   Web Frontend / JSP   │ ───► │  Java Web Application   │ ───► │   CryptoBridge / JNI    │
│  (MyFirstJSP / webapp) │      │  (src / Maven pom.xml)  │      │   (Java-to-Rust Bridge) │
└────────────────────────┘      └─────────────────────────┘      └─────────────────────────┘
│
▼
┌────────────────────────┐      ┌─────────────────────────┐      ┌─────────────────────────┐
│ Database Storage Layer │ ◄─── │ Secure Hashing & Verification│ ◄─ │ Rust CAPTCHA DLL Core   │
│ (database/)            │      │ (Password Hashing / Logs)│      │ (rust_captcha / .dll)   │
└────────────────────────┘      └─────────────────────────┘      └─────────────────────────┘


1. **Web Interface Layer**: Users interact with the web interface (`MyFirstJSP`, `danger/webapp`) for authentication and verification challenges.
2. **CryptoBridge Interop Layer**: Java application services (`src`) delegate intensive cryptographic and security tasks to compiled Rust extensions via Foreign Function Interfaces (FFI).
3. **Rust Core Performance Layer**: Custom Rust logic (`rust_captcha/`, compiled to `rust_captcha.dll`) handles dynamic CAPTCHA image generation and secure hashing routines with low memory overhead.
4. **Data Persistence**: Authenticated, hashed credentials and verification records are stored securely within the database abstraction layer (`database/`).

---

## Repository Structure

```text
├── 📁 .github/java-upgrade/   # CI/CD workflows and Java runtime upgrade configurations
├── 📁 .vscode/                 # Editor workspaces and launch settings
├── 📁 MyFirstJSP/              # Web frontend templates and JSP application views
├── 📁 danger/webapp/          # Core web application components and endpoint security
├── 📁 database/                # Database migration scripts and persistent schema definitions
├── 📁 rust_captcha/            # Rust crate source code (lib.rs) for CAPTCHA logic
├── 📁 src/                     # Java source code containing CryptoBridge bindings
├── 📜 .gitignore               # Excludes build artifacts (e.g., target/ folder)
├── 📜 pom.xml                  # Maven build configuration file
├── 📜 rust_captcha.dll         # Compiled Rust dynamic library binary
└── 📜 README.md                # Project documentation
🚀 Quick Start Guide
1. Prerequisites
Ensure you have the following installed on your host system:

JDK 11+

Apache Maven

Rust Toolchain (cargo / rustc)

2. Build the Rust Library (rust_captcha)
Compile the Rust module into a dynamic link library (.dll / .so):

Bash
cd rust_captcha
cargo build --release
# Copy the compiled DLL to the project root if necessary
cp target/release/rust_captcha.dll ../rust_captcha.dll
3. Build & Package the Java Application
Run Maven to compile the Java project and resolve pom.xml dependencies:

Bash
# Clean and package the Maven web project
mvn clean package
4. Run the Web Server
Deploy the packaged WAR artifact or launch via an embedded web server:

Bash
mvn tomcat7:run
# or run executable JAR/WAR
java -jar target/app.war
