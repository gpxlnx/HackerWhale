#!/bin/bash
# Update HackerWhale Tools Script
# Updates Go-based tools to latest versions

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[+] Updating HackerWhale Tools...${NC}\n"

# Go tools to update
GO_TOOLS=(
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    "github.com/projectdiscovery/katana/cmd/katana@latest"
    "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    "github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
    "github.com/projectdiscovery/alterx/cmd/alterx@latest"
    "github.com/projectdiscovery/chaos-client/cmd/chaos@latest"
    "github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"
    "github.com/projectdiscovery/notify/cmd/notify@latest"
    "github.com/projectdiscovery/uncover/cmd/uncover@latest"
    "github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
    "github.com/owasp-amass/amass/v4/...@master"
    "github.com/tomnomnom/anew@latest"
    "github.com/tomnomnom/assetfinder@latest"
    "github.com/tomnomnom/httprobe@latest"
    "github.com/tomnomnom/waybackurls@latest"
    "github.com/tomnomnom/unfurl@latest"
    "github.com/tomnomnom/qsreplace@latest"
    "github.com/ffuf/ffuf@latest"
    "github.com/lc/gau/v2/cmd/gau@latest"
    "github.com/jaeles-project/gospider@latest"
    "github.com/hakluke/hakrawler@latest"
    "github.com/sensepost/gowitness@latest"
)

total=${#GO_TOOLS[@]}
current=0

for tool in "${GO_TOOLS[@]}"; do
    current=$((current + 1))
    tool_name=$(echo $tool | awk -F'/' '{print $NF}' | cut -d'@' -f1)
    
    echo -e "${YELLOW}[$current/$total]${NC} Updating ${GREEN}$tool_name${NC}..."
    
    if go install -v $tool 2>/dev/null; then
        echo -e "${GREEN}[✓] $tool_name updated${NC}"
    else
        echo -e "${RED}[!] Failed to update $tool_name${NC}"
    fi
    echo ""
done

# Update nuclei templates
echo -e "${BLUE}[+] Updating Nuclei templates...${NC}"
nuclei -update-templates -silent 2>/dev/null || nuclei -ut -silent 2>/dev/null
echo -e "${GREEN}[✓] Nuclei templates updated${NC}"

echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Tools Update Complete! 🎉         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"

# Show versions
echo -e "${BLUE}Current versions:${NC}"
echo -e "  subfinder: ${GREEN}$(subfinder -version 2>&1 | grep -oP 'v[\d.]+' | head -1)${NC}"
echo -e "  httpx:     ${GREEN}$(httpx -version 2>&1 | grep -oP 'v[\d.]+' | head -1)${NC}"
echo -e "  nuclei:    ${GREEN}$(nuclei -version 2>&1 | grep -oP 'v[\d.]+' | head -1)${NC}"
echo ""

