# 🕵️ Web Recon & Exploitation Methodology (CTF / Pentest)

This guide is a procedural checklist to help you quickly set up, investigate and attack web services during a CTF or pentest.

---

## 🧱 Variables to define

At the beginning of your engagement or CTF challenge, define the following:

```bash
export TARGET_IP="10.10.11.XXX"
export TARGET_PORT="80"
export TARGET_URL="http://${TARGET_IP}:${TARGET_PORT}"
```

---

## 🚀 Step-by-step Methodology

### 🔍 1. Basic Recon

```bash
curl -I "$TARGET_URL"
```

- Get HTTP headers (check for tech info, cookies, server, redirection)
- Look for `X-Powered-By`, `Server`, etc.

```bash
wafw00f "$TARGET_URL" # Detect if there is a WAF and which one
```

---

### 🧱 2. Directory & File Discovery

```bash
ffuf -u "$TARGET_URL/FUZZ" -w /snap/seclists/current/Discovery/Web-Content/common.txt:FUZZ -t 50
```

Or with `gobuster`:

```bash
gobuster dir -u "$TARGET_URL" -w /snap/seclists/current/Discovery/Web-Content/common.txt -t 30
```

---

### 🧑‍💻 3. Analyze Response / Behavior

- Look at content returned: forms, error messages, JS files
- Look for `robots.txt`, `.git`, `.env`, etc.
- Search source code

---

### 📦 4. Check for Vulnerabilities

#### 📌 SQLi

If URL params, forms or cookies look injectable:

```bash
sqlmap -u "$TARGET_URL/page.php?id=1" --batch --dbs
```

Or extract the requests (ZAP, Burp or Network tab):

```bash
sqlmap -r request.raw --batch --dbs
```

#### 📌 LFI

If you find a parameter like `?file=` or suspect LFI:

```bash
ffuf -u "$TARGET_URL/index.php?page=FUZZ.php" -w /snap/seclists/current/Discovery/Web-Content/common.txt:FUZZ
```

Or use **Burp/ZAP** with repeater to test `../../../../etc/passwd`

---

### 🌐 5. Subdomain / vHost Discovery

```bash
gobuster vhost -u "$TARGET_URL" -w /snap/seclists/current/Discovery/DNS/subdomains-top1million-110000.txt --append-domain
```

Or use `crt.sh`:

```bash
curl -s "https://crt.sh/?q=target.com&output=json" | jq -r '.[].name_value' | sort -u
```

---

### 🌍 6. DNS Enumeration (if domain known)

```bash
dig target.com ANY
dig +trace target.com
dnsenum --enum target.com -f /snap/seclists/current/Discovery/DNS/subdomains-top1million-110000.txt -r
```

---

### 🕸 7. Crawling and Tech Fingerprinting

```bash
nikto -h "$TARGET_URL"
finalrecon.py --headers --sslinfo --url "$TARGET_URL"
```

Check:

- JavaScript files
- `/robots.txt`
- `.well-known/`
- CMS detection

---

## 🧠 Common logic / decisions

| If you find... | Do this... |
|----------------|------------|
| SQL Injection  | Run `sqlmap`, dump DB |
| LFI            | Fuzz with `ffuf`, ZAP, test `/etc/passwd` |
| Upload page    | Try to upload PHP webshell, double extensions |
| Forms / Input  | XSS, SQLi, command injection |
| Debug info     | Look for stack traces, tech names |
| Virtual host   | Try hostname fuzzing, `vhosts` with ffuf |
| Hidden content | Archive.org, `/dev`, `/tmp`, `.git/` |

---

## 📘 Useful Tool Commands & Flags

### 🛠 SQLMap

```bash
sqlmap -u "http://host/page.php?id=1" --batch
-D <database> -T <table> --dump
--cookie="PHPSESSID=..."
```

### 🛠 FFUF

```bash
ffuf -u "$TARGET_URL/FUZZ" -w wordlist.txt -fc 404
ffuf -w vhosts.txt -H "Host: FUZZ.target.com" -u "$TARGET_URL" -fs 1234
```

### 🛠 Nikto

```bash
nikto -h "$TARGET_URL" -Tuning x
```

### 🛠 wafw00f

```bash
wafw00f "$TARGET_URL"
```

---

## 🛡 Bonus: Proxy Setup with Burp / ZAP

To intercept HTTPS with Burp/ZAP, install the **Burp CA Certificate** in your browser.

To proxy CLI tools via Burp:

```bash
sudo apt install proxychains
# In /etc/proxychains.conf
# Add at bottom: http 127.0.0.1 8080

proxychains curl http://example.com
```

---

## ⚙️ Recon Automation Tools

- [`FinalRecon`](https://github.com/thewhiteh4t/FinalRecon)
- [`recon-ng`](https://github.com/lanmaster53/recon-ng)
- [`theHarvester`](https://github.com/laramies/theHarvester)
- [`Spiderfoot`](https://github.com/smicallef/spiderfoot)
- [`ReconSpider`](https://github.com/bhavsec/reconspider)

---

## 🧼 Cleanup & Notes

- Use `Burp match & replace` to change headers dynamically
- Always check for SSL/TLS warnings / cert issues
