# certview

An [Oh My Zsh](https://ohmyz.sh/) plugin for fast inspection and verification of X.509 certificates, CSRs, and cryptographic keys (RSA, ECC, Ed25519) in both **PEM** and **DER** formats.

## Features

- **Automatic Format Detection**: Handles ASCII PEM and binary DER files automatically.
- **Three Dedicated Tools**:
  - `certview`: Inspect X.509 certificates, check expiry, view SANs, serial numbers, fingerprints, and subjects.
  - `csrview`: Inspect Certificate Signing Requests and verify CSR cryptographic signatures.
  - `keyview`: Inspect RSA, ECDSA (ECC curves), and Ed25519 private/public keys, test integrity, or export public keys.
- **Zsh Tab-Completion**: Built-in completions for flags and certificate/key file extensions (`.pem`, `.der`, `.crt`, `.key`, `.csr`, etc.).

---

## Installation

### Oh My Zsh

Clone the repository into your custom plugins directory:

```zsh
git clone https://github.com/jnnrgd/certview.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/certview
```

Add `certview` to your `plugins` list in `~/.zshrc`:

```zsh
plugins=(
  git
  certview
)
```

Reload your environment:

```zsh
source ~/.zshrc
```

---

## Usage

### 1. `certview` (X.509 Certificates)

```zsh
# View full certificate details
certview cert.pem

# Extract specific fields
certview -s cert.crt              # Subject DN
certview -i cert.crt              # Issuer DN
certview -d cert.der              # NotBefore & NotAfter validity dates
certview -f cert.pem              # SHA-256 fingerprint
certview -n cert.crt              # Subject Alternative Names (SANs)
certview --serial cert.crt        # Serial number
certview -m cert.crt              # Key modulus

# Combine multiple flags
certview -s -i -d cert.pem

# Quick validity / expiration check (pass/fail)
certview -c cert.crt
```

### 2. `csrview` (Certificate Signing Requests)

```zsh
# View full decoded CSR
csrview request.csr

# Extract specific fields
csrview -s request.csr            # Subject DN
csrview -n request.csr            # Requested Subject Alternative Names (SANs)
csrview -p request.csr            # Public key
csrview -m request.csr            # Key modulus (RSA)

# Cryptographically verify self-signature on CSR
csrview -v request.csr
```

### 3. `keyview` (Keys: RSA, ECC, Ed25519)

```zsh
# View key parameters & curves (prime256v1, secp384r1, RSA bit length)
keyview private.key
keyview ec.der

# Verify key integrity
keyview -c id_rsa

# Extract and output public key in PEM format
keyview -p private.key > public.pub
```

---

## License

This project is dedicated to the public domain under the [Creative Commons Zero v1.0 Universal](LICENSE) (CC0 1.0). You can copy, modify, distribute, and perform the work, even for commercial purposes, all without asking permission.

