# 🚀 HackerWhale - Uso Avançado

## 🎯 Cenários de Uso

### 1. 🖥️ Uso Local (Laptop/Desktop)

**Vantagens**: Controle total, sem custos
**Desvantagens**: Limitado por recursos locais

```bash
# Build e execução básica
./hackerwhale.sh build
./hackerwhale.sh run

# Com Docker Compose (inclui persistência)
docker-compose up -d
docker-compose exec hackerwhale zsh
```

**Dica**: Use volumes para persistir dados e histórico
```bash
docker run -it --rm \
  -v $(pwd)/data:/workdir \
  -v $(pwd)/.zsh_history:/root/.zsh_history_docker \
  hackerwhale:latest
```

---

### 2. ☁️ Uso em VPS (Cloud)

**Vantagens**: Sempre online, IP diferente, bandwidth ilimitado
**Desvantagens**: Custo mensal, gerenciamento

#### Setup em VPS (Ubuntu/Debian)

```bash
# 1. Instalar Docker
curl -fsSL https://get.docker.com | sh

# 2. Clone o repositório
git clone https://github.com/gpxlnx/HackerWhale.git
cd HackerWhale

# 3. Build
./hackerwhale.sh build

# 4. Executar em background
./hackerwhale.sh start

# 5. Acesso via tmux (para manter sessões)
docker exec -it hackerwhale zsh
```

#### Monitoramento Contínuo em VPS

```bash
# Script de monitoramento automático
cat > monitor-continuous.sh << 'EOF'
#!/bin/bash
DOMAIN=$1
NOTIFY_CONFIG="~/.config/notify/provider-config.yaml"

while true; do
  # Novos subdomínios
  subfinder -d $DOMAIN -silent | anew subs.txt | notify -silent
  
  # Novas URLs do Wayback
  waybackurls $DOMAIN | anew urls.txt | notify -silent
  
  # Aguardar 1 hora
  sleep 3600
done
EOF

chmod +x monitor-continuous.sh
nohup ./monitor-continuous.sh example.com &
```

#### Recomendações de Providers

| Provider | Custo/mês | RAM | vCPU | Banda | Nota |
|----------|-----------|-----|------|-------|------|
| DigitalOcean | $6 | 1GB | 1 | 1TB | Bom custo-benefício |
| Vultr | $6 | 1GB | 1 | 2TB | Mais localizações |
| Hetzner | €4.5 | 2GB | 1 | 20TB | Melhor performance |
| AWS Lightsail | $5 | 1GB | 1 | 2TB | Integração AWS |
| Linode | $5 | 1GB | 1 | 1TB | Confiável |

---

### 3. ⚓ Uso em Kubernetes

**Vantagens**: Escalabilidade, orquestração, resiliência
**Desvantagens**: Complexidade, overhead

#### Deploy Simples

```bash
# Apply manifests
kubectl apply -f k8s/hackerwhale-k8s.yaml

# Acesso ao pod
kubectl exec -it deployment/hackerwhale -- zsh

# Port forward para acesso local
kubectl port-forward deployment/hackerwhale 8080:80
```

#### Deploy com Helm (criar Chart)

```yaml
# values.yaml
replicaCount: 1

image:
  repository: gpxlnx/hackerwhale
  tag: latest
  pullPolicy: Always

persistence:
  enabled: true
  size: 10Gi
  storageClass: standard

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi

env:
  - name: SHODAN_KEY
    valueFrom:
      secretKeyRef:
        name: api-keys
        key: shodan

nodeSelector:
  workload: security-testing
```

#### Jobs Paralelos em K8s

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: recon-job
spec:
  parallelism: 5
  completions: 100
  template:
    spec:
      containers:
      - name: hackerwhale
        image: gpxlnx/hackerwhale:latest
        command:
        - /bin/bash
        - -c
        - |
          DOMAIN=$(cat /targets/list.txt | sed -n "${JOB_COMPLETION_INDEX}p")
          subfinder -d $DOMAIN -o /results/$DOMAIN-subs.txt
          httpx -l /results/$DOMAIN-subs.txt -o /results/$DOMAIN-live.txt
      volumes:
      - name: targets
        configMap:
          name: target-list
      - name: results
        persistentVolumeClaim:
          claimName: recon-results
      restartPolicy: OnFailure
```

---

### 4. 🔄 CI/CD Pipeline

**Vantagens**: Automação, integração com workflows
**Desvantagens**: Tempo limitado de execução

#### GitHub Actions

```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on:
  schedule:
    - cron: '0 */6 * * *'  # A cada 6 horas
  workflow_dispatch:

jobs:
  recon:
    runs-on: ubuntu-latest
    container:
      image: gpxlnx/hackerwhale:latest
    
    steps:
      - name: Subdomain Enumeration
        run: |
          subfinder -d ${{ secrets.TARGET_DOMAIN }} -o subs.txt
        env:
          SHODAN_KEY: ${{ secrets.SHODAN_KEY }}
      
      - name: Live Probe
        run: httpx -l subs.txt -o live.txt
      
      - name: Vulnerability Scan
        run: |
          nuclei -l live.txt -severity critical,high \
            -o nuclei-results.txt
      
      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: scan-results
          path: |
            subs.txt
            live.txt
            nuclei-results.txt
      
      - name: Notify
        if: failure()
        run: |
          notify -data nuclei-results.txt
        env:
          TELEGRAM_TOKEN: ${{ secrets.TELEGRAM_TOKEN }}
