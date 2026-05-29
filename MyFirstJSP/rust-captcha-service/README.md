# SLF Rust CAPTCHA Service

Local CAPTCHA service for the Java JSP login flow.

## Run

```powershell
cd rust-captcha-service
cargo run
```

Default bind address:

```text
127.0.0.1:8787
```

Override it with:

```powershell
$env:CAPTCHA_BIND_ADDR="127.0.0.1:8787"
cargo run
```

The Java webapp calls this service through `CAPTCHA_SERVICE_URL`, defaulting to:

```text
http://127.0.0.1:8787
```
