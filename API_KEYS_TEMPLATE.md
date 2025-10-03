# 🔑 Configuração de API Keys

Para maximizar os resultados das ferramentas de reconnaissance, configure suas API keys.

## 📋 Criando Arquivos de Configuração

### 1. Subfinder (~/.config/subfinder/provider-config.yaml)

```yaml
shodan:
  - YOUR_SHODAN_KEY
censys:
  - YOUR_CENSYS_ID:YOUR_CENSYS_SECRET
virustotal:
  - YOUR_VIRUSTOTAL_KEY
passivetotal:
  - YOUR_USERNAME:YOUR_KEY
securitytrails:
  - YOUR_SECURITYTRAILS_KEY
binaryedge:
  - YOUR_BINARYEDGE_KEY
github:
  - YOUR_GITHUB_TOKEN
```

### 2. Amass (~/.config/amass/config.ini)

```ini
[data_sources.Shodan]
[data_sources.Shodan.Credentials]
apikey = YOUR_SHODAN_KEY

[data_sources.Censys]
[data_sources.Censys.Credentials]
apikey = YOUR_CENSYS_ID
secret = YOUR_CENSYS_SECRET

[data_sources.VirusTotal]
[data_sources.VirusTotal.Credentials]
apikey = YOUR_VIRUSTOTAL_KEY

[data_sources.SecurityTrails]
[data_sources.SecurityTrails.Credentials]
apikey = YOUR_SECURITYTRAILS_KEY

[data_sources.GitHub]
[data_sources.GitHub.accountname]
apikey = YOUR_GITHUB_TOKEN
```

### 3. Notify (~/.config/notify/provider-config.yaml)

```yaml
telegram:
  - id: "hackerwhale"
    telegram_apikey: "YOUR_BOT_TOKEN"
    telegram_chatid: "YOUR_CHAT_ID"

discord:
  - id: "hackerwhale"
    discord_webhook_url: "YOUR_WEBHOOK_URL"

slack:
  - id: "hackerwhale"
    slack_webhook_url: "YOUR_WEBHOOK_URL"
```

### 4. Uncover (~/.config/uncover/provider-config.yaml)

```yaml
shodan:
  - YOUR_SHODAN_KEY
censys:
  - YOUR_CENSYS_ID:YOUR_CENSYS_SECRET
fofa:
  - YOUR_FOFA_EMAIL:YOUR_FOFA_KEY
hunter:
  - YOUR_HUNTER_KEY
zoomeye:
  - YOUR_ZOOMEYE_KEY
```

### 5. Chaos (~/.config/chaos/config.yaml)

```yaml
api_key: YOUR_CHAOS_KEY
```

## 🆓 Como Obter API Keys Gratuitas

### Shodan
- Website: https://account.shodan.io/
- Gratuito: 100 créditos/mês
- Essencial para: Port scanning, service detection

### Censys
- Website: https://search.censys.io/
- Gratuito: 250 queries/mês
- Essencial para: Certificate transparency, infrastructure mapping

### VirusTotal
- Website: https://www.virustotal.com/gui/join-us
- Gratuito: 500 queries/dia
- Essencial para: Domain reputation, subdomain discovery

### GitHub
- Website: https://github.com/settings/tokens
- Gratuito: 5000 requests/hora
- Essencial para: Code search, subdomain leaks
- Permissões: `public_repo`, `read:org`

### SecurityTrails
- Website: https://securitytrails.com/
- Gratuito: 50 queries/mês
- Essencial para: Historical DNS data

### Chaos (ProjectDiscovery)
- Website: https://chaos.projectdiscovery.io/
- Gratuito: Sim
- Essencial para: Public bug bounty scope data

### Hunter.io
- Website: https://hunter.io/
- Gratuito: 25 queries/mês
- Essencial para: Email discovery

### Telegram Bot
1. Fale com @BotFather no Telegram
2. Envie `/newbot`
3. Siga as instruções
4. Pegue o token
5. Adicione o bot ao seu grupo
6. Pegue o chat_id usando: `https://api.telegram.org/bot<TOKEN>/getUpdates`

## 📦 Montando Configurações no Container

### Opção 1: Volume Mount (Recomendado)

```bash
docker run -it --rm \
  -v $(pwd)/data:/workdir \
  -v $(pwd)/configs:/root/.config \
  hackerwhale:latest
```

### Opção 2: Docker Compose

```yaml
volumes:
  - ./configs:/root/.config
```

### Opção 3: Build Time

Coloque seus arquivos de config em `configs/` e modifique o Dockerfile:

```dockerfile
COPY configs/subfinder /root/.config/subfinder
COPY configs/amass /root/.config/amass
COPY configs/notify /root/.config/notify
```

## 🔒 Segurança

### Nunca commite API keys!

Adicione ao `.gitignore`:
```
.env
configs/
*.key
*secret*
provider-config.yaml
```

### Use variáveis de ambiente

```bash
export SHODAN_KEY="your_key"
export CENSYS_ID="your_id"
export CENSYS_SECRET="your_secret"
```

### Ou use Docker secrets

```bash
echo "your_api_key" | docker secret create shodan_key -
```

## 📊 Verificando Configurações

Execute dentro do container:

```bash
# Subfinder
subfinder -d example.com -v

# Amass
amass enum -d example.com -list

# Chaos
chaos -d example.com

# Uncover
uncover -q 'ssl:"example.com"' -e shodan,censys
```

## 🎯 Prioridade de API Keys

Se você tem orçamento limitado ou quer começar, priorize nesta ordem:

1. **GitHub** (Grátis e essencial)
2. **Shodan** (100 créditos grátis/mês)
3. **VirusTotal** (500 queries/dia grátis)
4. **Censys** (250 queries/mês grátis)
5. **Chaos** (Grátis, dados de bug bounty)
6. **Telegram Bot** (Grátis, para notificações)

## 📝 Template de Teste

Crie um arquivo `test-apis.sh`:

```bash
#!/bin/bash

echo "[+] Testing API configurations..."

echo "[*] Testing Subfinder..."
subfinder -d hackerone.com -max-time 1 | head -5

echo "[*] Testing Chaos..."
chaos -d hackerone.com | head -5

echo "[*] Testing Amass..."
amass enum -passive -d hackerone.com -timeout 1

echo "[+] Test complete!"
```

## 🔗 Links Úteis

- [Subfinder Config Docs](https://github.com/projectdiscovery/subfinder#post-installation-instructions)
- [Amass Config Docs](https://github.com/owasp-amass/amass/blob/master/examples/config.ini)
- [Notify Config Docs](https://github.com/projectdiscovery/notify)
- [Uncover Docs](https://github.com/projectdiscovery/uncover)

