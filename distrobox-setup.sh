#!/bin/bash
# HackerWhale Distrobox Setup Script
# Quick setup for using HackerWhale with Distrobox

set -e

VERSION="1.0.0"
IMAGE_REMOTE="gpxlnx/hackerwhale:latest"
IMAGE_LOCAL="hackerwhale:latest"
CONTAINER_NAME="hackerwhale"
USE_LOCAL=${USE_LOCAL:-false}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
banner() {
    echo -e "${BLUE}"
    cat << "EOF"
    _   _            _             __        ___           _      
   | | | | __ _  ___| | _____ _ __\ \      / / |__   __ _| | ___ 
   | |_| |/ _` |/ __| |/ / _ \ '__\ \ /\ / /| '_ \ / _` | |/ _ \
   |  _  | (_| | (__|   <  __/ |   \ V  V / | | | | (_| | |  __/
   |_| |_|\__,_|\___|_|\_\___|_|    \_/\_/  |_| |_|\__,_|_|\___|
                                                                  
EOF
    echo -e "   ${GREEN}Distrobox Setup v${VERSION}${NC}"
    echo -e "   ${YELLOW}by @gpxlnx${NC}\n"
}

# Check if distrobox is installed
check_distrobox() {
    if ! command -v distrobox &> /dev/null; then
        echo -e "${YELLOW}[!] Distrobox not found. Installing...${NC}"
        install_distrobox
    else
        echo -e "${GREEN}[✓] Distrobox found: $(distrobox version)${NC}"
    fi
}

# Install distrobox
install_distrobox() {
    echo -e "${BLUE}[+] Installing Distrobox...${NC}"
    
    # Ask for installation method
    echo -e "\n${YELLOW}Choose installation method:${NC}"
    echo "1. System-wide (requires sudo)"
    echo "2. Local (~/.local, no sudo)"
    read -p "Enter choice [1-2]: " choice
    
    case $choice in
        1)
            curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
            ;;
        2)
            curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
            echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
            echo 'export PATH=$PATH:~/.local/bin' >> ~/.zshrc 2>/dev/null || true
            export PATH=$PATH:~/.local/bin
            ;;
        *)
            echo -e "${RED}[!] Invalid choice${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}[✓] Distrobox installed successfully!${NC}"
}

# Check for container manager
check_container_manager() {
    if command -v podman &> /dev/null; then
        echo -e "${GREEN}[✓] Podman found${NC}"
        CONTAINER_MGR="podman"
    elif command -v docker &> /dev/null; then
        echo -e "${GREEN}[✓] Docker found${NC}"
        CONTAINER_MGR="docker"
    else
        echo -e "${RED}[!] No container manager found (podman or docker required)${NC}"
        echo -e "${YELLOW}[+] Installing podman...${NC}"
        
        if [[ -f /etc/debian_version ]]; then
            sudo apt update && sudo apt install -y podman
        elif [[ -f /etc/fedora-release ]]; then
            sudo dnf install -y podman
        elif [[ -f /etc/arch-release ]]; then
            sudo pacman -S --noconfirm podman
        else
            echo -e "${RED}[!] Please install podman or docker manually${NC}"
            exit 1
        fi
    fi
}

# Check and pull image
pull_image() {
    # Check if local image exists
    if ${CONTAINER_MGR} images | grep -q "^hackerwhale.*latest"; then
        echo -e "${GREEN}[✓] Local image found: hackerwhale:latest${NC}"
        echo -e "${YELLOW}[?] Use local image? [Y/n]${NC}"
        read -r response
        if [[ ! "$response" =~ ^([nN][oO]|[nN])$ ]]; then
            IMAGE=${IMAGE_LOCAL}
            USE_LOCAL=true
            echo -e "${GREEN}[✓] Using local image${NC}"
            return
        fi
    fi
    
    echo -e "${BLUE}[+] Pulling HackerWhale image from Docker Hub...${NC}"
    IMAGE=${IMAGE_REMOTE}
    ${CONTAINER_MGR} pull ${IMAGE}
    echo -e "${GREEN}[✓] Image pulled successfully!${NC}"
}

# Create container
create_container() {
    echo -e "${BLUE}[+] Creating HackerWhale container...${NC}"
    
    # Ask for root or rootless
    echo -e "\n${YELLOW}Choose mode:${NC}"
    echo "1. Root mode (full access, recommended for pentest)"
    echo "2. Rootless mode (more secure)"
    read -p "Enter choice [1-2]: " mode_choice
    
    local root_flag=""
    if [[ "$mode_choice" == "1" ]]; then
        root_flag="--root"
        echo -e "${YELLOW}[!] Using root mode - container will have root access${NC}"
    fi
    
    # Create container
    distrobox create \
        --name ${CONTAINER_NAME} \
        --image ${IMAGE} \
        ${root_flag} \
        --additional-flags "--cap-add=NET_ADMIN --cap-add=NET_RAW" \
        --yes
    
    echo -e "${GREEN}[✓] Container created successfully!${NC}"
}

