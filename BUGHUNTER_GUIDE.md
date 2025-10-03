# 🐋 HackerWhale - Guia do Bug Hunter

## 🎯 Uso Rápido

### Build e Execução

```bash
# Build com script local
docker build --build-arg EXPANSION_SCRIPT_LOCAL=scripts/expansion_script.sh -t hackerwhale:latest .

# Executar com volume persistente
docker run -it --rm \
  --name hackerwhale \
  -v $(pwd)/data:/workdir \
  --cap-add=NET_ADMIN \
  --net=host \
  hackerwhale:latest zsh

# Executar em background (daemon)
docker run -d \
  --name hackerwhale \
  -v $(pwd)/data:/workdir \
  --cap-add=NET_ADMIN \
  --net=host \
  hackerwhale:latest

# Attach no container
docker exec -it hackerwhale zsh
```

## 🔥 Workflows Essenciais

### 1. Reconhecimento de Subdomínios

```bash
# Passive recon com múltiplas fontes
subfinder -d target.com | anew subs.txt
amass enum -passive -d target.com | anew subs.txt
assetfinder --subs-only target.com | anew subs.txt

# Active recon
alterx -list subs.txt -enrich | anew subs-permutations.txt
shuffledns -d target.com -w /opt/wordlists/assetnote/best-dns-wordlist.txt -r /opt/wordlists/resolvers.txt | anew subs.txt

# Validar subdomínios ativos
dnsx -l subs.txt -resp -silent | anew live-subs.txt

# HTTP probing
httpx -l live-subs.txt -status-code -tech-detect -title -o http-results.txt
```

### 2. Descoberta de URLs e Endpoints

```bash
# Wayback Machine
waybackurls target.com | anew urls.txt
gau target.com | anew urls.txt
gauplus -t 10 -subs target.com | anew urls.txt

# Crawling ativo
katana -u https://target.com -d 5 -jc -kf all -o katana-results.txt
gospider -s https://target.com -d 5 -c 10 -t 20 | anew urls.txt
hakrawler -url https://target.com -depth 3 | anew urls.txt

# JS analysis
subjs -i live-subs.txt | anew js-files.txt
cat js-files.txt | while read url; do linkfinder -i "$url" -o cli; done | anew endpoints.txt

# Limpar URLs duplicadas
cat urls.txt | uro | anew clean-urls.txt
```

### 3. Fuzzing de Diretórios e Parâmetros

```bash
# Directory fuzzing
ffuf -w /opt/wordlists/SecLists/Discovery/Web-Content/raft-large-directories.txt \
  -u https://target.com/FUZZ \
  -mc 200,204,301,302,307,401,403 \
  -o ffuf-dirs.json

# API fuzzing com Kiterunner
kr scan https://target.com -w /opt/tools/kr/routes-large.kite -o kr-results.txt

# Parameter discovery
paramspider -d target.com
arjun -u https://target.com/page -oT arjun-params.txt

# Hidden parameter discovery
x8 -u "https://target.com/api?test=1" -w /opt/wordlists/SecLists/Discovery/Web-Content/burp-parameter-names.txt
```

### 4. Scanning de Vulnerabilidades

```bash
# Port scanning
naabu -l live-subs.txt -top-ports 1000 -o ports.txt
nmap -iL live-subs.txt -sV -sC -oA nmap-results

# Nuclei templates
nuclei -l http-results.txt -t /root/nuclei-templates -severity critical,high,medium -o nuclei-results.txt

# XSS scanning
dalfox file urls.txt -o dalfox-xss.txt
cat urls.txt | gf xss | dalfox stdin

# SQL injection
sqlmap -m urls.txt --batch --random-agent --level 1 --risk 1

# CRLF injection
crlfuzz -l urls.txt -o crlfuzz-results.txt

# WAF detection
wafw00f -i live-subs.txt -o wafw00f-results.txt
```

### 5. Monitoramento Contínuo

```bash
# Setup notify para alertas
notify -provider telegram -config ~/.config/notify/provider-config.yaml

# Monitoramento de novos subdomínios
while true; do
  subfinder -d target.com -silent | anew monitor-subs.txt | notify
  sleep 3600
done &

# Monitoramento com Interactsh
interactsh-client -v

# Alertas de mudanças em JS
cat js-files.txt | while read url; do
  curl -s "$url" | sha256sum
done > js-hashes.txt
```

## 🛠️ Ferramentas por Categoria

### Reconnaissance
- **Passivo**: subfinder, amass, assetfinder, chaos-client, github-subdomains
- **Ativo**: alterx, shuffledns, massdns, puredns, dnsx
- **DNS**: hakrevdns, dnsgen, dnsvalidator

