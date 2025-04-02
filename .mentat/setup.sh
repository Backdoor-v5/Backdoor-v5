#!/bin/bash
set -e

# Colors for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   Backdoor Development Setup Script      ${NC}"
echo -e "${BLUE}==========================================${NC}"

# Detect if we're running in a container (simplified check)
IN_CONTAINER=0
if [ -f "/.dockerenv" ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    IN_CONTAINER=1
    echo -e "${YELLOW}Container environment detected.${NC}"
    echo -e "${YELLOW}Only basic setup will be performed.${NC}"
fi

# Create .gitignore if not exists
if [ ! -f .gitignore ]; then
    echo -e "\n${BLUE}Creating .gitignore file...${NC}"
    cat > .gitignore << 'GITIGNORE_CONTENT'
# Xcode
#
# gitignore contributors: remember to update Global/Xcode.gitignore, Objective-C.gitignore & Swift.gitignore

## User settings
xcuserdata/
.DS_Store

## compatibility with Xcode 8 and earlier (ignoring not required starting Xcode 9)
*.xcscmblueprint
*.xccheckout

## compatibility with Xcode 3 and earlier (ignoring not required starting Xcode 4)
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3

## Obj-C/Swift specific
*.hmap

## App packaging
*.ipa
*.dSYM.zip
*.dSYM

## Playgrounds
timeline.xctimeline
playground.xcworkspace

# Swift Package Manager
#
# Add this line if you want to avoid checking in source code from Swift Package Manager dependencies.
.build/
.swiftpm/

# CocoaPods
#
# We recommend against adding the Pods directory to your .gitignore. However
# you should judge for yourself, the pros and cons are mentioned at:
# https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control
#
Pods/

# Carthage
#
# Add this line if you want to avoid checking in source code from Carthage dependencies.
Carthage/Checkouts
Carthage/Build/

# fastlane
#
# It is recommended to not store the screenshots in the git repo.
# Instead, use fastlane to re-generate the screenshots whenever they are needed.
# For more information about the recommended setup visit:
# https://docs.fastlane.tools/best-practices/source-control/#source-control

fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
#
# After new code Injection tools there's a generated folder /iOSInjectionProject
# https://github.com/johnno1962/injectionforxcode

iOSInjectionProject/

# Development tools
*.swp
*~
.swiftlint.txt
*.swift.orig

# Packages
packages/
GITIGNORE_CONTENT
    echo -e "${GREEN}Created .gitignore file${NC}"
fi

# Copy configuration files - Modified to remove header strip from .swiftformat
echo -e "\n${BLUE}Setting up configuration files...${NC}"
cp -v Clean/.swiftlint.yml .swiftlint.yml
cp -v Clean/.clang-format .clang-format

# For .swiftformat, remove the header strip option to preserve license headers
if [ -f Clean/.swiftformat ]; then
    echo -e "${BLUE}Creating .swiftformat without header strip to preserve license headers...${NC}"
    grep -v "\-\-header strip" Clean/.swiftformat > .swiftformat || cp -v Clean/.swiftformat .swiftformat
    echo -e "${GREEN}.swiftformat created without header strip option${NC}"
else
    echo -e "${YELLOW}No .swiftformat found in Clean directory, creating default...${NC}"
    cat > .swiftformat << 'SWIFTFORMAT_CONTENT'
--indent 4
--indentcase true
--trimwhitespace always
--importgrouping alphabetized
--semicolons never
--disable redundantSelf
SWIFTFORMAT_CONTENT
    echo -e "${GREEN}Created default .swiftformat without header strip${NC}"
fi

echo -e "${GREEN}Configuration files copied${NC}"

# Skip installation in containers, just provide guidance
if [ $IN_CONTAINER -eq 1 ]; then
    echo -e "\n${YELLOW}Skipping tool installation in container environment.${NC}"
    echo -e "${BLUE}When running locally, the development tools needed are:${NC}"
    echo -e "  - ${GREEN}SwiftLint${NC}: for linting Swift code"
    echo -e "  - ${GREEN}SwiftFormat${NC}: for formatting Swift code"
    echo -e "  - ${GREEN}clang-format${NC}: for formatting C++/Objective-C code"
    echo -e "\n${BLUE}You can install these tools using:${NC}"
    echo -e "  - On macOS: ${GREEN}brew install swiftlint swiftformat clang-format${NC}"
    echo -e "  - On Linux: Use package manager or download binaries"
    echo -e "\n${GREEN}Setup completed with configuration files only.${NC}"
    exit 0
fi

# Add $HOME/.local/bin to PATH if not already and not in a container
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "\n${BLUE}Adding $HOME/.local/bin to PATH${NC}"
    export PATH="$HOME/.local/bin:$PATH"
    # Only modify .bashrc if it exists and we're in an interactive shell
    if [ -f "$HOME/.bashrc" ] && [ -t 0 ]; then
        grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || \
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
fi

echo -e "\n${GREEN}Setup completed!${NC}"
echo -e "${BLUE}You can now run formatting and linting tools for your Swift and C++/Objective-C code.${NC}"
echo -e "${GREEN}Note: License headers will be preserved during formatting.${NC}"
