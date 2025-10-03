#!/bin/bash
# HackerWhale Helper Script
# Quick commands for bug hunting workflows

set -e

VERSION="1.0.0"
IMAGE_NAME="hackerwhale:latest"
CONTAINER_NAME="hackerwhale"
WORKDIR="$(pwd)/data"

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
    echo -e "   ${GREEN}Bug Hunting Docker Environment v${VERSION}${NC}"
    echo -e "   ${YELLOW}by @gpxlnx${NC}\n"
}

# Help
usage() {
    banner
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  build                 - Build the HackerWhale image"
    echo "  run                   - Start HackerWhale container (interactive)"
    echo "  start                 - Start HackerWhale in background"
    echo "  stop                  - Stop HackerWhale container"
    echo "  restart               - Restart HackerWhale container"
    echo "  shell                 - Open shell in running container"
    echo "  status                - Check container status"
    echo "  logs                  - View container logs"
    echo "  clean                 - Remove container and image"
    echo ""
    echo "Workflow Commands:"
    echo "  recon <domain>        - Run full reconnaissance on domain"
    echo "  scan <target_file>    - Run vulnerability scan on targets"
    echo "  fuzz <url>            - Fuzz URL for hidden paths"
    echo "  monitor <domain>      - Start continuous monitoring"
    echo ""
    echo "Options:"
    echo "  -h, --help            - Show this help message"
    echo "  -v, --version         - Show version"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 run"
    echo "  $0 recon example.com"
    echo "  $0 scan targets.txt"
    echo ""
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}[!] Docker is not installed. Please install Docker first.${NC}"
        exit 1
    fi
}

# Build image
build_image() {
    echo -e "${GREEN}[+] Building HackerWhale image...${NC}"
    docker build \
        --build-arg EXPANSION_SCRIPT_LOCAL=scripts/expansion_script.sh \
        -t ${IMAGE_NAME} .
    echo -e "${GREEN}[✓] Image built successfully!${NC}"
}

# Run container (interactive)
run_container() {
    echo -e "${GREEN}[+] Starting HackerWhale (interactive mode)...${NC}"
    mkdir -p ${WORKDIR}
    docker run -it --rm \
        --name ${CONTAINER_NAME} \
        -v ${WORKDIR}:/workdir \
        --cap-add=NET_ADMIN \
        --net=host \
        ${IMAGE_NAME} zsh
}

# Start container (background)
start_container() {
    echo -e "${GREEN}[+] Starting HackerWhale (background mode)...${NC}"
    mkdir -p ${WORKDIR}
    docker run -d \
        --name ${CONTAINER_NAME} \
        -v ${WORKDIR}:/workdir \
        --cap-add=NET_ADMIN \
        --net=host \
        ${IMAGE_NAME}
    echo -e "${GREEN}[✓] Container started! Use '$0 shell' to access.${NC}"
}

# Stop container
stop_container() {
    echo -e "${YELLOW}[+] Stopping HackerWhale...${NC}"
    docker stop ${CONTAINER_NAME} 2>/dev/null || echo -e "${RED}[!] Container not running${NC}"
}

# Restart container
restart_container() {
    stop_container
    sleep 2
    start_container
}

# Open shell
open_shell() {
    if docker ps | grep -q ${CONTAINER_NAME}; then
        docker exec -it ${CONTAINER_NAME} zsh
    else
        echo -e "${RED}[!] Container is not running. Start it first with '$0 start'${NC}"
        exit 1
    fi
}

# Check status
check_status() {
    if docker ps | grep -q ${CONTAINER_NAME}; then
        echo -e "${GREEN}[✓] HackerWhale is running${NC}"
        docker ps | grep ${CONTAINER_NAME}
    else
        echo -e "${YELLOW}[!] HackerWhale is not running${NC}"
    fi
}

# View logs
view_logs() {
    docker logs -f ${CONTAINER_NAME}
}

# Clean up
cleanup() {
    echo -e "${YELLOW}[+] Cleaning up...${NC}"
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
    echo -e "${RED}[?] Remove image as well? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        docker rmi ${IMAGE_NAME} 2>/dev/null || true
        echo -e "${GREEN}[✓] Cleanup complete!${NC}"
    fi
}