### Discovery
- **URLs**: waybackurls, gau, gauplus, haktrails
- **Crawling**: katana, gospider, hakrawler
- **JS Analysis**: subjs, linkfinder, jsscanner, jsubfinder

### Fuzzing
- **Directories**: ffuf, dirsearch, turbosearch
- **APIs**: kiterunner, arjun, paramspider, x8
- **Parameters**: arjun, paramspider, x8

### Vulnerability Scanning
- **Multi**: nuclei, jaeles
- **XSS**: dalfox
- **SQLi**: sqlmap
- **CRLF**: crlfuzz
- **SSRF**: interactsh-client

### Network
- **Port Scan**: naabu, masscan, nmap
- **Service**: httpx, httprobe
- **SSL/TLS**: tlsx, sslscan
- **Info**: nrich

### Utilities
- **Filtering**: anew, uro, unfurl, qsreplace, gf
- **CIDR**: mapcidr, prips
- **Screenshots**: gowitness
- **Wordlists**: /opt/wordlists/SecLists, /opt/wordlists/assetnote

## 🎓 Dicas de Bug Hunter Experiente

### 1. Organize Seus Dados
```bash
# Estrutura de diretório recomendada
mkdir -p /workdir/{recon/{subs,urls,js},fuzzing,vuln,screenshots,reports}
```

### 2. Use Pipes e Anew
```bash
# Sempre use anew para evitar duplicatas e manter histórico
subfinder -d target.com | anew recon/subs/all.txt | httpx | anew recon/subs/live.txt
```

### 3. Automatize com Scripts
```bash
# Exemplo de script de recon completo
#!/bin/bash
DOMAIN=$1
mkdir -p $DOMAIN/{recon,fuzzing,vuln}

# Passive recon
echo "[+] Running passive recon..."
subfinder -d $DOMAIN | anew $DOMAIN/recon/subs.txt
amass enum -passive -d $DOMAIN | anew $DOMAIN/recon/subs.txt

# Active probing
echo "[+] Probing for live hosts..."
httpx -l $DOMAIN/recon/subs.txt -o $DOMAIN/recon/live.txt

# URL discovery
echo "[+] Discovering URLs..."
cat $DOMAIN/recon/live.txt | waybackurls | anew $DOMAIN/recon/urls.txt

# Vulnerability scanning
echo "[+] Running nuclei..."
nuclei -l $DOMAIN/recon/live.txt -o $DOMAIN/vuln/nuclei.txt
```

### 4. Gestão de API Keys
```bash
# Crie um arquivo de configuração
mkdir -p ~/.config/tools

# Subfinder
cat > ~/.config/subfinder/provider-config.yaml << EOF
shodan: [YOUR_KEY]
censys: [YOUR_KEY]
virustotal: [YOUR_KEY]
EOF

# Amass
cat > ~/.config/amass/config.ini << EOF
[data_sources.Shodan]
[data_sources.Shodan.Credentials]
apikey = YOUR_KEY
EOF

# Notify (Telegram)
cat > ~/.config/notify/provider-config.yaml << EOF
telegram:
  - id: "bot_token"
    telegram_chat_id: "chat_id"
EOF
```

### 5. Performance e Recursos
```bash
# Limitar uso de CPU/RAM em scans pesados
nuclei -l targets.txt -c 10 -rl 150  # 10 concurrent, 150 req/sec

# Para alvos grandes, use screening antes
cat massive-list.txt | httpx -silent | tee live.txt | nuclei -severity critical,high
```

### 6. Segurança e OPSEC
```bash
# Use proxies quando necessário
export HTTP_PROXY=socks5://127.0.0.1:1080
export HTTPS_PROXY=socks5://127.0.0.1:1080

# Randomize user-agents
httpx -l targets.txt -random-agent

# Rate limiting para evitar ban
nuclei -l targets.txt -rl 100 -c 10
```

## 📦 Wordlists Incluídas

- **SecLists**: `/opt/wordlists/SecLists/` - Coleção completa
- **Assetnote**: `/opt/wordlists/assetnote/` - DNS wordlists otimizadas
- **Jhaddix all.txt**: `/opt/wordlists/all.txt` - Mega wordlist

## 🔗 Links Úteis

- [Nuclei Templates](https://github.com/projectdiscovery/nuclei-templates)
- [Bug Bounty Platforms](https://www.bugcrowd.com/) | [HackerOne](https://www.hackerone.com/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

## 🤝 Contribuindo

Este projeto é mantido por [@gpxlnx](https://github.com/gpxlnx). 

Para adicionar novas ferramentas, edite `scripts/expansion_script.sh` e adicione a função de instalação.

## ⚠️ Disclaimer

Esta ferramenta é para uso ético em testes autorizados apenas. O uso não autorizado é ilegal.

Happy Hacking! 🚀

