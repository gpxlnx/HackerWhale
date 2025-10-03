# 🐋 HackerWhale com Distrobox

Guia completo para usar o HackerWhale através do [Distrobox](https://github.com/89luca89/distrobox), permitindo integração total com seu sistema host.

## 🎯 Vantagens do Distrobox

- ✅ **Integração completa** com o sistema host
- ✅ **Acesso ao HOME** do usuário principal
- ✅ **Compartilhamento de arquivos** transparente
- ✅ **Executar GUI apps** do container no host
- ✅ **Export de comandos** para usar no host
- ✅ **Persistência automática** de dados
- ✅ **Múltiplas distros** simultaneamente

---

## 📦 Instalação do Distrobox

### Método 1: Curl (Recomendado)

```bash
# Instalar no sistema (com sudo)
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh

# Ou instalar localmente (sem sudo)
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
```

### Método 2: Gerenciador de Pacotes

```bash
# Ubuntu/Debian
sudo apt install distrobox

# Fedora
sudo dnf install distrobox

# Arch Linux
sudo pacman -S distrobox

# openSUSE
sudo zypper install distrobox
```

### Verificar Instalação

```bash
distrobox version
```

---

## 🚀 Criar Container HackerWhale

### Opção 1: Com Root Automaticamente

```bash
# Criar container HackerWhale logando como root
distrobox create \
  --name hackerwhale \
  --image gpxlnx/hackerwhale:latest \
  --root \
  --yes

# Entrar no container (já como root)
distrobox enter hackerwhale
```

### Opção 2: Sem Root (Rootless)

```bash
# Criar container rootless (mais seguro)
distrobox create \
  --name hackerwhale \
  --image gpxlnx/hackerwhale:latest \
  --yes

# Entrar no container
distrobox enter hackerwhale

# Dentro do container, virar root quando necessário
sudo su -
```

### Opção 3: Com Configurações Avançadas

```bash
# Container com todas as ferramentas e capacidades
distrobox create \
  --name hackerwhale \
  --image gpxlnx/hackerwhale:latest \
  --root \
  --init \
  --hostname hackerwhale \
  --additional-flags "--cap-add=NET_ADMIN --cap-add=NET_RAW" \
  --volume /opt:/opt:ro \
  --yes

# Entrar
distrobox enter hackerwhale
```

---

## 🔧 Configuração Permanente

### Criar Arquivo de Configuração

```bash
# Criar diretório de config
mkdir -p ~/.config/distrobox

# Criar arquivo de configuração
cat > ~/.config/distrobox/distrobox.conf << 'EOF'
# HackerWhale Configuration
container_manager="podman"
container_image_default="gpxlnx/hackerwhale:latest"
container_name_default="hackerwhale"
container_additional_volumes="/opt:/opt:ro"
non_interactive="1"
EOF
```

### Criar Container Automaticamente no Login

```bash
# Adicionar ao ~/.bashrc ou ~/.zshrc
echo 'alias hw="distrobox enter hackerwhale"' >> ~/.zshrc

# Criar container se não existir
cat >> ~/.zshrc << 'EOF'
# Auto-start HackerWhale
if ! distrobox list | grep -q hackerwhale; then
    distrobox create --name hackerwhale --image gpxlnx/hackerwhale:latest --root --yes
fi
EOF
```

---

## 🎯 Uso Prático

### Comandos Básicos

```bash
# Listar containers
distrobox list

# Entrar no HackerWhale (como root)
distrobox enter hackerwhale

# Executar comando direto
distrobox enter hackerwhale -- subfinder -d example.com

# Parar container
distrobox stop hackerwhale

# Remover container
distrobox rm hackerwhale
```

### Exportar Ferramentas para o Host

Você pode usar ferramentas do HackerWhale diretamente no host:

```bash
# Dentro do container HackerWhale
distrobox-export --bin /root/go/bin/subfinder --export-path ~/.local/bin
distrobox-export --bin /root/go/bin/nuclei --export-path ~/.local/bin
distrobox-export --bin /root/go/bin/httpx --export-path ~/.local/bin

# Agora você pode usar no host:
# subfinder -d example.com  (executa dentro do container automaticamente!)
```

### Exportar Aplicações GUI (se houver)

```bash
# Exportar gowitness (se precisar da GUI)
distrobox-export --app gowitness
```

---

## 📋 Workflow Completo de Bug Hunting

### 1. Setup Inicial

```bash
# Criar e configurar HackerWhale
distrobox create --name hackerwhale --image gpxlnx/hackerwhale:latest --root --yes

# Entrar
distrobox enter hackerwhale

# Configurar API keys (uma vez)
mkdir -p /root/.config/subfinder
nano /root/.config/subfinder/provider-config.yaml
```

### 2. Workflow Diário

```bash
# Do sistema host, executar recon
distrobox enter hackerwhale -- bash -c "
cd ~/recon/target.com
subfinder -d target.com | tee subs.txt
httpx -l subs.txt | tee live.txt
nuclei -l live.txt -severity critical,high
"

# Os arquivos ficam em ~/recon/target.com no seu HOME real!
```

### 3. Integração com Scripts

```bash
# Criar script de recon no host
cat > ~/bin/recon.sh << 'EOF'
#!/bin/bash
DOMAIN=$1
distrobox enter hackerwhale -- bash -c "
mkdir -p ~/recon/${DOMAIN}
cd ~/recon/${DOMAIN}
echo '[+] Subdomain enumeration...'
subfinder -d ${DOMAIN} | anew subs.txt
echo '[+] HTTP probing...'
httpx -l subs.txt | anew live.txt
echo '[+] Vulnerability scan...'
nuclei -l live.txt -severity critical,high -o vulns.txt
echo '[✓] Results in ~/recon/${DOMAIN}/'
"
EOF

chmod +x ~/bin/recon.sh

# Usar do host
recon.sh example.com
```

---

## 🔥 Configurações Avançadas

### Container com Systemd (para serviços)

```bash
distrobox create \
  --name hackerwhale-systemd \
  --image gpxlnx/hackerwhale:latest \
  --root \
  --init \
  --additional-packages "systemd libpam-systemd" \
  --yes
```

### Múltiplos Ambientes

```bash
# HackerWhale para testes gerais
distrobox create --name hw-main --image gpxlnx/hackerwhale:latest --root --yes

# HackerWhale isolado para cliente específico
distrobox create --name hw-client1 --image gpxlnx/hackerwhale:latest --root --yes

# Alternar entre eles
distrobox enter hw-main
distrobox enter hw-client1
```

### Backup e Restore

```bash
# Backup do container
podman commit hackerwhale hackerwhale-backup:$(date +%Y%m%d)

# Restaurar
distrobox create --name hackerwhale --image hackerwhale-backup:20251003 --root --yes
```

---

## 🛠️ Troubleshooting

### Problema: Container não inicia

```bash
# Verificar logs
distrobox enter hackerwhale --verbose

# Recriar do zero
distrobox rm hackerwhale --force
distrobox create --name hackerwhale --image gpxlnx/hackerwhale:latest --root --yes
```

### Problema: Ferramentas não encontradas

```bash
# Verificar PATH dentro do container
distrobox enter hackerwhale -- bash -c 'echo $PATH'

# Adicionar ao PATH permanentemente
distrobox enter hackerwhale -- bash -c 'echo "export PATH=\$PATH:/root/go/bin" >> /root/.zshrc'
```

### Problema: Sem permissões de rede

```bash
# Recriar com capacidades de rede
distrobox rm hackerwhale
distrobox create \
  --name hackerwhale \
  --image gpxlnx/hackerwhale:latest \
  --root \
  --additional-flags "--cap-add=NET_ADMIN --cap-add=NET_RAW" \
  --yes
```

---

## 📊 Comparação: Docker vs Distrobox

| Característica | Docker/Podman Normal | Distrobox |
|----------------|---------------------|-----------|
| **Isolamento** | Alto | Baixo (integrado) |
| **Acesso HOME** | Limitado | Completo |
| **GUI Apps** | Complicado | Simples |
| **Performance** | Boa | Excelente |
| **Persistência** | Manual | Automática |
| **Uso como CLI** | Complexo | Natural |
| **Múltiplas distros** | Manual | Gerenciado |

---

## 🎯 Use Cases Ideais

### ✅ Quando usar Distrobox:

- Desenvolvimento local
- Testes rápidos e frequentes
- Necessidade de GUI apps
- Acesso fácil aos arquivos do host
- Múltiplos ambientes simultâneos
- Integração com IDE do host

### ✅ Quando usar Docker/Podman puro:

- Produção/Deploy
- CI/CD pipelines
- Isolamento total necessário
- Ambientes efêmeros
- Kubernetes
- Servidores headless

---

## 🚀 Scripts Úteis

### Script de Setup Completo

```bash
#!/bin/bash
# setup-hackerwhale-distrobox.sh

echo "[+] Installing Distrobox..."
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local

echo "[+] Adding to PATH..."
echo 'export PATH=$PATH:~/.local/bin' >> ~/.zshrc

echo "[+] Creating HackerWhale container..."
distrobox create \
  --name hackerwhale \
  --image gpxlnx/hackerwhale:latest \
  --root \
  --yes

echo "[+] Creating aliases..."
cat >> ~/.zshrc << 'EOF'
alias hw='distrobox enter hackerwhale'
alias hw-root='distrobox enter --root hackerwhale'
EOF

echo "[✓] Setup complete! Use 'hw' to enter HackerWhale"
```

### Script de Exportação de Ferramentas

```bash
#!/bin/bash
# export-tools.sh
# Exportar ferramentas principais para o host

TOOLS=(
    "subfinder"
    "httpx"
    "nuclei"
    "nmap"
    "masscan"
    "naabu"
    "katana"
    "dalfox"
    "sqlmap"
)

distrobox enter hackerwhale -- bash << 'EOF'
for tool in ${TOOLS[@]}; do
    which $tool && distrobox-export --bin $(which $tool) --export-path ~/.local/bin
done
EOF

echo "[✓] Tools exported! Verify with: which subfinder"
```

---

## 📚 Recursos Adicionais

- **Distrobox Docs**: https://distrobox.it/
- **Distrobox GitHub**: https://github.com/89luca89/distrobox
- **Compatibility Table**: https://github.com/89luca89/distrobox/blob/main/docs/compatibility.md

---

## 🎓 Exemplo Prático Completo

```bash
# 1. Instalar Distrobox
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local

# 2. Criar HackerWhale
distrobox create --name hackerwhale --image gpxlnx/hackerwhale:latest --root --yes

# 3. Entrar e testar
distrobox enter hackerwhale

# Dentro do container
cd ~
mkdir -p recon/test.com
cd recon/test.com
subfinder -d hackerone.com | tee subs.txt
httpx -l subs.txt | tee live.txt
nuclei -l live.txt -severity high,critical

# 4. Sair e verificar arquivos no host
exit
ls -lah ~/recon/test.com/

# 5. Executar comandos do host
distrobox enter hackerwhale -- nuclei -version
```

---

## ⚠️ Notas Importantes

1. **Root Mode**: Ao usar `--root`, você tem acesso root dentro E fora do container. Use com cuidado!
2. **Persistência**: Dados em `/root` dentro do container persistem automaticamente
3. **HOME**: Seu `$HOME` do host é montado automaticamente
4. **Network**: Container compartilha rede com host (perfeito para pentest)
5. **GUI**: Apps gráficos funcionam out-of-the-box

---

## 🔒 Segurança

```bash
# Para maior segurança, use modo rootless:
distrobox create --name hackerwhale --image gpxlnx/hackerwhale:latest --yes

# E só use sudo quando necessário:
distrobox enter hackerwhale
sudo nmap -sS target.com
```

---

**🐋 HackerWhale + Distrobox = Ambiente de Bug Hunting Perfeito!**

Dúvidas? Issues: https://github.com/gpxlnx/HackerWhale/issues


