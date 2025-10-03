# ⚡ HackerWhale - Commands Cheatsheet

Referência rápida de comandos mais usados.

---

## 🏗️ Build & Setup

```bash
# Build da imagem
docker build -t hackerwhale:latest .

# Setup Distrobox (automático)
./distrobox-setup.sh

# Instalar script hw
chmod +x hw && cp hw ~/bin/

# Verificar instalação
docker images | grep hackerwhale
distrobox list
hw status
```

---

## 🚀 Acesso ao Container

```bash
# Método 1: Script hw (Recomendado)
hw                              # Entra como root em /root/workspace
hw root                         # Mesma coisa
hw user                         # Entra como usuário
hw run "comando"                # Executa comando único

# Método 2: Distrobox direto
distrobox enter hackerwhale     # Entra como usuário
distrobox enter hackerwhale -- sudo su -  # Entra e vira root

# Método 3: Docker tradicional
docker run -it --rm hackerwhale:latest zsh
```

---

## 🔍 Reconnaissance

### Subdomain Enumeration
```bash
# Subfinder
subfinder -d example.com
subfinder -d example.com -o subs.txt
subfinder -dL domains.txt -o all-subs.txt

# Amass
amass enum -d example.com
amass enum -d example.com -o amass-subs.txt

# Assetfinder
assetfinder --subs-only example.com
echo example.com | assetfinder | anew subs.txt

# Múltiplas ferramentas
subfinder -d example.com -silent | anew subs.txt
assetfinder --subs-only example.com | anew subs.txt
```

### DNS Resolution
```bash
# Dnsx - resolver subdomínios
dnsx -l subs.txt -o resolved.txt
dnsx -l subs.txt -resp -o resolved-ips.txt

# MassDNS
massdns -r /usr/share/massdns/lists/resolvers.txt -t A subs.txt -o S

# ShuffleDNS
shuffledns -d example.com -w /wordlists/subdomains.txt -r resolvers.txt
```

### HTTP Probing
```bash
# Httpx
httpx -l subs.txt
httpx -l subs.txt -o live.txt
httpx -l subs.txt -status-code -title -tech-detect -o results.txt

# Httprobe
cat subs.txt | httprobe
cat subs.txt | httprobe | anew live.txt
```

---

## 🌐 Web Discovery

### URL Collection
```bash
# Waybackurls
waybackurls example.com | anew urls.txt
cat subs.txt | waybackurls | anew urls.txt

# Gau
gau example.com | anew urls.txt
gau --threads 5 example.com

# Haktrails
haktrails subdomains example.com
haktrails urls example.com
```

### Crawling
```bash
# Katana
katana -u https://example.com
katana -u https://example.com -d 3 -o katana-urls.txt
katana -list urls.txt -o crawled.txt

# GoSpider
gospider -s https://example.com -o output
gospider -S sites.txt -o output -c 10 -d 3
```

### JavaScript Analysis
```bash
# Subjs
subjs -i urls.txt
cat urls.txt | subjs | anew js-files.txt

# Linkfinder
python3 /tools/LinkFinder/linkfinder.py -i https://example.com/app.js -o results.html
```

---

## 🎯 Fuzzing

### Directory/File Fuzzing
```bash
# Ffuf
ffuf -u https://example.com/FUZZ -w /wordlists/common.txt
ffuf -u https://example.com/FUZZ -w /wordlists/SecLists/Discovery/Web-Content/raft-large-directories.txt -mc 200,301,302,401,403

# Dirsearch
dirsearch -u https://example.com
dirsearch -u https://example.com -e php,html,js -x 404,500
```

### Parameter Discovery
```bash
# Arjun
arjun -u https://example.com/api/endpoint
arjun -i urls.txt -o params.json

# ParamSpider
paramspider -d example.com
paramspider -l domains.txt
```

### API Fuzzing
```bash
# Kiterunner
kr scan https://example.com/api/ -w routes.txt
kr brute https://example.com/api/ -w routes.txt
```

---

## 🐛 Vulnerability Scanning

