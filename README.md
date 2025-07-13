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
- 🧪 Optional signature verification with `--verify <secret>`

---

## ⚙️ Installation

### 1. Clone this repository

```bash
git clone https://github.com/yourusername/jwt-analyzer.git
cd jwt-analyzer

### 2. Make the script executable

```bash
chmod +x jwt-analyzer.sh

### 3. Install required tools (if not already installed)

# For Debian/Ubuntu
sudo apt install jq openssl coreutils

# For macOS
brew install jq

📦 Usage
Basic Analysis

```bash
./jwt-analyzer.sh --token <your.jwt.token>

