# 📂 Compartilhamento de Arquivos - HackerWhale

Guia completo sobre como compartilhar arquivos entre o host e o container HackerWhale.

---

## 🎯 Como Funciona Agora

### Diretório Compartilhado Automático

Quando você usa `hw`, o script cria automaticamente:

**No Host:**
```
~/hackerwhale-workspace/
```

**No Container (como root):**
```
/root/workspace/ -> link para ~/hackerwhale-workspace
```

---

## 🚀 Uso Prático

### 1. Entrar e Trabalhar

```bash
# No host
hw

# Você está em /root/workspace (que é o mesmo que ~/hackerwhale-workspace do host!)
pwd
# Output: /root/workspace

# Criar arquivos
echo "teste" > arquivo.txt

# Sair
exit

# No host, verificar
cat ~/hackerwhale-workspace/arquivo.txt
# Output: teste
```

### 2. Preparar Scan no Host, Executar no Container

```bash
# No host: criar lista de alvos
mkdir -p ~/hackerwhale-workspace/recon
echo "example.com" > ~/hackerwhale-workspace/recon/targets.txt
echo "test.com" >> ~/hackerwhale-workspace/recon/targets.txt

# Entrar no container
hw

# No container (já está em /root/workspace)
cd recon
subfinder -dL targets.txt -o subs.txt
httpx -l subs.txt -o live.txt

# Sair
exit

# No host: ver resultados
cat ~/hackerwhale-workspace/recon/live.txt
```

### 3. Executar Comando Direto

```bash
# Do host, executar comando no container
hw run "cd /root/workspace && subfinder -d example.com -o subs.txt"

# Ver resultado no host
cat ~/hackerwhale-workspace/subs.txt
```

---

## 📁 Estrutura Recomendada

Organize seus projetos assim:

```bash
~/hackerwhale-workspace/
├── recon/
│   ├── client1/
│   │   ├── subs.txt
│   │   ├── live.txt
│   │   └── vulns.txt
│   ├── client2/
│   └── targets.txt
├── wordlists/
│   ├── custom-subdomains.txt
│   └── api-endpoints.txt
├── scripts/
│   └── my-recon.sh
└── reports/
    └── findings.md
```

---

## 🔄 Múltiplas Opções de Compartilhamento

### Opção 1: Workspace Compartilhado (Padrão)

```bash
# Script hw já configura automaticamente
hw

# Trabalhar em:
cd /root/workspace  # = ~/hackerwhale-workspace no host
```

### Opção 2: Acessar Todo o HOME do Host

```bash
# O Distrobox já monta seu HOME automaticamente
hw

# No container, acessar:
cd /home/gxavier/Documents/projetos
ls -la
```

### Opção 3: Diretórios Específicos

```bash
# Criar links simbólicos
hw run "ln -s /home/\$USER/Documents /root/docs"
hw run "ln -s /home/\$USER/Downloads /root/downloads"

# Usar:
hw
cd /root/docs
ls -la
```

### Opção 4: Volumes Adicionais

```bash
# Recriar container com volume extra
distrobox rm hackerwhale -f

distrobox create \
  --name hackerwhale \
  --image hackerwhale:latest \
  --volume /mnt/externo:/root/externo:rw \
  --yes

# Depois usar normalmente:
hw
cd /root/externo
```

---

## 💡 Exemplos de Workflows

### Workflow 1: Recon de Múltiplos Domínios

```bash
# No host: preparar lista
cat > ~/hackerwhale-workspace/domains.txt << EOF
example.com
test.com
demo.com
EOF

# Executar recon para todos
hw run "cd /root/workspace && \
  cat domains.txt | while read domain; do \
    mkdir -p \$domain && \
    cd \$domain && \
    subfinder -d \$domain | tee subs.txt && \
    httpx -l subs.txt | tee live.txt && \
    cd ..; \
  done"

# No host: ver resultados
tree ~/hackerwhale-workspace/
```

### Workflow 2: Usar Scripts Customizados

```bash
# No host: criar script
cat > ~/hackerwhale-workspace/my-recon.sh << 'EOF'
#!/bin/bash
DOMAIN=$1
mkdir -p /root/workspace/recon/$DOMAIN
cd /root/workspace/recon/$DOMAIN

echo "[+] Subdomain enumeration..."
subfinder -d $DOMAIN | anew subs.txt

echo "[+] HTTP probing..."
httpx -l subs.txt | anew live.txt

echo "[+] Vulnerability scan..."
nuclei -l live.txt -severity critical,high -o vulns.txt

echo "[✓] Done! Results in /root/workspace/recon/$DOMAIN/"
EOF

chmod +x ~/hackerwhale-workspace/my-recon.sh

# Executar no container
hw run "bash /root/workspace/my-recon.sh example.com"

# Ver resultados no host
cat ~/hackerwhale-workspace/recon/example.com/vulns.txt
```

