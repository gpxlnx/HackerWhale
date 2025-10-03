# 🚀 Getting Started - HackerWhale

Guia completo de instalação e uso desde o build até a execução com Distrobox.

---

## 📋 Índice

1. [Build Local da Imagem](#1-build-local-da-imagem)
2. [Uso com Distrobox (Recomendado)](#2-uso-com-distrobox-recomendado)
3. [Script `hw` - Acesso Rápido](#3-script-hw---acesso-rápido)
4. [Compartilhamento de Arquivos](#4-compartilhamento-de-arquivos)
5. [Atualização de Ferramentas](#5-atualização-de-ferramentas)

---

## 1. Build Local da Imagem

### Pré-requisitos

```bash
# Docker ou Podman instalado
docker --version
# ou
podman --version
```

### Método 1: Build Simples

```bash
# Clone o repositório
git clone https://github.com/gpxlnx/HackerWhale.git
cd HackerWhale

# Build da imagem (pode levar 20-30 minutos)
docker build -t hackerwhale:latest .
```

### Método 2: Build com Script Helper

```bash
# Usando o script auxiliar
chmod +x hackerwhale.sh
./hackerwhale.sh build

# Ver status
./hackerwhale.sh status
```

### Verificar Build

```bash
# Listar imagens
docker images | grep hackerwhale

# Testar rapidamente
docker run --rm hackerwhale:latest subfinder -version
```

---

## 2. Uso com Distrobox (Recomendado)

### Por que Distrobox?

✅ **Integração total** com o sistema host  
✅ **Acesso nativo** aos arquivos do host  
✅ **Sem overhead** de volumes Docker  
✅ **Performance** melhor que containers tradicionais  
✅ **Ferramentas exportadas** para uso direto no host

### Instalação do Distrobox

```bash
# Método 1: Script oficial
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local

# Método 2: Package manager
# Arch
sudo pacman -S distrobox

# Fedora
sudo dnf install distrobox

# Ubuntu/Debian (via PPA)
sudo add-apt-repository ppa:michel-slm/distrobox
sudo apt update && sudo apt install distrobox
```

### Verificar Instalação

```bash
distrobox --version
```

### Criar Container HackerWhale

#### Opção A: Script Automático (Recomendado)

```bash
# Usar imagem local que você buildou
./distrobox-setup.sh

# Quando perguntar se quer usar imagem local, responda: Y
```

#### Opção B: Manual

```bash
# Criar container (usando imagem local)
distrobox create \
  --name hackerwhale \
  --image hackerwhale:latest \
  --yes

# Verificar
distrobox list
```

### Entrar no Container

```bash
# Entrar como usuário normal
distrobox enter hackerwhale

# Dentro do container, virar root
sudo su -

# Agora você está como root com todas as ferramentas!
whoami
# Output: root

subfinder -version
# Output: v2.9.0 (latest)
```

### Sair do Container

```bash
# Dentro do container, simplesmente:
exit        # Sai do root
exit        # Sai do container
```

---

## 3. Script `hw` - Acesso Rápido

### O que é o `hw`?

Um script helper que simplifica o acesso ao container HackerWhale como root, com workspace compartilhado configurado automaticamente.

### Instalação

```bash
# Copiar script para PATH
chmod +x hw
mkdir -p ~/bin
cp hw ~/bin/

# Adicionar ~/bin ao PATH (se ainda não estiver)
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
# ou para zsh:
echo 'export PATH=$HOME/bin:$PATH' >> ~/.zshrc

# Recarregar shell
source ~/.bashrc  # ou ~/.zshrc
```

### Uso Básico

```bash
# Entrar no container como root (workspace compartilhado ativo)
hw

# Você está em /root/workspace/ (= ~/hackerwhale-workspace no host)
pwd
# Output: /root/workspace

# Todas as ferramentas estão no PATH
subfinder -version
httpx -version
nuclei -version
```

### Comandos Disponíveis

```bash
# Entrar como root (padrão)
hw
hw root
hw -r
hw --root

# Entrar como usuário
hw user
hw -u
hw --user

# Executar comando único
hw run "subfinder -d example.com"
hw run "nuclei -l targets.txt -severity critical,high"

# Status do container
hw status

# Ajuda
hw help
```

### Exemplo de Workflow

```bash
# No host: preparar alvos
echo "example.com" > ~/hackerwhale-workspace/domains.txt
echo "test.com" >> ~/hackerwhale-workspace/domains.txt

# Entrar no container
hw

# Dentro (já em /root/workspace):
cat domains.txt | while read domain; do
    echo "[+] Recon: $domain"
    mkdir -p $domain
    cd $domain
    
    subfinder -d $domain | tee subs.txt
    httpx -l subs.txt | tee live.txt
    nuclei -l live.txt -o vulns.txt
    
    cd ..
done

# Sair
exit

# No host: ver resultados
ls -la ~/hackerwhale-workspace/
cat ~/hackerwhale-workspace/example.com/vulns.txt
```

---

## 4. Compartilhamento de Arquivos

### Workspace Compartilhado (Automático com `hw`)

Quando você usa o script `hw`, ele cria automaticamente:

**Host:**
```
~/hackerwhale-workspace/
```

**Container (root):**
```
/root/workspace/ -> link simbólico para ~/hackerwhale-workspace
```

### Estrutura Recomendada

```bash
~/hackerwhale-workspace/
├── recon/
│   ├── client1/
│   │   ├── subs.txt
│   │   ├── live.txt
│   │   └── vulns.txt
│   └── client2/
├── wordlists/
│   └── custom.txt
├── scripts/
│   └── my-recon.sh
└── reports/
    └── findings.md
```

### Acessar Outros Diretórios do Host

```bash
# Distrobox já monta automaticamente todo o seu HOME
hw

# Dentro do container, acessar:
ls /home/$USER/Documents
ls /home/$USER/Downloads

# Criar links se preferir:
ln -s /home/$USER/Documents /root/docs
ln -s /home/$USER/Downloads /root/downloads
```

📖 **[Guia Completo de Compartilhamento](./FILE_SHARING_GUIDE.md)**

---

## 5. Atualização de Ferramentas

### Atualizar Ferramentas Go

```bash
# Dentro do container (via hw):
hw

# Executar script de atualização
cd /root
./update-tools.sh
```

### Atualizar Manualmente

```bash
hw

# Atualizar ferramenta específica
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Atualizar templates do Nuclei
nuclei -update-templates
```

### Rebuild da Imagem (Para Atualizações Permanentes)

```bash
# No host, sair do container
exit

# Rebuild
cd /home/gxavier/HackerWhale
docker build -t hackerwhale:latest .

# Recriar container Distrobox
distrobox rm hackerwhale -f
distrobox create --name hackerwhale --image hackerwhale:latest --yes
```

---

## 🎯 Quick Reference

### Fluxo Completo

```bash
# 1. Build (primeira vez)
git clone https://github.com/gpxlnx/HackerWhale.git
cd HackerWhale
docker build -t hackerwhale:latest .

# 2. Setup Distrobox (primeira vez)
./distrobox-setup.sh

# 3. Instalar script hw (primeira vez)
chmod +x hw && cp hw ~/bin/

# 4. Usar diariamente
hw                                    # Entrar
subfinder -d example.com -o subs.txt  # Trabalhar
exit                                  # Sair

# 5. Ver resultados no host
cat ~/hackerwhale-workspace/subs.txt
```

### Comandos Essenciais

| Ação | Comando |
|------|---------|
| **Build imagem** | `docker build -t hackerwhale:latest .` |
| **Criar container** | `./distrobox-setup.sh` |
| **Entrar (root)** | `hw` |
| **Executar comando** | `hw run "subfinder -d example.com"` |
| **Status** | `hw status` ou `distrobox list` |
| **Remover container** | `distrobox rm hackerwhale -f` |
| **Workspace** | `~/hackerwhale-workspace/` (host) |
| **Workspace** | `/root/workspace/` (container) |

---

## 🆘 Troubleshooting

### Container não inicia

```bash
# Ver logs
distrobox list
docker ps -a | grep hackerwhale

# Recriar
distrobox rm hackerwhale -f
distrobox create --name hackerwhale --image hackerwhale:latest --yes
```

### Ferramentas desatualizadas

```bash
# Atualizar dentro do container
hw
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```

### Workspace não compartilhado

```bash
# Recriar link
hw run "ln -sfn /home/\$USER/hackerwhale-workspace /root/workspace"
```

### Script `hw` não encontrado

```bash
# Adicionar ~/bin ao PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

---

## 📚 Próximos Passos

- 📖 [Guia Completo Distrobox](./DISTROBOX_GUIDE.md) - Features avançadas
- 🎓 [Bug Hunter Guide](./BUGHUNTER_GUIDE.md) - Workflows práticos
- 📂 [File Sharing Guide](./FILE_SHARING_GUIDE.md) - Compartilhamento avançado
- 🚀 [Advanced Usage](./ADVANCED_USAGE.md) - VPS, K8s, CI/CD

---

**🐋 Happy Hacking!**

