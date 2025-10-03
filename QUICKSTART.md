# 🚀 HackerWhale - Quick Start Guide

**Comece a fazer bug hunting em 5 minutos!**

## ⚡ Instalação Rápida

### Opção 1: Docker Hub (Mais Rápido - Recomendado)

```bash
# Pull e execute (30 segundos)
docker run -it --rm \
  --name hackerwhale \
  -v $(pwd)/data:/workdir \
  --cap-add=NET_ADMIN \
  --net=host \
  gpxlnx/hackerwhale:latest zsh
```

### Opção 2: Build Local (Com Customizações)

```bash
# Clone e execute (10-15 minutos)
git clone https://github.com/gpxlnx/HackerWhale.git
cd HackerWhale
chmod +x hackerwhale.sh
./hackerwhale.sh build
./hackerwhale.sh run
```

---

## 🎯 Primeiro Scan (3 minutos)

### Teste Básico

```bash
# Dentro do container
cd /workdir

# 1. Subdomain Discovery
subfinder -d hackerone.com | tee subs.txt
# Resultado: lista de subdomínios

# 2. Check Live Hosts
httpx -l subs.txt -o live.txt
# Resultado: hosts que respondem HTTP

# 3. Quick Vuln Scan
nuclei -l live.txt -severity high,critical
# Resultado: vulnerabilidades encontradas
```

**Pronto!** Você acabou de fazer seu primeiro scan com HackerWhale! 🎉

---

## 💡 Workflows Prontos

### Recon Automático

```bash
# Use o helper script (fora do container)
./hackerwhale.sh recon example.com

# Ou manualmente (dentro do container)
cd /workdir
mkdir example.com && cd example.com

# Pipeline completo
subfinder -d example.com | anew subs.txt
httpx -l subs.txt | anew live.txt
waybackurls example.com | anew urls.txt
nuclei -l live.txt -o vulns.txt
```

### Scanning de Lista

```bash
# Se você tem uma lista de alvos
cat targets.txt | httpx -silent | nuclei -severity critical,high
```

### Monitoramento Contínuo

```bash
# Monitorar mudanças (roda indefinidamente)
./hackerwhale.sh monitor example.com
```

---

## 🔑 Configurar API Keys (Opcional mas Recomendado)

### 1. Criar arquivo de config do Subfinder

```bash
mkdir -p ~/.config/subfinder
cat > ~/.config/subfinder/provider-config.yaml << EOF
shodan:
  - SEU_SHODAN_KEY_AQUI
censys:
  - SEU_CENSYS_ID:SEU_CENSYS_SECRET
virustotal:
  - SEU_VIRUSTOTAL_KEY_AQUI
EOF
```

### 2. Obter API Keys Gratuitas

| Serviço | Link | Limite Gratuito |
|---------|------|-----------------|
| Shodan | https://account.shodan.io/ | 100 créditos/mês |
| Censys | https://search.censys.io/ | 250 queries/mês |
| VirusTotal | https://www.virustotal.com/ | 500 queries/dia |
| GitHub | https://github.com/settings/tokens | 5000 req/hora |

Ver guia completo: [API_KEYS_TEMPLATE.md](./API_KEYS_TEMPLATE.md)

---

## 📚 Ferramentas Mais Usadas

### Reconnaissance
```bash
subfinder -d target.com           # Passive subdomain enum
amass enum -passive -d target.com # Comprehensive recon
httpx -l domains.txt              # HTTP probing
```

### Discovery
```bash
waybackurls target.com            # Historical URLs
katana -u https://target.com      # Modern crawler
gau target.com                    # Get All URLs
```

### Fuzzing
```bash
ffuf -u https://target.com/FUZZ -w wordlist.txt  # Directory fuzzing
arjun -u https://target.com       # Parameter discovery
```

### Vulnerability Scanning
```bash
nuclei -u https://target.com      # Multi-purpose scanner
dalfox url https://target.com     # XSS scanner
sqlmap -u https://target.com      # SQLi scanner
```

---

## 🎓 Aprenda Mais

### Documentação Completa

| Guia | Para Quem | Tempo Leitura |
|------|-----------|---------------|
| [BUGHUNTER_GUIDE.md](./BUGHUNTER_GUIDE.md) | Iniciantes/Intermediários | 15 min |
| [ADVANCED_USAGE.md](./ADVANCED_USAGE.md) | Avançados | 20 min |
| [AUTOMATION_SCRIPTS.md](./AUTOMATION_SCRIPTS.md) | Todos | 10 min |
| [API_KEYS_TEMPLATE.md](./API_KEYS_TEMPLATE.md) | Todos | 5 min |

### Comandos Essenciais

```bash
# Ver ferramentas instaladas
ls /root/go/bin/

# Ver wordlists disponíveis
ls /opt/wordlists/

# Atualizar templates do Nuclei
nuclei -update-templates

# Verificar versões
subfinder -version
httpx -version
nuclei -version
```

