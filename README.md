# 🔐 JWT Analyzer (Bash)

A lightweight, fast, and dependency-light JWT analyzer written in pure Bash. This script decodes, parses, and evaluates JSON Web Tokens (JWTs) to identify common security risks like missing claims, insecure algorithms, PII exposure, and bad cryptographic practices — right from your terminal.

---

## 🚀 Features

- 🔍 Decode and inspect JWT header & payload
- 🔐 Detect use of insecure algorithms like `none`
- 🕓 Analyze time-based claims (`exp`, `iat`, `nbf`)
- 🧠 Identify missing or weak claims (`iss`, `aud`, `jti`)
- 📛 Detect sensitive fields (e.g., passwords, API keys)
- 📧 Catch potential PII like email, SSN, credit cards
- ✅ Supports verbose output for raw token contents
- 💬 Best-practice security tips for storage and transport

---