# Setup aliases
setup_aliases() {
    echo -e "${BLUE}[+] Setting up aliases...${NC}"
    
    local shell_rc=""
    if [[ -f ~/.zshrc ]]; then
        shell_rc=~/.zshrc
    elif [[ -f ~/.bashrc ]]; then
        shell_rc=~/.bashrc
    else
        echo -e "${YELLOW}[!] No shell rc file found, skipping aliases${NC}"
        return
    fi
    
    # Check if aliases already exist
    if grep -q "alias hw=" "$shell_rc"; then
        echo -e "${YELLOW}[!] Aliases already exist, skipping${NC}"
        return
    fi
    
    cat >> "$shell_rc" << 'EOF'

# HackerWhale Distrobox aliases
alias hw='distrobox enter hackerwhale'
alias hw-root='distrobox enter --root hackerwhale'
alias hw-stop='distrobox stop hackerwhale'
alias hw-list='distrobox list'

EOF
    
    echo -e "${GREEN}[✓] Aliases added to $shell_rc${NC}"
    echo -e "${BLUE}[i] Available aliases: hw, hw-root, hw-stop, hw-list${NC}"
}

# Test installation
test_installation() {
    echo -e "\n${BLUE}[+] Testing installation...${NC}"
    
    echo -e "${YELLOW}[*] Testing subfinder...${NC}"
    if distrobox enter ${CONTAINER_NAME} -- bash -c 'export PATH=$PATH:/root/go/bin && subfinder -version' &>/dev/null; then
        echo -e "${GREEN}[✓] subfinder works!${NC}"
    else
        echo -e "${RED}[!] subfinder test failed${NC}"
    fi
    
    echo -e "${YELLOW}[*] Testing nuclei...${NC}"
    if distrobox enter ${CONTAINER_NAME} -- bash -c 'export PATH=$PATH:/root/go/bin && nuclei -version' &>/dev/null; then
        echo -e "${GREEN}[✓] nuclei works!${NC}"
    else
        echo -e "${RED}[!] nuclei test failed${NC}"
    fi
}

# Show next steps
show_next_steps() {
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           HackerWhale Setup Complete! 🐋                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${BLUE}📋 Next Steps:${NC}\n"
    echo -e "${YELLOW}1.${NC} Enter HackerWhale:"
    echo -e "   ${GREEN}hw${NC}  or  ${GREEN}distrobox enter hackerwhale${NC}"
    
    echo -e "\n${YELLOW}2.${NC} Run a quick test:"
    echo -e "   ${GREEN}hw${NC}"
    echo -e "   ${GREEN}subfinder -d hackerone.com${NC}"
    
    echo -e "\n${YELLOW}3.${NC} Configure API keys (optional):"
    echo -e "   ${GREEN}hw${NC}"
    echo -e "   ${GREEN}mkdir -p ~/.config/subfinder${NC}"
    echo -e "   ${GREEN}nano ~/.config/subfinder/provider-config.yaml${NC}"
    
    echo -e "\n${YELLOW}4.${NC} Read the guides:"
    echo -e "   ${GREEN}cat DISTROBOX_GUIDE.md${NC}"
    echo -e "   ${GREEN}cat QUICKSTART.md${NC}"
    
    echo -e "\n${BLUE}📖 Documentation:${NC}"
    echo -e "   • Distrobox Guide: ${GREEN}DISTROBOX_GUIDE.md${NC}"
    echo -e "   • Quick Start: ${GREEN}QUICKSTART.md${NC}"
    echo -e "   • Bug Hunter Guide: ${GREEN}BUGHUNTER_GUIDE.md${NC}"
    
    echo -e "\n${BLUE}🔧 Useful Commands:${NC}"
    echo -e "   • Enter container: ${GREEN}hw${NC}"
    echo -e "   • Stop container: ${GREEN}hw-stop${NC}"
    echo -e "   • List containers: ${GREEN}hw-list${NC}"
    echo -e "   • Remove container: ${GREEN}distrobox rm hackerwhale${NC}"
    
    echo -e "\n${GREEN}Happy Hacking! 🚀${NC}\n"
}

# Main
main() {
    banner
    
    echo -e "${BLUE}[+] Starting HackerWhale Distrobox setup...${NC}\n"
    
    check_container_manager
    check_distrobox
    pull_image
    create_container
    setup_aliases
    test_installation
    show_next_steps
}

main "$@"

