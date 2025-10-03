# 📋 HackerWhale - Project Summary

Resumo executivo do projeto HackerWhale.

---

## 🎯 Objetivo

Fornecer uma imagem Docker completa para Bug Hunting e Pentest com **75+ ferramentas** prontas para uso, com foco em:
- **Isolamento** do sistema host
- **Portabilidade** entre ambientes
- **Produtividade** com workflows prontos
- **Zero configuração** para começar

---

## 🏗️ Arquitetura

### Componentes Principais

1. **Dockerfile**
   - Base: `ubuntu:24.04`
   - Pacotes essenciais pré-instalados
   - Expansion script executado no build
   - Shell: `zsh` + `oh-my-zsh`
   - Terminal: `tmux` configurado

2. **Expansion Script** (`scripts/expansion_script.sh`)
   - Instalação de 75+ ferramentas
   - Download de wordlists (SecLists, Assetnote, Jhaddix)
   - Configuração de ambiente Go
   - Limpeza automática

3. **Distrobox Integration**
   - Container como ambiente de desenvolvimento
   - Acesso nativo aos arquivos do host
   - Performance superior a containers tradicionais

4. **Helper Scripts**
   - `hw`: Acesso rápido ao container como root
   - `distrobox-setup.sh`: Setup automático
   - `hackerwhale.sh`: Operações Docker
   - `publish.sh`: Publicação no Docker Hub
   - `update-tools.sh`: Atualização de ferramentas

---

## 📦 Categorias de Ferramentas

### 🔍 Reconnaissance (20+)
Subdomain enumeration, DNS discovery, asset discovery

### 🌐 Web Discovery (15+)
URL crawling, JS analysis, endpoint discovery

### 🎯 Fuzzing & Brute Force (10+)
Directory fuzzing, API fuzzing, parameter discovery

### 🐛 Vulnerability Scanning (15+)
Multi-purpose scanners, XSS, SQLi, CRLF, SSRF

### 🌐 Network (10+)
Port scanning, service detection, SSL/TLS analysis

### 🛠️ Utilities (15+)
Filtering, CIDR operations, screenshots, collaboration

### 📚 Wordlists
SecLists, Assetnote, Jhaddix all.txt

---

## 🚀 Métodos de Uso

### 1. Build Local + Distrobox + `hw` (Recomendado)
```bash
docker build -t hackerwhale:latest .
./distrobox-setup.sh
cp hw ~/bin/
hw  # Pronto!
```

**Vantagens:**
- ✅ Customização total
- ✅ Performance máxima
- ✅ Acesso nativo aos arquivos
- ✅ Integração perfeita com host

### 2. Docker Hub + Distrobox
```bash
distrobox create --name hackerwhale --image gpxlnx/hackerwhale:latest --yes
distrobox enter hackerwhale
```

**Vantagens:**
- ✅ Sem build necessário
- ✅ Sempre atualizado
- ✅ Setup rápido

### 3. Docker Run (Tradicional)
```bash
docker pull gpxlnx/hackerwhale:latest
docker run -it --rm hackerwhale:latest zsh
```

**Vantagens:**
- ✅ Sem dependências extras
- ✅ Portável
- ✅ Descartável

### 4. Kubernetes
```bash
kubectl apply -f k8s/hackerwhale-k8s.yaml
```

**Vantagens:**
- ✅ Escala horizontal
- ✅ Alta disponibilidade
- ✅ Automação CI/CD

---

## 📁 Estrutura de Arquivos

```
HackerWhale/
├── Core
│   ├── Dockerfile                 # Build da imagem
│   ├── docker-compose.yml         # Compose setup
│   └── scripts/expansion_script.sh # Instalação de tools
│
├── Scripts
│   ├── hw                         # Acesso rápido (Distrobox)
│   ├── distrobox-setup.sh         # Setup automático
│   ├── hackerwhale.sh             # Helper Docker
│   ├── publish.sh                 # Publish Docker Hub
│   └── update-tools.sh            # Update ferramentas
│
├── Documentação
│   ├── README.md                  # Overview
│   ├── GETTING_STARTED.md         # 🔥 Guia principal
│   ├── DISTROBOX_GUIDE.md         # Distrobox avançado
│   ├── FILE_SHARING_GUIDE.md      # Compartilhamento
│   ├── BUGHUNTER_GUIDE.md         # Workflows
│   ├── ADVANCED_USAGE.md          # VPS, K8s, CI/CD
│   └── API_KEYS_TEMPLATE.md       # Setup API keys
│
└── Deploy
    ├── k8s/                       # Manifests Kubernetes
    └── assets/                    # Imagens e docs
```