---

## 🆘 Problemas Comuns

### Container não inicia

```bash
# Verificar se Docker está rodando
docker ps

# Verificar logs
docker logs hackerwhale

# Reiniciar Docker
sudo systemctl restart docker
```

### Ferramenta não encontrada

```bash
# Verificar PATH
echo $PATH

# Adicionar Go bin ao PATH
export PATH=$PATH:/root/go/bin
```

### Sem permissão de rede

```bash
# Container precisa de NET_ADMIN capability
docker run --cap-add=NET_ADMIN --net=host ...
```

### DNS não resolve

```bash
# Usar DNS público
docker run --dns 8.8.8.8 --dns 1.1.1.1 ...
```

---

## 💻 Comandos Docker Úteis

```bash
# Ver containers rodando
docker ps

# Ver logs do container
docker logs -f hackerwhale

# Entrar no container
docker exec -it hackerwhale zsh

# Parar container
docker stop hackerwhale

# Remover container
docker rm hackerwhale

# Ver uso de recursos
docker stats hackerwhale

# Copiar arquivo para container
docker cp file.txt hackerwhale:/workdir/

# Copiar arquivo do container
docker cp hackerwhale:/workdir/results.txt .
```

---

## 🎯 Seu Primeiro Bug Bounty

### Passo a Passo Completo

```bash
# 1. Escolher target (ex: de um programa público)
TARGET="example.com"

# 2. Criar diretório
mkdir -p /workdir/$TARGET
cd /workdir/$TARGET

# 3. Recon de subdomínios
echo "[+] Finding subdomains..."
subfinder -d $TARGET | anew subs.txt
amass enum -passive -d $TARGET | anew subs.txt

# 4. Check live hosts
echo "[+] Checking live hosts..."
httpx -l subs.txt -status-code -tech-detect -title -json -o http.json
cat http.json | jq -r '.url' > live.txt

# 5. Screenshot (para triagem visual)
echo "[+] Taking screenshots..."
gowitness file -f live.txt -D screenshots/

# 6. Find URLs
echo "[+] Finding URLs..."
cat live.txt | waybackurls | anew urls.txt
cat live.txt | gau | anew urls.txt
cat live.txt | katana -silent | anew urls.txt

# 7. Port scan
echo "[+] Port scanning..."
naabu -list live.txt -top-ports 1000 -o ports.txt

# 8. Vulnerability scan
echo "[+] Scanning for vulnerabilities..."
nuclei -list live.txt -severity critical,high,medium -o vulns.txt

# 9. XSS testing em URLs
echo "[+] Testing XSS..."
cat urls.txt | gf xss | dalfox pipe -o xss.txt

# 10. Review resultados
echo ""
echo "========== RESULTS =========="
echo "Subdomains: $(wc -l < subs.txt)"
echo "Live: $(wc -l < live.txt)"
echo "URLs: $(wc -l < urls.txt)"
echo "Ports: $(wc -l < ports.txt)"
echo "Vulns: $(wc -l < vulns.txt)"
echo "============================="
```

### O que fazer com os resultados?

1. **Revisar vulnerabilidades** (vulns.txt)
2. **Validar manualmente** cada finding
3. **Documentar** com screenshots e PoC
4. **Reportar** no programa de bug bounty
5. **Aguardar** triagem e recompensa! 💰

---

## 🎁 Bonus: One-Liners Poderosos

```bash
# Recon super rápido
echo "target.com" | subfinder -silent | httpx -silent | nuclei -silent

# Find XSS em segundos
waybackurls target.com | gf xss | dalfox pipe

# Mass scanning paralelo
cat domains.txt | parallel -j 10 "subfinder -d {} | httpx | nuclei > {}.txt"

# Monitor com notificação
while true; do subfinder -d target.com | anew subs.txt | notify; sleep 3600; done

# Full pipeline em uma linha
subfinder -d target.com | httpx | katana | gf xss | dalfox pipe | notify
```

---

## 📞 Próximos Passos

1. ✅ Teste o quick start acima
2. 📖 Leia o [Bug Hunter Guide](./BUGHUNTER_GUIDE.md)
3. 🔑 Configure [API Keys](./API_KEYS_TEMPLATE.md)
4. 🤖 Use [Scripts de Automação](./AUTOMATION_SCRIPTS.md)
5. 🚀 Deploy em [VPS/K8s](./ADVANCED_USAGE.md)
6. 💰 Reporte seu primeiro bug!

---

## 🌟 Dicas Finais

- ✅ Sempre tenha **autorização** antes de testar
- ✅ Leia o **scope** do programa
- ✅ **Documente** tudo que fizer
- ✅ **Valide** findings antes de reportar
- ✅ Seja **responsável** e **ético**

---

**🐋 Happy Hunting!**

Dúvidas? Abra uma issue: https://github.com/gpxlnx/HackerWhale/issues

---

*Made with ❤️ by bug hunters, for bug hunters*

