#!/bin/bash
# HackerWhale Docker Hub Publish Script
# Quick script to publish image to Docker Hub

set -e

VERSION=${1:-latest}
USERNAME="gpxlnx"
IMAGE="hackerwhale"
FULL_IMAGE="${USERNAME}/${IMAGE}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
    _   _            _             __        ___           _      
   | | | | __ _  ___| | _____ _ __\ \      / / |__   __ _| | ___ 
   | |_| |/ _` |/ __| |/ / _ \ '__\ \ /\ / /| '_ \ / _` | |/ _ \
   |  _  | (_| | (__|   <  __/ |   \ V  V / | | | | (_| | |  __/
   |_| |_|\__,_|\___|_|\_\___|_|    \_/\_/  |_| |_|\__,_|_|\___|
                                                                  
EOF
echo -e "${GREEN}Docker Hub Publisher${NC}"
echo -e "${YELLOW}by @gpxlnx${NC}\n"

# Check if local image exists
echo -e "${BLUE}[1/5] Checking local image...${NC}"
if ! docker images | grep -q "^${IMAGE}"; then
    echo -e "${RED}[!] Local image '${IMAGE}' not found!${NC}"
    echo -e "${YELLOW}[i] Build it first: ./hackerwhale.sh build${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Local image found${NC}"

# Check if logged in to Docker Hub
echo -e "\n${BLUE}[2/5] Checking Docker Hub login...${NC}"
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}[!] Not logged in to Docker Hub${NC}"
    echo -e "${BLUE}[+] Logging in...${NC}"
    docker login
else
    echo -e "${GREEN}[✓] Already logged in${NC}"
fi

# Tag the image
echo -e "\n${BLUE}[3/5] Tagging image...${NC}"
echo -e "${YELLOW}[*] Tag: ${FULL_IMAGE}:${VERSION}${NC}"
docker tag ${IMAGE}:latest ${FULL_IMAGE}:${VERSION}

if [ "$VERSION" != "latest" ]; then
    echo -e "${YELLOW}[*] Tag: ${FULL_IMAGE}:latest${NC}"
    docker tag ${IMAGE}:latest ${FULL_IMAGE}:latest
fi

echo -e "${GREEN}[✓] Image tagged${NC}"

# Show image size
IMAGE_SIZE=$(docker images ${FULL_IMAGE}:${VERSION} --format "{{.Size}}")
echo -e "${BLUE}[i] Image size: ${IMAGE_SIZE}${NC}"

# Confirm push
echo -e "\n${YELLOW}[?] Ready to push to Docker Hub. Continue? [y/N]${NC}"
read -r response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${RED}[!] Push cancelled${NC}"
    exit 0
fi

# Push to Docker Hub
echo -e "\n${BLUE}[4/5] Pushing to Docker Hub...${NC}"
echo -e "${YELLOW}[*] This may take a while (image is ${IMAGE_SIZE})...${NC}\n"

docker push ${FULL_IMAGE}:${VERSION}

if [ "$VERSION" != "latest" ]; then
    echo -e "\n${YELLOW}[*] Pushing latest tag...${NC}\n"
    docker push ${FULL_IMAGE}:latest
fi

# Verify
echo -e "\n${BLUE}[5/5] Verifying publication...${NC}"
if docker pull ${FULL_IMAGE}:${VERSION} > /dev/null 2>&1; then
    echo -e "${GREEN}[✓] Image successfully published!${NC}"
else
    echo -e "${YELLOW}[!] Could not verify (but push may have succeeded)${NC}"
fi

# Summary
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Publication Complete! 🐋                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${BLUE}📊 Summary:${NC}"
echo -e "  • Username: ${GREEN}${USERNAME}${NC}"
echo -e "  • Image: ${GREEN}${IMAGE}${NC}"
echo -e "  • Version: ${GREEN}${VERSION}${NC}"
echo -e "  • Size: ${GREEN}${IMAGE_SIZE}${NC}"

echo -e "\n${BLUE}🔗 Links:${NC}"
echo -e "  • Docker Hub: ${GREEN}https://hub.docker.com/r/${FULL_IMAGE}${NC}"
echo -e "  • Pull command: ${GREEN}docker pull ${FULL_IMAGE}:${VERSION}${NC}"

echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo -e "  ${YELLOW}1.${NC} Visit Docker Hub and add description:"
echo -e "     ${GREEN}https://hub.docker.com/r/${FULL_IMAGE}/general${NC}"
echo -e "  ${YELLOW}2.${NC} Create GitHub release:"
echo -e "     ${GREEN}https://github.com/${USERNAME}/HackerWhale/releases/new${NC}"
echo -e "  ${YELLOW}3.${NC} Test with Distrobox:"
echo -e "     ${GREEN}./distrobox-setup.sh${NC}"

echo -e "\n${GREEN}Happy Hacking! 🚀${NC}\n"