---

## 🔄 Workflow Típico

### Bug Hunting Local

```bash
# 1. Entrar no container
hw

# 2. Recon
subfinder -d example.com | tee subs.txt
httpx -l subs.txt | tee live.txt
katana -u live.txt | tee urls.txt

# 3. Vulnerability scan
nuclei -l live.txt -severity critical,high

# 4. Fuzzing
ffuf -u https://example.com/FUZZ -w /wordlists/SecLists/Discovery/Web-Content/common.txt

# 5. Sair
exit

# 6. Ver resultados no host
cat ~/hackerwhale-workspace/*.txt
```

---

## 🎓 Casos de Uso

### 1. Bug Bounty Local
Ambiente isolado sem sujar o sistema host

### 2. VPS para Monitoramento 24/7
Deploy em servidor e monitorar continuamente

### 3. Kubernetes para Escala
Paralelizar testes em múltiplos targets

### 4. CI/CD para Segurança Contínua
Integrar em pipelines de desenvolvimento

### 5. Treinamento e Educação
Ambiente padronizado para cursos e labs

---

## 🔐 Segurança e Compliance

### ⚠️ Uso Responsável
- ✅ Autorização explícita necessária
- ✅ Respeitar escopo definido
- ✅ Compliance com leis locais
- ✅ Rate limiting para evitar sobrecarga

### 🛡️ Boas Práticas
- Configurar API keys separadamente
- Usar proxies quando necessário
- Manter logs de auditoria
- Não commitar credenciais

---

## 📊 Métricas

### Imagem Docker
- **Base:** Ubuntu 24.04
- **Tamanho:** ~3-4GB (após build)
- **Build time:** 20-30 minutos
- **Ferramentas:** 75+
- **Wordlists:** ~15GB (SecLists + Assetnote + Jhaddix)

### Performance
- **Startup:** < 5 segundos (Distrobox)
- **RAM:** 512MB-2GB (dependendo do uso)
- **CPU:** Multi-core support

---

## 🔄 Ciclo de Atualização

### Imagem
1. Update `expansion_script.sh` com novas ferramentas
2. Build local: `docker build -t hackerwhale:latest .`
3. Test: `hw`
4. Publish: `./publish.sh`

### Ferramentas (dentro do container)
```bash
hw
./update-tools.sh
# ou
go install -v github.com/projectdiscovery/tool@latest
```

---

## 📚 Documentação

### Essencial (Ordem de leitura)
1. **README.md** - Overview e quick start
2. **GETTING_STARTED.md** - Setup completo passo a passo
3. **DISTROBOX_GUIDE.md** - Uso avançado Distrobox
4. **BUGHUNTER_GUIDE.md** - Workflows práticos

### Referência
- **FILE_SHARING_GUIDE.md** - Compartilhamento avançado
- **ADVANCED_USAGE.md** - VPS, K8s, CI/CD
- **API_KEYS_TEMPLATE.md** - Configuração API keys
- **AUTOMATION_SCRIPTS.md** - Scripts prontos

---

## 🎯 Roadmap Futuro

### v2.1 (Próximo)
- [ ] Adicionar mais 10 ferramentas
- [ ] Suporte a ARM64
- [ ] GitHub Actions workflows
- [ ] Templates de recon prontos

### v3.0 (Futuro)
- [ ] Web UI para gerenciamento
- [ ] Database integrada (PostgreSQL)
- [ ] API REST para automação
- [ ] Dashboard de resultados

---

## 🤝 Contribuindo

### Como Adicionar Ferramentas

1. Editar `scripts/expansion_script.sh`
2. Adicionar função de instalação
3. Adicionar na `callInstallTools()`
4. Test build
5. Update documentação
6. Pull request

### Estrutura de Função
```bash
MinhaFerramenta(){
    echo -e "${RED}[+]${FUNCNAME[0]}${NC}"
    cd ${TOOLSPATH}
    git clone https://github.com/user/tool.git
    cd tool
    go build -o /usr/local/bin/tool
}
```

---

## 📄 Licença

MIT License - Uso livre com atribuição

---

## 👨‍💻 Autor

**gpxlnx** ([@gpxlnx](https://github.com/gpxlnx))

---

## 🔗 Links

- **GitHub:** https://github.com/gpxlnx/HackerWhale
- **Docker Hub:** https://hub.docker.com/r/gpxlnx/hackerwhale
- **Issues:** https://github.com/gpxlnx/HackerWhale/issues

---

**🐋 Happy Hacking!**