```

#### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - recon
  - scan
  - report

variables:
  TARGET: "example.com"

recon:
  stage: recon
  image: gpxlnx/hackerwhale:latest
  script:
    - subfinder -d $TARGET -o subs.txt
    - httpx -l subs.txt -o live.txt
  artifacts:
    paths:
      - subs.txt
      - live.txt

scan:
  stage: scan
  image: gpxlnx/hackerwhale:latest
  script:
    - nuclei -l live.txt -severity critical,high -o results.txt
  artifacts:
    paths:
      - results.txt
  dependencies:
    - recon

report:
  stage: report
  image: gpxlnx/hackerwhale:latest
  script:
    - cat results.txt | notify
  dependencies:
    - scan
  only:
    - schedules
```

---

## 🎨 Otimizações de Performance

### 1. Reduzir Tamanho da Imagem

```dockerfile
# Multi-stage build
FROM golang:1.21-alpine AS go-builder
RUN go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
RUN go install github.com/projectdiscovery/httpx/cmd/httpx@latest

FROM ubuntu:24.04
COPY --from=go-builder /go/bin/* /usr/local/bin/
# ... resto da configuração
```

**Resultado**: De ~4GB para ~2GB

### 2. Build Cache Otimizado

```dockerfile
# Cache layers eficientemente
FROM ubuntu:24.04

# Layer 1: Pacotes do sistema (muda raramente)
RUN apt-get update && apt-get install -y \
    curl wget git ... \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Ferramentas Go (muda ocasionalmente)
RUN go install github.com/...

# Layer 3: Ferramentas Python (muda frequentemente)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Layer 4: Scripts customizados (muda muito)
COPY scripts/ /opt/scripts/
```

### 3. Parallel Installation

Modifique `expansion_script.sh`:

```bash
callInstallTools(){
    # Instalar ferramentas Go em paralelo
    (
        go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &
        go install github.com/projectdiscovery/httpx/cmd/httpx@latest &
        go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest &
        wait
    )
    
    # Instalar ferramentas Python em paralelo
    (
        $PIPCOMMAND dirsearch &
        $PIPCOMMAND arjun &
        $PIPCOMMAND sqlmap &
        wait
    )
}
```

---

## 🛡️ Segurança e OPSEC

### 1. Usar Proxies

```bash
# SOCKS5 Proxy
export HTTP_PROXY=socks5://127.0.0.1:1080
export HTTPS_PROXY=socks5://127.0.0.1:1080

# Com Tor
docker run -d --name tor-proxy dperson/torproxy
export HTTP_PROXY=socks5://tor-proxy:9050

# Verificar IP
curl -x socks5://tor-proxy:9050 https://ifconfig.me
```

### 2. Rate Limiting Global

```bash
# ~/.zshrc
export RATE_LIMIT=100
export MAX_THREADS=10

alias subfinder='subfinder -rate-limit $RATE_LIMIT'
alias nuclei='nuclei -rate-limit $RATE_LIMIT -c $MAX_THREADS'
alias httpx='httpx -threads $MAX_THREADS'
```

### 3. Rotate User Agents

```bash
# user-agents.txt
cat > /opt/wordlists/user-agents.txt << EOF
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36
Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36
EOF

# Usar com ferramentas
httpx -l targets.txt -random-agent
```

### 4. Logs e Auditoria

```bash
# Habilitar logging detalhado
export HISTFILE=/workdir/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000

# Timestamped commands
setopt EXTENDED_HISTORY

# Log todas as requisições
alias nuclei='nuclei -stats -json -o nuclei.log'
```

---

## 📊 Monitoramento e Métricas

### 1. Prometheus + Grafana

```yaml
# docker-compose.override.yml
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
  
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

### 2. Metrics Export

```bash
# Exportar métricas de scans
cat > export-metrics.sh << 'EOF'
#!/bin/bash
echo "# HELP scan_domains_found Total domains found"
echo "# TYPE scan_domains_found counter"
echo "scan_domains_found $(cat subs.txt | wc -l)"

echo "# HELP scan_live_hosts Total live hosts"
echo "# TYPE scan_live_hosts counter"
echo "scan_live_hosts $(cat live.txt | wc -l)"

echo "# HELP scan_vulnerabilities Total vulnerabilities"
echo "# TYPE scan_vulnerabilities counter"
echo "scan_vulnerabilities $(cat nuclei.txt | wc -l)"
EOF
```

---

## 🔧 Troubleshooting

### Problema: Container consome muita RAM

**Solução**: Limitar recursos

```bash
docker run --memory="2g" --cpus="2" hackerwhale:latest
```

### Problema: DNS resolution falha

**Solução**: Usar DNS público

```bash
docker run --dns 8.8.8.8 --dns 1.1.1.1 hackerwhale:latest
```

### Problema: Timeout em scans

**Solução**: Ajustar timeout global

```bash
export TIMEOUT=60
nuclei -l targets.txt -timeout $TIMEOUT
httpx -l targets.txt -timeout $TIMEOUT
```

### Problema: Ferramentas Go não encontradas

**Solução**: Verificar PATH

```bash
export PATH=$PATH:/root/go/bin
echo 'export PATH=$PATH:/root/go/bin' >> ~/.zshrc
```

---

## 📚 Recursos Adicionais

### Scripts Úteis

```bash
# Quick recon one-liner
echo "target.com" | subfinder -silent | httpx -silent | nuclei -silent

# Full pipeline
cat domains.txt | \
  subfinder -silent | \
  anew subs.txt | \
  httpx -silent | \
  anew live.txt | \
  nuclei -silent | \
  notify

# Mass scan
cat program-domains.txt | \
  parallel -j 10 "subfinder -d {} | httpx | nuclei"
```

### Templates de Automação

Veja `/opt/scripts/` no container para mais exemplos.

---

## 🆘 Suporte

- Issues: https://github.com/gpxlnx/HackerWhale/issues
- GitHub: https://github.com/gpxlnx

---

**Happy Hunting! 🎯**