### Nuclei
```bash
# Basic scan
nuclei -u https://example.com
nuclei -l urls.txt -o vulns.txt

# Severity filtering
nuclei -l urls.txt -severity critical,high -o critical-vulns.txt

# Specific templates
nuclei -l urls.txt -t cves/ -t vulnerabilities/ -o scan-results.txt

# Update templates
nuclei -update-templates
```

### XSS Testing
```bash
# Dalfox
dalfox url https://example.com?param=value
dalfox file urls.txt -o xss-results.txt
echo "https://example.com?q=FUZZ" | dalfox pipe
```

### SQL Injection
```bash
# SQLMap
sqlmap -u "https://example.com?id=1"
sqlmap -u "https://example.com?id=1" --dbs
sqlmap -u "https://example.com?id=1" -D dbname --tables
sqlmap -r request.txt --batch
```

### CRLF Injection
```bash
# Crlfuzz
crlfuzz -u https://example.com
crlfuzz -l urls.txt -o crlf-vulns.txt
```

---

## 🌐 Network Scanning

### Port Scanning
```bash
# Naabu
naabu -host example.com
naabu -list hosts.txt -o ports.txt
naabu -host example.com -top-ports 1000

# Nmap
nmap -sV example.com
nmap -sC -sV -oA scan example.com
nmap -p- -T4 example.com

# Masscan
masscan -p1-65535 --rate=10000 10.0.0.0/8
```

### SSL/TLS
```bash
# Tlsx
tlsx -u example.com
tlsx -l hosts.txt -san -cn -o tls-info.txt

# SSLScan
sslscan example.com
```

---

## 🛠️ Utilities

### Filtering & Deduplication
```bash
# Anew - adicionar apenas linhas novas
cat new-subs.txt | anew all-subs.txt

# Uro - limpar URLs duplicadas
cat urls.txt | uro | anew clean-urls.txt

# Qsreplace - substituir query strings
cat urls.txt | qsreplace "FUZZ"
```

### Pattern Matching
```bash
# Gf - grep avançado com patterns
cat urls.txt | gf xss
cat urls.txt | gf sqli
cat urls.txt | gf redirect
cat urls.txt | gf ssrf
```

### Screenshots
```bash
# Gowitness
gowitness scan single -u https://example.com
gowitness scan file -f urls.txt
```

### Notifications
```bash
# Notify
echo "Scan completed!" | notify
cat vulns.txt | notify

# Telegram-send
telegram-send "Scan completed!"
telegram-send --file results.txt
```

---

## 📁 File Management

### Workspace
```bash
# No host: criar estrutura
mkdir -p ~/hackerwhale-workspace/recon/{client1,client2}
mkdir -p ~/hackerwhale-workspace/{wordlists,scripts,reports}

# Dentro do container (via hw)
hw
cd /root/workspace  # = ~/hackerwhale-workspace no host
ls -la
```

### Transferência
```bash
# Host → Container
cp ~/Documents/targets.txt ~/hackerwhale-workspace/

# Container → Host (automático, mesmo diretório)
hw run "subfinder -d example.com -o /root/workspace/subs.txt"
# Arquivo aparece em ~/hackerwhale-workspace/subs.txt
```

---

## 🔄 Manutenção

### Atualizar Ferramentas
```bash
# Dentro do container
hw
./update-tools.sh

# Ou manualmente
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest

# Atualizar templates
nuclei -update-templates
```

### Container Management
```bash
# Listar containers
distrobox list
docker ps -a

# Parar container
distrobox stop hackerwhale

# Remover container
distrobox rm hackerwhale -f

# Recriar
distrobox create --name hackerwhale --image hackerwhale:latest --yes
```

### Rebuild Imagem
```bash
# Rebuild completo
docker build --no-cache -t hackerwhale:latest .

# Rebuild incremental
docker build -t hackerwhale:latest .

# Limpar imagens antigas
docker image prune -a
```

---

## 📊 Workflows Completos

