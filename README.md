# 🐋 HackerWhale

![](https://res.cloudinary.com/dtr6hzxnx/image/upload/v1723166559/blog/HackerWhale_-_tiagotavares.io_xrvsrq.png)

> **Uma imagem Docker completa para Bug Hunting e Pentest, com 75+ ferramentas prontas para uso.**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://hub.docker.com/r/gpxlnx/hackerwhale)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?logo=kubernetes)](./k8s/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-success.svg)](https://github.com/gpxlnx/HackerWhale)

## 🎯 Por que HackerWhale?

Este projeto nasceu da necessidade de ter um ambiente isolado, portátil e completo para testes de segurança, sem interferir no sistema host. Em poucos minutos você terá:

- ✅ **75+ ferramentas** de recon, scanning e exploitation
- ✅ **Wordlists essenciais** (SecLists, Assetnote, etc)
- ✅ **Zero configuração** - tudo já vem instalado
- ✅ **Portabilidade** - rode em qualquer lugar (local, VPS, K8s)
- ✅ **Isolamento** - não suja seu sistema operacional
- ✅ **Workflows prontos** - scripts para cenários comuns

## 🚀 Quick Start

### 🔥 Método Recomendado: Build Local + Distrobox + `hw`

```bash
# 1. Build da imagem local
git clone https://github.com/gpxlnx/HackerWhale.git
cd HackerWhale
docker build -t hackerwhale:latest .

# 2. Setup Distrobox
./distrobox-setup.sh
# Quando perguntar, escolha usar imagem local (Y)

# 3. Instalar script hw
chmod +x hw && cp hw ~/bin/

# 4. Pronto! Usar diariamente:
hw                                    # Entrar no container como root
subfinder -d example.com -o subs.txt  # Usar ferramentas
exit                                  # Sair
```

📖 **[📘 Guia Completo de Instalação](./GETTING_STARTED.md)** ← Comece aqui!

---

### Métodos Alternativos

#### Opção 1: Distrobox com Imagem do Docker Hub

```bash
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
distrobox create --name hackerwhale --image gpxlnx/hackerwhale:latest --yes
distrobox enter hackerwhale
```

📖 **[Guia Completo Distrobox](./DISTROBOX_GUIDE.md)**

#### Opção 2: Docker Hub (Tradicional)

```bash
# Pull da imagem pronta
docker pull gpxlnx/hackerwhale:latest

# Executar
docker run -it --rm \
  --name hackerwhale \
  -v $(pwd)/data:/workdir \
  --cap-add=NET_ADMIN \
  --net=host \
  gpxlnx/hackerwhale:latest zsh
```

#### Opção 3: Build Local (Docker Run)

```bash
# Clone o repositório
git clone https://github.com/gpxlnx/HackerWhale.git
cd HackerWhale

# Build e execute com o helper script
chmod +x hackerwhale.sh
./hackerwhale.sh build
./hackerwhale.sh run
```

#### Opção 4: Docker Compose

```bash
# Com persistência e configurações
docker-compose up -d
docker-compose exec hackerwhale zsh
```

#### Opção 5: Kubernetes

```bash
# Deploy rápido
kubectl apply -f k8s/hackerwhale-k8s.yaml

# Acesso ao pod
kubectl exec -it deployment/hackerwhale -- zsh
```

## 📦 Ferramentas Incluídas

### 🔍 Reconnaissance (20+)
**Passivo**: Subfinder, Amass, Assetfinder, Chaos-client, Github-search  
**Ativo**: Alterx, ShuffleDNS, MassDNS, PureDNS, Dnsx, Dnsgen  
**DNS**: Hakrevdns, DNSValidator

### 🌐 Web Discovery (15+)
**URLs**: Waybackurls, Gau, Gauplus, Haktrails, Unfurl  
**Crawling**: Katana, GoSpider, Hakrawler  
**JS**: Subjs, LinkFinder, JSScanner, JsubFinder

### 🎯 Fuzzing & Brute Force (10+)
**Directories**: ffuf, Dirsearch, TurboSearch  
**APIs**: Kiterunner, Arjun, ParamSpider, X8  
**Parameters**: Arjun, ParamSpider, X8

### 🐛 Vulnerability Scanning (15+)
**Multi-purpose**: Nuclei, Jaeles  
**XSS**: DalFox  
**SQLi**: Sqlmap  
**CRLF**: Crlfuzz  
**SSRF**: Interactsh-client  
**CMS**: WPScan  
**WAF**: wafw00f

### 🌐 Network (10+)
**Port Scan**: Naabu, Masscan, Nmap, arp-scan  
**Service**: Httpx, Httprobe  
**SSL/TLS**: Tlsx, sslscan  
**Info**: Nrich, Uncover

### 🛠️ Utilities (15+)
**Filtering**: Anew, Uro, Qsreplace, Gf  
**CIDR**: Mapcidr, prips  
**Screenshots**: Gowitness  
**Password**: John The Ripper  
**Collaboration**: Notify, Telegram-send  
**Cloud**: Kubectl, K9s  
**Misc**: Metabigor, Collector, Burl, Antiburl, Sub404

### 📚 Wordlists
- **SecLists** - Coleção completa
- **Assetnote** - DNS wordlists otimizadas
- **Jhaddix all.txt** - Mega wordlist

![Tools Map](assets/tools_map.png)

## 📖 Documentação Completa

| Guia | Descrição |
|------|-----------|
| [📘 **Getting Started**](./GETTING_STARTED.md) | **Guia completo: Build → Distrobox → hw** |
| [⚡ Commands Cheatsheet](./COMMANDS_CHEATSHEET.md) | Referência rápida de comandos |
| [🐋 Distrobox Guide](./DISTROBOX_GUIDE.md) | Uso avançado com Distrobox |
| [📂 File Sharing Guide](./FILE_SHARING_GUIDE.md) | Compartilhamento de arquivos host ↔ container |
| [🎓 Bug Hunter Guide](./BUGHUNTER_GUIDE.md) | Workflows práticos e dicas de bug hunting |
| [🚀 Advanced Usage](./ADVANCED_USAGE.md) | VPS, K8s, CI/CD, otimizações |
| [🔑 API Keys Setup](./API_KEYS_TEMPLATE.md) | Configuração de API keys para recon |
| [📊 Project Summary](./PROJECT_SUMMARY.md) | Resumo executivo e arquitetura |

## 💡 Workflows Essenciais

### Reconnaissance Completo
```bash
./hackerwhale.sh recon example.com
```

### Vulnerability Scanning
```bash
./hackerwhale.sh scan targets.txt
```

### Directory Fuzzing
```bash
./hackerwhale.sh fuzz https://example.com
```

### Monitoramento Contínuo
```bash
./hackerwhale.sh monitor example.com
```

## 🛠️ Helper Script

O `hackerwhale.sh` facilita operações comuns:

```bash
./hackerwhale.sh build      # Build da imagem
./hackerwhale.sh run        # Executar interativo
./hackerwhale.sh start      # Executar em background
./hackerwhale.sh shell      # Abrir shell no container
./hackerwhale.sh status     # Verificar status
./hackerwhale.sh stop       # Parar container
./hackerwhale.sh clean      # Limpar tudo
```

## 🎨 Customização

### Adicionar Ferramentas Customizadas

Edite `scripts/expansion_script.sh`:

```bash
MinhaFerramenta(){
    echo -e "${RED}[+]${FUNCNAME[0]}${NC}"
    cd ${TOOLSPATH}
    git clone https://github.com/user/tool.git
    cd tool
    pip install -r requirements.txt
}
```

Adicione na função `callInstallTools()`:
```bash
callInstallTools(){
    # ... outras ferramentas
    MinhaFerramenta
}
```

### Build com Script Remoto

```bash
docker build \
  --build-arg EXPANSION_SCRIPT_URL=https://raw.githubusercontent.com/user/repo/main/custom_script.sh \
  -t hackerwhale:custom .
```

## 🌟 Casos de Uso

### 1. Bug Bounty Local
Rode em seu laptop sem instalar nada permanentemente:
```bash
./hackerwhale.sh run
```

### 2. VPS para Monitoramento 24/7
Deploy em VPS e monitore continuamente:
```bash
# Em VPS
./hackerwhale.sh start
./hackerwhale.sh monitor target.com
```

### 3. Kubernetes para Testes em Escala
Deploy em cluster K8s para paralelização:
```bash
kubectl apply -f k8s/hackerwhale-k8s.yaml
kubectl scale deployment hackerwhale --replicas=10
```

### 4. CI/CD para Segurança Contínua
Integre em pipelines GitHub Actions/GitLab CI:
```yaml
- uses: docker://gpxlnx/hackerwhale:latest
  with:
    args: nuclei -l targets.txt
```

## 📊 Estrutura do Projeto

```
HackerWhale/
├── Dockerfile                    # Imagem base
├── docker-compose.yml            # Compose com serviços extras
├── hackerwhale.sh               # Helper script (build/run/stop)
├── hw                           # Script de acesso rápido (Distrobox)
├── distrobox-setup.sh           # Setup automático Distrobox
├── publish.sh                   # Publicar no Docker Hub
├── update-tools.sh              # Atualizar ferramentas Go
│
├── README.md                    # Introdução e overview
├── GETTING_STARTED.md           # 🔥 Guia completo de instalação
├── DISTROBOX_GUIDE.md           # Uso avançado com Distrobox
├── FILE_SHARING_GUIDE.md        # Compartilhamento de arquivos
├── QUICKSTART.md                # Início rápido
├── BUGHUNTER_GUIDE.md           # Workflows de bug hunting
├── ADVANCED_USAGE.md            # VPS, K8s, CI/CD
├── API_KEYS_TEMPLATE.md         # Setup de API keys
├── AUTOMATION_SCRIPTS.md        # Scripts prontos
├── CHANGELOG_V2.md              # Changelog v2.0
│
├── scripts/
│   ├── expansion_script.sh      # Script de instalação de tools
│   ├── check_and_copy_cert.sh   # Helper para certificados
│   └── tools_mindmap.sh         # Gerador de mapa mental
│
├── k8s/
│   ├── hackerwhale-k8s.yaml     # Deploy K8s
│   ├── hackerwhale-minikube.yaml
│   ├── nginx.yaml               # Exemplos de serviços
│   ├── postgresql.yaml
│   └── rabbitmq.yaml
│
└── assets/
    ├── tools_list.md            # Lista de ferramentas
    ├── tools_map.png            # Mapa visual
    └── tools.dot                # Source do mapa
```

## 🔐 Segurança

### ⚠️ Uso Responsável

Esta ferramenta é para **uso ético** apenas. Certifique-se de ter:
- ✅ Autorização explícita do dono do sistema
- ✅ Escopo bem definido
- ✅ Compliance com leis locais

### 🛡️ Boas Práticas

- Use rate limiting para evitar sobrecarga
- Configure API keys em arquivos separados (não commite!)
- Use proxies em testes sensíveis
- Mantenha logs de auditoria

## 🤝 Contribuindo

Contribuições são bem-vindas! 

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/NovaFerrament`)
3. Commit suas mudanças (`git commit -m 'Add: nova ferramenta'`)
4. Push para a branch (`git push origin feature/NovaFerramenta`)
5. Abra um Pull Request

## 📝 Changelog

### v2.0.0 (2025-01-XX)
- ✨ Adicionadas 10+ novas ferramentas (Katana, Interactsh, Tlsx, etc)
- 📚 Wordlists automáticas (SecLists, Assetnote)
- 🚀 Helper script com workflows prontos
- 📖 Documentação completa e guias práticos
- 🐳 Docker Compose support
- 🔧 Melhorias de performance

### v1.0.0
- 🎉 Release inicial
- 🛠️ 65 ferramentas base
- 📦 Dockerfile otimizado
- ⚓ Suporte Kubernetes

## 📚 Recursos Externos

- **Docker Hub**: https://hub.docker.com/r/gpxlnx/hackerwhale
- **GitHub**: https://github.com/gpxlnx/HackerWhale

## 👨‍💻 Autor

**gpxlnx** ([@gpxlnx](https://github.com/gpxlnx))
- GitHub: https://github.com/gpxlnx

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](./LICENSE) para detalhes.

---

<div align="center">

**⭐ Se este projeto te ajudou, considere dar uma estrela!**

**Happy Hacking! 🚀🔒**

</div>