### Workflow 3: Monitoramento Contínuo

```bash
# No host: criar script de monitoramento
cat > ~/hackerwhale-workspace/monitor.sh << 'EOF'
#!/bin/bash
DOMAIN=$1
INTERVAL=${2:-3600}

while true; do
  echo "[$(date)] Checking $DOMAIN..."
  
  # Buscar novos subdomínios
  subfinder -d $DOMAIN -silent | anew /root/workspace/monitor/$DOMAIN-subs.txt
  
  # Notificar se houver novos
  NEW=$(tail -1 /root/workspace/monitor/$DOMAIN-subs.txt)
  if [ ! -z "$NEW" ]; then
    echo "[!] New subdomain found: $NEW"
  fi
  
  sleep $INTERVAL
done
EOF

# Executar em background
hw run "mkdir -p /root/workspace/monitor && \
  nohup bash /root/workspace/monitor.sh example.com > /root/workspace/monitor/monitor.log 2>&1 &"

# Acompanhar logs no host
tail -f ~/hackerwhale-workspace/monitor/monitor.log
```

---

## 🛠️ Troubleshooting

### Problema: Arquivos não aparecem

```bash
# Verificar se o link existe
hw run "ls -la /root/workspace"

# Recriar link manualmente
hw run "ln -sfn /home/\$USER/hackerwhale-workspace /root/workspace"
```

### Problema: Permissões negadas

```bash
# Ajustar permissões no host
chmod -R 755 ~/hackerwhale-workspace

# Ou trabalhar como root também no host
sudo chown -R $(whoami):$(whoami) ~/hackerwhale-workspace
```

### Problema: Espaço em disco

```bash
# Ver uso de espaço
du -sh ~/hackerwhale-workspace/

# Limpar arquivos antigos
hw run "cd /root/workspace && find . -name '*.txt' -mtime +30 -delete"
```

---

## 📊 Comparação de Métodos

| Método | Localização Host | Localização Container | Facilidade | Uso |
|--------|------------------|----------------------|------------|-----|
| **Workspace** | `~/hackerwhale-workspace` | `/root/workspace` | ⭐⭐⭐⭐⭐ | Recomendado |
| **HOME direto** | `~/Documents` | `/home/gxavier/Documents` | ⭐⭐⭐⭐ | Arquivos pessoais |
| **Links manuais** | Qualquer | `/root/custom` | ⭐⭐⭐ | Casos específicos |
| **Volumes extras** | `/mnt/externo` | `/root/externo` | ⭐⭐ | Discos externos |

---

## 🎯 Comandos Úteis

```bash
# Ver o que está compartilhado
hw run "df -h | grep home"

# Criar backup
tar -czf backup-workspace-$(date +%Y%m%d).tar.gz ~/hackerwhale-workspace/

# Sincronizar com outro lugar
rsync -av ~/hackerwhale-workspace/ /mnt/backup/

# Limpar workspace
rm -rf ~/hackerwhale-workspace/*

# Ver tamanho
du -sh ~/hackerwhale-workspace/
```

---

## 📝 Dicas Importantes

1. **Sempre trabalhe em `/root/workspace`** dentro do container para garantir compartilhamento
2. **Use paths relativos** nos scripts para portabilidade
3. **Faça backup** dos resultados importantes regularmente
4. **Organize por projeto** para facilitar gerenciamento
5. **Documente** seus scans e resultados

---

## 🔐 Segurança

### Boas Práticas:

```bash
# Não deixe credenciais no workspace compartilhado
# Use variáveis de ambiente ou arquivos em /root/.config/

# No container:
hw run "mkdir -p /root/.secrets && chmod 700 /root/.secrets"
hw run "echo 'MY_API_KEY=xxx' > /root/.secrets/keys"

# Usar nos scripts:
hw run "source /root/.secrets/keys && subfinder -d example.com"
```

---

## 🎉 Quick Reference

```bash
# Estrutura básica
~/hackerwhale-workspace/          # No host
    └── [arquivos]
                                   
/root/workspace/                   # No container (root)
    └── [mesmos arquivos]

# Comandos rápidos
hw                                 # Entrar (vai para /root/workspace)
hw run "ls /root/workspace"        # Listar arquivos
cat ~/hackerwhale-workspace/file   # Ver no host
```

---

**🐋 Agora seus arquivos estão compartilhados automaticamente!**

Execute: `hw` e trabalhe em `/root/workspace/`