### Workflow 1: Recon Básico
```bash
hw

# 1. Subdomain enum
subfinder -d example.com | tee subs.txt

# 2. HTTP probing
httpx -l subs.txt | tee live.txt

# 3. URL discovery
katana -list live.txt | tee urls.txt

# 4. Vulnerability scan
nuclei -l urls.txt -severity critical,high -o vulns.txt

exit
cat ~/hackerwhale-workspace/vulns.txt
```

### Workflow 2: Recon Profundo
```bash
hw
DOMAIN="example.com"
mkdir -p /root/workspace/$DOMAIN
cd /root/workspace/$DOMAIN

# 1. Subdomain enum (múltiplas ferramentas)
subfinder -d $DOMAIN -silent | anew subs.txt
assetfinder --subs-only $DOMAIN | anew subs.txt
amass enum -d $DOMAIN -silent | anew subs.txt

# 2. DNS resolution
dnsx -l subs.txt -resp -o resolved.txt

# 3. HTTP probing
httpx -l resolved.txt -o live.txt

# 4. Port scanning
naabu -list live.txt -o ports.txt

# 5. URL discovery
waybackurls $DOMAIN | anew urls.txt
gau $DOMAIN | anew urls.txt
katana -list live.txt | anew urls.txt

# 6. JS discovery
subjs -i urls.txt | anew js-files.txt

# 7. Parameter discovery
arjun -i live.txt -o params.json

# 8. Vulnerability scan
nuclei -l urls.txt -severity critical,high,medium -o vulns.txt

# 9. XSS scan
dalfox file urls.txt -o xss.txt

exit
tree ~/hackerwhale-workspace/$DOMAIN
```

### Workflow 3: Monitoramento Contínuo
```bash
# Criar script de monitoramento
cat > ~/hackerwhale-workspace/monitor.sh << 'EOF'
#!/bin/bash
DOMAIN=$1
INTERVAL=${2:-3600}

while true; do
  echo "[$(date)] Monitoring $DOMAIN..."
  
  # Buscar novos subdomínios
  subfinder -d $DOMAIN -silent | anew /root/workspace/monitor/$DOMAIN-subs.txt | notify
  
  # Buscar novos hosts vivos
  httpx -l /root/workspace/monitor/$DOMAIN-subs.txt -silent | anew /root/workspace/monitor/$DOMAIN-live.txt | notify
  
  sleep $INTERVAL
done
EOF

chmod +x ~/hackerwhale-workspace/monitor.sh

# Executar
hw run "mkdir -p /root/workspace/monitor && nohup bash /root/workspace/monitor.sh example.com > /root/workspace/monitor/monitor.log 2>&1 &"

# Acompanhar logs
tail -f ~/hackerwhale-workspace/monitor/monitor.log
```

---

## 🆘 Troubleshooting

```bash
# Verificar se container está rodando
distrobox list
docker ps

# Ver logs do container
docker logs hackerwhale

# Entrar em container com problemas
distrobox enter hackerwhale -- bash

# Verificar versão das ferramentas
hw run "subfinder -version"
hw run "nuclei -version"

# Resetar tudo
distrobox rm hackerwhale -f
docker rmi hackerwhale:latest
# Rebuild...
```

---

## 📝 Tips & Tricks

```bash
# Usar pipes para combinar ferramentas
subfinder -d example.com -silent | httpx -silent | nuclei -silent

# Adicionar rate limiting
subfinder -d example.com -rate-limit 10

# Usar múltiplos threads
nuclei -l urls.txt -t cves/ -c 50

# Filtrar por status code
httpx -l urls.txt -mc 200,201,301,302,401,403,500

# Combinar com notify
subfinder -d example.com | httpx | notify

# Usar wordlist customizada
ffuf -u https://example.com/FUZZ -w ~/hackerwhale-workspace/wordlists/custom.txt

# Background tasks
nohup nuclei -l urls.txt -o scan.txt > /dev/null 2>&1 &
```

---

**⚡ Para mais detalhes, consulte [GETTING_STARTED.md](./GETTING_STARTED.md)**

