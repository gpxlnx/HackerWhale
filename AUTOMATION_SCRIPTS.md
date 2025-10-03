# 🤖 Scripts de Automação - HackerWhale

Coleção de scripts prontos para automatizar workflows comuns de bug hunting.

## 📋 Índice

1. [Recon Completo](#1-recon-completo)
2. [Monitoramento Contínuo](#2-monitoramento-contínuo)
3. [Pipeline de Vulnerabilidades](#3-pipeline-de-vulnerabilidades)
4. [Mass Scanning](#4-mass-scanning)
5. [Notificações Automáticas](#5-notificações-automáticas)
6. [Backup e Relatórios](#6-backup-e-relatórios)

---

## 1. Recon Completo

### Script: `full-recon.sh`

```bash
#!/bin/bash
# Full reconnaissance automation
# Usage: ./full-recon.sh example.com

DOMAIN=$1
DATE=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="recon_${DOMAIN}_${DATE}"

if [ -z "$DOMAIN" ]; then
    echo "[!] Usage: $0 domain.com"
    exit 1
fi

# Setup
mkdir -p ${OUTPUT_DIR}/{subs,urls,ports,vulns,screenshots}
cd ${OUTPUT_DIR}

echo "[+] Starting reconnaissance for: $DOMAIN"

# Stage 1: Subdomain Enumeration
echo "[1/6] Subdomain enumeration..."
subfinder -d $DOMAIN -silent | anew subs/all.txt &
amass enum -passive -d $DOMAIN -silent | anew subs/all.txt &
assetfinder --subs-only $DOMAIN | anew subs/all.txt &
chaos -d $DOMAIN -silent | anew subs/all.txt &
wait

# Stage 2: DNS Resolution
echo "[2/6] DNS resolution..."
dnsx -l subs/all.txt -resp -silent | anew subs/resolved.txt

# Stage 3: HTTP Probing
echo "[3/6] HTTP probing..."
httpx -l subs/resolved.txt -status-code -tech-detect -title \
    -json -o subs/http.json -silent
cat subs/http.json | jq -r '.url' | anew subs/live.txt

# Stage 4: URL Discovery
echo "[4/6] URL discovery..."
cat subs/live.txt | waybackurls | anew urls/wayback.txt &
cat subs/live.txt | gau --threads 5 | anew urls/gau.txt &
katana -list subs/live.txt -silent -d 3 | anew urls/katana.txt &
wait

# Merge and clean URLs
cat urls/*.txt | uro | anew urls/all-clean.txt

# Stage 5: Port Scanning
echo "[5/6] Port scanning..."
naabu -list subs/resolved.txt -top-ports 1000 -silent -o ports/open.txt

# Stage 6: Vulnerability Scanning
echo "[6/6] Vulnerability scanning..."
nuclei -list subs/live.txt -severity critical,high,medium \
    -stats -silent -o vulns/nuclei.txt

# Stage 7: Screenshots (async)
echo "[7/7] Taking screenshots..."
gowitness file -f subs/live.txt -D screenshots/ &

# Summary
echo ""
echo "=========================================="
echo "           RECON SUMMARY"
echo "=========================================="
echo "Subdomains found:    $(wc -l < subs/all.txt)"
echo "Live hosts:          $(wc -l < subs/live.txt)"
echo "URLs discovered:     $(wc -l < urls/all-clean.txt)"
echo "Open ports:          $(wc -l < ports/open.txt)"
echo "Vulnerabilities:     $(wc -l < vulns/nuclei.txt)"
echo "=========================================="
echo "Results saved in: ${OUTPUT_DIR}"
```

---

## 2. Monitoramento Contínuo

### Script: `monitor-domain.sh`

```bash
#!/bin/bash
# Continuous monitoring for new assets
# Usage: ./monitor-domain.sh example.com

DOMAIN=$1
INTERVAL=${2:-3600}  # Default: 1 hora
MONITOR_DIR="monitor_${DOMAIN}"

mkdir -p ${MONITOR_DIR}/{subs,urls,vulns,alerts}
cd ${MONITOR_DIR}

# Initialize baseline if not exists
if [ ! -f "subs/baseline.txt" ]; then
    echo "[+] Creating baseline for $DOMAIN..."
    subfinder -d $DOMAIN -silent > subs/baseline.txt
    httpx -l subs/baseline.txt -silent > subs/baseline-live.txt
    echo "[✓] Baseline created"
fi

echo "[+] Starting continuous monitoring for: $DOMAIN"
echo "[+] Interval: ${INTERVAL}s ($(($INTERVAL/60)) minutes)"

while true; do
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    echo ""
    echo "[$(date)] Running scan..."
    
    # Check for new subdomains
    subfinder -d $DOMAIN -silent | anew subs/baseline.txt > subs/new_${TIMESTAMP}.txt
    
    if [ -s "subs/new_${TIMESTAMP}.txt" ]; then
        NEW_COUNT=$(wc -l < subs/new_${TIMESTAMP}.txt)
        echo "[!] Found $NEW_COUNT new subdomains!"
        
        # Probe new subdomains
        httpx -l subs/new_${TIMESTAMP}.txt -silent | \
            anew subs/baseline-live.txt > subs/new-live_${TIMESTAMP}.txt
        
        # Scan for vulns on new hosts
        if [ -s "subs/new-live_${TIMESTAMP}.txt" ]; then
            nuclei -list subs/new-live_${TIMESTAMP}.txt \
                -severity critical,high \
                -silent -o vulns/new_${TIMESTAMP}.txt
            
            # Send notification
            cat subs/new-live_${TIMESTAMP}.txt | \
                notify -silent -bulk \
                -data "New assets found for $DOMAIN"
        fi
    else
        echo "[✓] No new subdomains found"
    fi
    
    # Check for new URLs on existing hosts
    cat subs/baseline-live.txt | waybackurls | \
        anew urls/baseline.txt > urls/new_${TIMESTAMP}.txt
    
    if [ -s "urls/new_${TIMESTAMP}.txt" ]; then
        NEW_URLS=$(wc -l < urls/new_${TIMESTAMP}.txt)
        echo "[!] Found $NEW_URLS new URLs!"
    fi
    
    # Cleanup old scan results (keep last 7 days)
    find . -name "new_*" -mtime +7 -delete
    
    echo "[$(date)] Sleeping for ${INTERVAL}s..."
    sleep $INTERVAL
done
```

---

## 3. Pipeline de Vulnerabilidades

### Script: `vuln-pipeline.sh`

```bash
#!/bin/bash
# Comprehensive vulnerability scanning pipeline
# Usage: ./vuln-pipeline.sh targets.txt

TARGETS=$1
OUTPUT_DIR="vulns_$(date +%Y%m%d_%H%M%S)"

if [ ! -f "$TARGETS" ]; then
    echo "[!] Targets file not found: $TARGETS"
    exit 1
fi

mkdir -p ${OUTPUT_DIR}/{xss,sqli,ssrf,lfi,rce,misc}
cd ${OUTPUT_DIR}

echo "[+] Starting vulnerability pipeline..."
echo "[+] Targets: $(wc -l < ../$TARGETS)"

# XSS Detection
echo "[1/6] Testing for XSS..."
cat ../$TARGETS | gf xss | dalfox pipe -o xss/dalfox.txt &

# SQL Injection
echo "[2/6] Testing for SQLi..."
cat ../$TARGETS | gf sqli | tee sqli/candidates.txt | \
    parallel -j 5 "sqlmap -u {} --batch --random-agent --level 1 --risk 1" &

# SSRF Detection
echo "[3/6] Testing for SSRF..."
interactsh-client -json -o ssrf/interact.json &
INTERACT_PID=$!
sleep 5
INTERACT_URL=$(cat ssrf/interact.json | jq -r '.url' | tail -1)
cat ../$TARGETS | qsreplace "$INTERACT_URL" | httpx -silent > ssrf/requests.txt

# CRLF Injection
echo "[4/6] Testing for CRLF..."
crlfuzz -l ../$TARGETS -o crlf/results.txt &

# LFI Detection
echo "[5/6] Testing for LFI..."
cat ../$TARGETS | gf lfi | \
    parallel -j 10 "ffuf -u {} -w /opt/wordlists/SecLists/Fuzzing/LFI/LFI-Jhaddix.txt -mc 200 -fs 0" \
    | tee lfi/results.txt &

# Nuclei Comprehensive Scan
echo "[6/6] Running Nuclei..."
nuclei -list ../$TARGETS -severity critical,high,medium \
    -stats -markdown-export nuclei-report.md \
    -json -o misc/nuclei.json

# Wait for all background jobs
wait

# Generate Summary Report
cat > REPORT.md << EOF
# Vulnerability Scan Report
**Date**: $(date)
**Targets**: $(wc -l < ../$TARGETS)

## Summary

| Category | Findings |
|----------|----------|
| XSS | $(wc -l < xss/dalfox.txt 2>/dev/null || echo 0) |
| SQLi | $(wc -l < sqli/candidates.txt 2>/dev/null || echo 0) |
| SSRF | $(wc -l < ssrf/requests.txt 2>/dev/null || echo 0) |
| CRLF | $(grep -c "Vulnerable" crlf/results.txt 2>/dev/null || echo 0) |
| LFI | $(wc -l < lfi/results.txt 2>/dev/null || echo 0) |
| Nuclei | $(jq -s 'length' misc/nuclei.json 2>/dev/null || echo 0) |

## Details

$(cat nuclei-report.md 2>/dev/null || echo "No Nuclei results")

EOF

echo ""
echo "[✓] Pipeline complete!"
echo "[+] Report: ${OUTPUT_DIR}/REPORT.md"
```

---

## 4. Mass Scanning

### Script: `mass-scan.sh`

```bash
#!/bin/bash
# Mass scanning multiple targets in parallel
# Usage: ./mass-scan.sh domains.txt [threads]

DOMAINS_FILE=$1
THREADS=${2:-10}
OUTPUT_DIR="mass_scan_$(date +%Y%m%d_%H%M%S)"

if [ ! -f "$DOMAINS_FILE" ]; then
    echo "[!] Domains file not found"
    exit 1
fi

mkdir -p ${OUTPUT_DIR}
cd ${OUTPUT_DIR}

export -f scan_domain

scan_domain() {
    local domain=$1
    local output="${domain//[.]/_}"
    
    echo "[+] Scanning: $domain"
    
    # Quick recon
    subfinder -d $domain -silent | \
        httpx -silent | \
        nuclei -severity high,critical -silent \
        > ${output}.txt
    
    if [ -s "${output}.txt" ]; then
        echo "[!] Vulnerabilities found in $domain!" | \
            notify -silent -bulk
    fi
}

echo "[+] Mass scanning $(wc -l < ../$DOMAINS_FILE) domains"
echo "[+] Threads: $THREADS"

# Parallel execution
cat ../$DOMAINS_FILE | parallel -j $THREADS scan_domain {}

# Merge results
cat *.txt > all-results.txt 2>/dev/null
echo "[✓] Found $(wc -l < all-results.txt) total findings"
```

---

## 5. Notificações Automáticas

### Script: `notify-setup.sh`

```bash
#!/bin/bash
# Setup automated notifications
# Usage: ./notify-setup.sh

# Configure Telegram
setup_telegram() {
    read -p "Telegram Bot Token: " TOKEN
    read -p "Telegram Chat ID: " CHAT_ID
    
    mkdir -p ~/.config/notify
    cat > ~/.config/notify/provider-config.yaml << EOF
telegram:
  - id: "hackerwhale"
    telegram_apikey: "$TOKEN"
    telegram_chatid: "$CHAT_ID"
EOF
    
    echo "Test notification" | notify -silent -bulk
    echo "[✓] Telegram configured!"
}

# Configure Discord
setup_discord() {
    read -p "Discord Webhook URL: " WEBHOOK
    
    cat >> ~/.config/notify/provider-config.yaml << EOF
discord:
  - id: "hackerwhale"
    discord_webhook_url: "$WEBHOOK"
EOF
    
    echo "Test notification" | notify -provider discord
    echo "[✓] Discord configured!"
}

# Notification wrapper function
notify_finding() {
    local severity=$1
    local title=$2
    local message=$3
    
    case $severity in
        critical)
            EMOJI="🔴"
            ;;
        high)
            EMOJI="🟠"
            ;;
        medium)
            EMOJI="🟡"
            ;;
        *)
            EMOJI="🔵"
            ;;
    esac
    
    echo "$EMOJI **$title**
$message" | notify -silent -bulk
}

# Main menu
echo "Notification Setup"
echo "1. Telegram"
echo "2. Discord"
echo "3. Both"
read -p "Choose: " choice

case $choice in
    1) setup_telegram ;;
    2) setup_discord ;;
    3) setup_telegram && setup_discord ;;
    *) echo "Invalid choice" ;;
esac

# Export function for use in other scripts
echo 'export -f notify_finding' >> ~/.zshrc
```

---

## 6. Backup e Relatórios

### Script: `backup-results.sh`

```bash
#!/bin/bash
# Backup scan results and generate reports
# Usage: ./backup-results.sh [directory]

SOURCE_DIR=${1:-.}
BACKUP_DIR="backups"
DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE="scan-backup_${DATE}.tar.gz"

mkdir -p $BACKUP_DIR

echo "[+] Creating backup..."

# Create archive
tar -czf ${BACKUP_DIR}/${ARCHIVE} \
    --exclude='*.png' \
    --exclude='*.jpg' \
    --exclude='screenshots' \
    ${SOURCE_DIR}

echo "[✓] Backup created: ${BACKUP_DIR}/${ARCHIVE}"

# Generate markdown report
cat > ${BACKUP_DIR}/report_${DATE}.md << EOF
# Scan Report
**Date**: $(date)
**Archive**: ${ARCHIVE}

## Statistics

\`\`\`
$(du -sh ${SOURCE_DIR})
$(find ${SOURCE_DIR} -type f -name "*.txt" | wc -l) text files
$(find ${SOURCE_DIR} -type f -name "*.json" | wc -l) JSON files
\`\`\`

## Contents

\`\`\`
$(tree ${SOURCE_DIR} -L 2 2>/dev/null || ls -lR ${SOURCE_DIR})
\`\`\`

## Key Findings

### Subdomains
$(find ${SOURCE_DIR} -name "*subs*.txt" -exec wc -l {} + | tail -1)

### Live Hosts
$(find ${SOURCE_DIR} -name "*live*.txt" -exec wc -l {} + | tail -1)

### Vulnerabilities
$(find ${SOURCE_DIR} -name "*nuclei*.txt" -exec wc -l {} + | tail -1)

EOF

echo "[✓] Report created: ${BACKUP_DIR}/report_${DATE}.md"

# Upload to remote (optional)
if [ ! -z "$BACKUP_SERVER" ]; then
    echo "[+] Uploading to remote server..."
    scp ${BACKUP_DIR}/${ARCHIVE} $BACKUP_SERVER:~/backups/
    echo "[✓] Upload complete"
fi

# Cleanup old backups (keep last 30 days)
find ${BACKUP_DIR} -name "*.tar.gz" -mtime +30 -delete
echo "[✓] Cleanup complete"
```

---

## 🚀 Instalação Rápida

Salve todos os scripts em `/opt/scripts/` dentro do container:

```bash
# No container
mkdir -p /opt/scripts
cd /opt/scripts

# Baixe os scripts (assumindo que você os salvou em um gist/repo)
curl -O https://raw.githubusercontent.com/gpxlnx/HackerWhale/main/scripts/full-recon.sh
curl -O https://raw.githubusercontent.com/gpxlnx/HackerWhale/main/scripts/monitor-domain.sh
# ... outros scripts

# Tornar executáveis
chmod +x *.sh

# Adicionar ao PATH
echo 'export PATH=$PATH:/opt/scripts' >> ~/.zshrc
```

---

## 📝 Uso em Cron

Exemplo de crontab para monitoramento automático:

```bash
# Editar crontab
crontab -e

# Adicionar jobs
# Recon diário às 2AM
0 2 * * * /opt/scripts/full-recon.sh example.com

# Monitor a cada 6 horas
0 */6 * * * /opt/scripts/monitor-domain.sh example.com 21600

# Backup semanal (Domingo 3AM)
0 3 * * 0 /opt/scripts/backup-results.sh /workdir
```

---

## 🎯 Templates Prontos

### One-Liner para Recon Rápido

```bash
# Mega one-liner
echo "target.com" | subfinder -silent | httpx -silent | nuclei -severity critical,high -silent | notify
```

### Pipeline Completo em Uma Linha

```bash
# Full pipeline
subfinder -d target.com -silent | anew subs.txt | httpx -silent | anew live.txt | katana -silent | anew urls.txt | gf xss | dalfox pipe | notify
```

### Parallel Mass Recon

```bash
# 10 domínios em paralelo
cat domains.txt | parallel -j 10 "subfinder -d {} | httpx | nuclei > {}.txt"
```

---

## 📚 Recursos Adicionais

- Salve estes scripts em um repositório privado
- Use variáveis de ambiente para credenciais
- Implemente logging adequado
- Configure rate limiting apropriado
- Teste em ambientes controlados primeiro

**Happy Hunting! 🎯**

