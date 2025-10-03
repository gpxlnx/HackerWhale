# ✅ Post-Setup Checklist

Lista de verificação após instalação do HackerWhale.

---

## 🔍 Verificar Instalação

### 1. Docker/Podman
```bash
docker --version
# ou
podman --version

# Listar imagem
docker images | grep hackerwhale
```
**Esperado:** `hackerwhale latest` deve aparecer

---

### 2. Distrobox
```bash
distrobox --version

# Listar containers
distrobox list
```
**Esperado:** Container `hackerwhale` deve existir

---

### 3. Script hw
```bash
which hw

hw --help
```
**Esperado:** Script encontrado em `~/bin/hw`

---

### 4. Workspace
```bash
ls -la ~/hackerwhale-workspace/
```
**Esperado:** Diretório existe

---

## ✅ Teste Básico

### Entrar no Container
```bash
hw
```
**Esperado:** 
- Prompt muda para container
- Você está como root
- PWD é `/root/workspace`

---

### Testar Ferramentas
```bash
# Dentro do container (via hw)

# Reconnaissance
subfinder -version
amass -version

# Web Discovery
httpx -version
katana -version

# Vulnerability Scanning
nuclei -version

# Network
naabu -version

# Utilities
anew -version
```
**Esperado:** Todas as ferramentas respondem com versão

---

### Testar Workspace Compartilhado
```bash
# Dentro do container
echo "teste" > /root/workspace/teste.txt
exit

# No host
cat ~/hackerwhale-workspace/teste.txt
```
**Esperado:** Arquivo `teste.txt` aparece no host com conteúdo "teste"

---

## 🎯 Teste Completo de Workflow

```bash
hw

# Criar estrutura
mkdir -p /root/workspace/test
cd /root/workspace/test

# Subdomain enumeration
subfinder -d example.com -silent | tee subs.txt

# HTTP probing
httpx -l subs.txt -silent | tee live.txt

# Vulnerability scan
nuclei -l live.txt -severity critical,high -silent | tee vulns.txt

# Sair
exit

# Verificar resultados no host
ls -la ~/hackerwhale-workspace/test/
cat ~/hackerwhale-workspace/test/subs.txt
```
**Esperado:** 
- Arquivos criados
- Subdomínios encontrados
- Hosts vivos identificados

---

## 🔧 Verificar Configurações

### Go Environment
```bash
hw run "go version"
hw run "echo \$GOPATH"
hw run "ls -la \$GOPATH/bin | head -20"
```
**Esperado:** 
- Go instalado
- GOPATH configurado
- Binários Go no PATH

---

### Wordlists
```bash
hw run "ls -la /wordlists/"
hw run "ls -la /wordlists/SecLists/ | head -10"
```
**Esperado:** 
- Diretório `/wordlists/` existe
- SecLists instaladas
- Assetnote instaladas

---

### Nuclei Templates
```bash
hw run "nuclei -tl | head -20"
```
**Esperado:** Lista de templates do Nuclei

---

## 📊 Performance Check

### Startup Time
```bash
time hw run "echo 'test'"
```
**Esperado:** < 3 segundos

---

### Resource Usage
```bash
# No host
docker stats hackerwhale --no-stream
```
**Esperado:** Uso razoável de CPU/RAM

---

## 🐛 Troubleshooting

### Se algo não funcionar:

#### Container não inicia
```bash
distrobox list
docker ps -a

# Recriar
distrobox rm hackerwhale -f
distrobox create --name hackerwhale --image hackerwhale:latest --yes
```

#### Ferramenta não encontrada
```bash
hw run "which subfinder"
hw run "echo \$PATH"

# Reinstalar
hw
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```

#### Workspace não compartilha
```bash
hw run "ls -la /root/workspace"
hw run "ln -sfn /home/\$USER/hackerwhale-workspace /root/workspace"
```

#### Script hw não funciona
```bash
echo $PATH | grep bin
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

---

## ✅ Checklist Final

- [ ] Docker/Podman instalado e funcionando
- [ ] Imagem `hackerwhale:latest` existe
- [ ] Distrobox instalado e funcionando
- [ ] Container `hackerwhale` criado
- [ ] Script `hw` instalado em ~/bin/
- [ ] `hw` funciona e entra no container como root
- [ ] Workspace ~/hackerwhale-workspace/ existe
- [ ] Arquivos compartilham entre host e container
- [ ] Ferramentas principais funcionando (subfinder, nuclei, httpx)
- [ ] Go environment configurado
- [ ] Wordlists instaladas
- [ ] Workflow de teste executado com sucesso

---

## 🎉 Tudo OK?

Se todos os itens estão ✅, você está pronto para começar!

```bash
hw
# Happy Hacking! 🚀🔒
```

---

## 📚 Próximos Passos

1. Ler [BUGHUNTER_GUIDE.md](./BUGHUNTER_GUIDE.md) para workflows práticos
2. Consultar [COMMANDS_CHEATSHEET.md](./COMMANDS_CHEATSHEET.md) como referência
3. Configurar API keys: [API_KEYS_TEMPLATE.md](./API_KEYS_TEMPLATE.md)
4. Explorar [AUTOMATION_SCRIPTS.md](./AUTOMATION_SCRIPTS.md) para scripts prontos

---

**🐋 HackerWhale está pronto para uso!**
