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

# Copy configuration files
echo -e "\n${BLUE}Setting up configuration files...${NC}"
cp -v Clean/.swiftlint.yml .swiftlint.yml
cp -v Clean/.swiftformat .swiftformat
cp -v Clean/.clang-format .clang-format
echo -e "${GREEN}Configuration files copied${NC}"

# Function to install SwiftLint
install_swiftlint() {
    echo -e "\n${BLUE}Installing SwiftLint...${NC}"
    
    # Check if SwiftLint is already available
    if command -v swiftlint &> /dev/null; then
        echo -e "${GREEN}SwiftLint already installed${NC}"
        return
    fi
    
    # Try to download pre-built binary
    LATEST_SWIFTLINT_URL=$(curl -s https://api.github.com/repos/realm/SwiftLint/releases/latest | grep browser_download_url | grep portable | cut -d '"' -f 4)
    
    if [ ! -z "$LATEST_SWIFTLINT_URL" ]; then
        echo "Downloading SwiftLint from $LATEST_SWIFTLINT_URL"
        curl -L "$LATEST_SWIFTLINT_URL" -o swiftlint.zip
        unzip -o swiftlint.zip
        if [ -f "swiftlint" ]; then
            chmod +x swiftlint
            mkdir -p $HOME/.local/bin
            mv swiftlint $HOME/.local/bin/
            rm -f swiftlint.zip LICENSE 2>/dev/null || true
            export PATH="$HOME/.local/bin:$PATH"
            echo -e "${GREEN}SwiftLint installed successfully${NC}"
        else
            echo -e "${RED}Error: SwiftLint binary not found in the downloaded package${NC}"
        fi
    else
        echo -e "${RED}Error: Could not find SwiftLint download URL${NC}"
    fi
}

# Function to install SwiftFormat
install_swiftformat() {
    echo -e "\n${BLUE}Installing SwiftFormat...${NC}"
    
    # Check if SwiftFormat is already available
    if command -v swiftformat &> /dev/null; then
        echo -e "${GREEN}SwiftFormat already installed${NC}"
        return
    fi
    
    # Try direct binary download first
    LATEST_SWIFTFORMAT_URL=$(curl -s https://api.github.com/repos/nicklockwood/SwiftFormat/releases/latest | \
        grep browser_download_url | \
        grep -v artifactbundle | \
        grep -v .zip | \
        grep -E "swiftformat$" | \
        head -n 1 | \
        cut -d '"' -f 4)
    
    if [ ! -z "$LATEST_SWIFTFORMAT_URL" ]; then
        echo "Found direct SwiftFormat binary at $LATEST_SWIFTFORMAT_URL"
        curl -L "$LATEST_SWIFTFORMAT_URL" -o swiftformat
        chmod +x swiftformat
        mkdir -p $HOME/.local/bin
        mv swiftformat $HOME/.local/bin/
        export PATH="$HOME/.local/bin:$PATH"
        echo -e "${GREEN}SwiftFormat installed successfully${NC}"
        return
    fi
    
    # Try artifact bundle as fallback
    echo "No direct binary found, trying artifact bundle..."
    BUNDLE_URL=$(curl -s https://api.github.com/repos/nicklockwood/SwiftFormat/releases/latest | \
        grep browser_download_url | \
        grep artifactbundle | \
        head -n 1 | \
        cut -d '"' -f 4)
    
    if [ ! -z "$BUNDLE_URL" ]; then
        echo "Found SwiftFormat artifact bundle at $BUNDLE_URL"
        TEMP_DIR=$(mktemp -d)
        curl -L "$BUNDLE_URL" -o "$TEMP_DIR/swiftformat.zip"
        unzip -o "$TEMP_DIR/swiftformat.zip" -d "$TEMP_DIR"
        
        # Try to find the correct binary for this platform
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS
            SWIFTFORMAT_BIN=$(find "$TEMP_DIR" -name "swiftformat" -type f | grep -v linux | head -n 1)
        else
            # Linux - try to match architecture
            if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
                SWIFTFORMAT_BIN=$(find "$TEMP_DIR" -name "*aarch64*" -type f | head -n 1)
            else
                SWIFTFORMAT_BIN=$(find "$TEMP_DIR" -name "*linux*" -type f | grep -v aarch64 | head -n 1)
            fi
        fi
        
        if [ ! -z "$SWIFTFORMAT_BIN" ]; then
            echo "Found binary at $SWIFTFORMAT_BIN"
            chmod +x "$SWIFTFORMAT_BIN"
            mkdir -p $HOME/.local/bin
            cp "$SWIFTFORMAT_BIN" "$HOME/.local/bin/swiftformat"
            export PATH="$HOME/.local/bin:$PATH"
            echo -e "${GREEN}SwiftFormat installed successfully${NC}"
        else
            echo -e "${RED}Error: Could not find SwiftFormat binary in artifact bundle${NC}"
        fi
        
        rm -rf "$TEMP_DIR"
    else
        echo -e "${RED}Error: Could not find SwiftFormat download URL${NC}"
    fi
}

# Function to install clang-format
install_clang_format() {
    echo -e "\n${BLUE}Installing clang-format...${NC}"
    
    # Check if clang-format is already available
    if command -v clang-format &> /dev/null; then
        echo -e "${GREEN}clang-format already installed${NC}"
        return
    fi
    
    # Try apt-get for Debian-based systems
    if command -v apt-get &> /dev/null; then
        echo "Trying to install clang-format via apt-get..."
        sudo apt-get update -y
        sudo apt-get install -y clang-format || echo -e "${RED}Failed to install clang-format via apt-get${NC}"
        return
    fi
    
    # Try brew for macOS
    if command -v brew &> /dev/null; then
        echo "Trying to install clang-format via brew..."
        brew install clang-format || echo -e "${RED}Failed to install clang-format via brew${NC}"
        return
    fi
    
    # Try yum for Red Hat-based systems
    if command -v yum &> /dev/null; then
        echo "Trying to install clang-format via yum..."
        sudo yum install -y clang-tools-extra || echo -e "${RED}Failed to install clang-format via yum${NC}"
        return
    fi
    
    echo -e "${YELLOW}Could not install clang-format automatically. Please install it manually.${NC}"
}

# Install all required tools
install_swiftlint
install_swiftformat
install_clang_format

# Add $HOME/.local/bin to PATH if not already
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "\n${BLUE}Adding $HOME/.local/bin to PATH${NC}"
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Install Swift Package Manager dependencies
echo -e "\n${BLUE}Installing Swift Package Manager dependencies...${NC}"
swift package resolve

echo -e "\n${GREEN}Setup completed successfully!${NC}"
echo -e "${BLUE}You can now run the project in Xcode or use the Makefile to build it.${NC}"
