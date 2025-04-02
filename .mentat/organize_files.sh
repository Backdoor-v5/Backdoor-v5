#!/bin/bash
set -e

# Colors for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   Backdoor Files Organization Script     ${NC}"
echo -e "${BLUE}==========================================${NC}"

# Create necessary directories
echo -e "\n${BLUE}Creating directory structure...${NC}"
mkdir -p files/package-info
mkdir -p files/snippets
mkdir -p files/patches
echo -e "${GREEN}Directory structure created${NC}"

# Move license header script to scripts/license directory
echo -e "\n${BLUE}Moving license script to scripts/license directory...${NC}"
if [ -f fix_license_headers.sh ]; then
    mkdir -p scripts/license
    mv -v fix_license_headers.sh scripts/license/
    echo -e "${GREEN}Moved fix_license_headers.sh to scripts/license/${NC}"
else
    echo -e "${YELLOW}fix_license_headers.sh not found in current directory${NC}"
fi

# Move package related files to package-info directory
echo -e "\n${BLUE}Moving package-related files...${NC}"
for file in package-products.txt package-ref-list.txt package-refs.txt package-resolved.patch product-deps.txt framework-refs.txt workspace-resolved.txt; do
    if [ -f "$file" ]; then
        mv -v "$file" files/package-info/
        echo -e "${GREEN}Moved $file to files/package-info/${NC}"
    else
        echo -e "${YELLOW}$file not found${NC}"
    fi
done

# Move snippet files to snippets directory
echo -e "\n${BLUE}Moving code snippet files...${NC}"
for file in fixed-ssnl-snippet.txt ssnl-snippet.txt; do
    if [ -f "$file" ]; then
        mv -v "$file" files/snippets/
        echo -e "${GREEN}Moved $file to files/snippets/${NC}"
    else
        echo -e "${YELLOW}$file not found${NC}"
    fi
done

# Move patch files to patches directory
echo -e "\n${BLUE}Moving patch files...${NC}"
for file in localization_changes.patch app-repo.json; do
    if [ -f "$file" ]; then
        mv -v "$file" files/patches/
        echo -e "${GREEN}Moved $file to files/patches/${NC}"
    else
        echo -e "${YELLOW}$file not found${NC}"
    fi
done

echo -e "\n${GREEN}File organization completed!${NC}"
echo -e "${BLUE}The repository has been reorganized for better structure.${NC}"
