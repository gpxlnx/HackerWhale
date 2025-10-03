# 🐋 HackerWhale - Quick Reference

---

## 🚀 Setup em 4 Passos

```bash
# 1. Build
git clone https://github.com/gpxlnx/HackerWhale.git && cd HackerWhale
docker build -t hackerwhale:latest .

# 2. Setup Distrobox
./distrobox-setup.sh
# Escolher: Y (usar imagem local)

# 3. Instalar hw
chmod +x hw && cp hw ~/bin/
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc && source ~/.bashrc

# 4. Pronto!
hw
```

---

## ⚡ Uso Diário

```bash
hw                                    # Entrar
subfinder -d example.com -o subs.txt  # Trabalhar
exit                                  # Sair
cat ~/hackerwhale-workspace/subs.txt  # Ver resultados
```

---

## 📚 Documentação

| O que você quer? | Leia isto |
|------------------|-----------|
| **Começar do zero** | [GETTING_STARTED.md](./GETTING_STARTED.md) |
| **Comandos rápidos** | [COMMANDS_CHEATSHEET.md](./COMMANDS_CHEATSHEET.md) |
| **Workflows práticos** | [BUGHUNTER_GUIDE.md](./BUGHUNTER_GUIDE.md) |
| **Distrobox avançado** | [DISTROBOX_GUIDE.md](./DISTROBOX_GUIDE.md) |
| **Verificar instalação** | [POST_SETUP_CHECKLIST.md](./POST_SETUP_CHECKLIST.md) |

---

## 🛠️ Ferramentas Principais

```bash
# Recon
subfinder, amass, assetfinder, dnsx, httpx

# Web
katana, gospider, waybackurls, gau

# Scan
nuclei, naabu, nmap, masscan

# Fuzz
ffuf, dirsearch, arjun

# Utils
anew, notify, uro, qsreplace
```

---

## 🎯 Workflow Básico

```bash
hw
DOMAIN="example.com"

# 1. Subdomains
subfinder -d $DOMAIN | tee subs.txt

# 2. HTTP probe
httpx -l subs.txt | tee live.txt

# 3. URLs
katana -list live.txt | tee urls.txt

# 4. Scan
nuclei -l urls.txt -severity critical,high | tee vulns.txt

exit
cat ~/hackerwhale-workspace/vulns.txt
```

---

## 🆘 Problemas?

```bash
# Container não funciona?
distrobox rm hackerwhale -f
distrobox create --name hackerwhale --image hackerwhale:latest --yes

# hw não encontrado?
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Ferramentas desatualizadas?
hw
./update-tools.sh
```

---

## 📖 Documentação Completa

- [README.md](./README.md) - Overview completo
- [GETTING_STARTED.md](./GETTING_STARTED.md) - Guia passo a passo
- [COMMANDS_CHEATSHEET.md](./COMMANDS_CHEATSHEET.md) - Referência de comandos
- [POST_SETUP_CHECKLIST.md](./POST_SETUP_CHECKLIST.md) - Verificação pós-instalação

---

**🐋 Happy Hacking! Execute: `hw`**