# Reconnaissance workflow
run_recon() {
    local domain=$1
    if [ -z "$domain" ]; then
        echo -e "${RED}[!] Please provide a domain${NC}"
        exit 1
    fi

    echo -e "${GREEN}[+] Starting reconnaissance for: ${domain}${NC}"
    
    mkdir -p ${WORKDIR}/${domain}/{recon,urls,vuln}
    
    if ! docker ps | grep -q ${CONTAINER_NAME}; then
        start_container
        sleep 3
    fi

    docker exec ${CONTAINER_NAME} bash -c "
        cd /workdir/${domain}
        
        echo '[+] Subdomain enumeration...'
        subfinder -d ${domain} -silent | anew recon/subs.txt
        amass enum -passive -d ${domain} | anew recon/subs.txt
        
        echo '[+] Probing for live hosts...'
        httpx -l recon/subs.txt -silent -o recon/live.txt
        
        echo '[+] URL discovery...'
        cat recon/live.txt | waybackurls | anew urls/all.txt
        gau ${domain} | anew urls/all.txt
        
        echo '[+] Cleaning URLs...'
        cat urls/all.txt | uro | anew urls/clean.txt
        
        echo '[+] Done! Results in /workdir/${domain}/'
    "
}

# Vulnerability scanning workflow
run_scan() {
    local target_file=$1
    if [ -z "$target_file" ]; then
        echo -e "${RED}[!] Please provide a target file${NC}"
        exit 1
    fi

    if [ ! -f "$target_file" ]; then
        echo -e "${RED}[!] File not found: ${target_file}${NC}"
        exit 1
    fi

    echo -e "${GREEN}[+] Starting vulnerability scan...${NC}"
    
    if ! docker ps | grep -q ${CONTAINER_NAME}; then
        start_container
        sleep 3
    fi

    local basename=$(basename ${target_file})
    docker cp ${target_file} ${CONTAINER_NAME}:/tmp/${basename}
    
    docker exec ${CONTAINER_NAME} bash -c "
        cd /workdir
        mkdir -p vuln_results
        
        echo '[+] Running Nuclei...'
        nuclei -l /tmp/${basename} -severity critical,high,medium -o vuln_results/nuclei-$(date +%Y%m%d_%H%M%S).txt
        
        echo '[+] Checking WAF...'
        wafw00f -i /tmp/${basename} -o vuln_results/wafw00f-$(date +%Y%m%d_%H%M%S).txt
        
        echo '[+] Done! Results in /workdir/vuln_results/'
    "
}

# Fuzzing workflow
run_fuzz() {
    local url=$1
    if [ -z "$url" ]; then
        echo -e "${RED}[!] Please provide a URL${NC}"
        exit 1
    fi

    echo -e "${GREEN}[+] Starting fuzzing for: ${url}${NC}"
    
    if ! docker ps | grep -q ${CONTAINER_NAME}; then
        start_container
        sleep 3
    fi

    docker exec ${CONTAINER_NAME} bash -c "
        cd /workdir
        mkdir -p fuzz_results
        
        echo '[+] Directory fuzzing with ffuf...'
        ffuf -w /opt/wordlists/SecLists/Discovery/Web-Content/raft-medium-directories.txt \
            -u ${url}/FUZZ \
            -mc 200,204,301,302,307,401,403 \
            -o fuzz_results/ffuf-$(date +%Y%m%d_%H%M%S).json
        
        echo '[+] Parameter discovery with Arjun...'
        arjun -u ${url} -oT fuzz_results/arjun-$(date +%Y%m%d_%H%M%S).txt
        
        echo '[+] Done! Results in /workdir/fuzz_results/'
    "
}

# Monitoring workflow
run_monitor() {
    local domain=$1
    if [ -z "$domain" ]; then
        echo -e "${RED}[!] Please provide a domain${NC}"
        exit 1
    fi

    echo -e "${GREEN}[+] Starting monitoring for: ${domain}${NC}"
    echo -e "${YELLOW}[!] Press Ctrl+C to stop${NC}"
    
    if ! docker ps | grep -q ${CONTAINER_NAME}; then
        start_container
        sleep 3
    fi

    docker exec ${CONTAINER_NAME} bash -c "
        cd /workdir
        mkdir -p monitor/${domain}
        
        while true; do
            echo '[$(date)] Checking for new subdomains...'
            subfinder -d ${domain} -silent | anew monitor/${domain}/subs.txt | tee monitor/${domain}/new-$(date +%Y%m%d_%H%M%S).txt
            sleep 3600
        done
    "
}

# Main
main() {
    check_docker

    case "${1}" in
        build)
            build_image
            ;;
        run)
            run_container
            ;;
        start)
            start_container
            ;;
        stop)
            stop_container
            ;;
        restart)
            restart_container
            ;;
        shell)
            open_shell
            ;;
        status)
            check_status
            ;;
        logs)
            view_logs
            ;;
        clean)
            cleanup
            ;;
        recon)
            run_recon "${2}"
            ;;
        scan)
            run_scan "${2}"
            ;;
        fuzz)
            run_fuzz "${2}"
            ;;
        monitor)
            run_monitor "${2}"
            ;;
        -h|--help)
            usage
            ;;
        -v|--version)
            echo "HackerWhale v${VERSION}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"

