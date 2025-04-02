#!/bin/bash
set -e

# Colors for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}      Backdoor Pre-commit Checks         ${NC}"
echo -e "${BLUE}==========================================${NC}"

# Ensure PATH includes ~/.local/bin for installed tools
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Format Swift files
format_swift() {
    echo -e "\n${BLUE}Formatting Swift files...${NC}"
    
    if ! command -v swiftformat &> /dev/null; then
        echo -e "${RED}SwiftFormat not found. Run '.mentat/setup.sh' first.${NC}"
        return 1
    fi
    
    SWIFT_FILES=$(find . -name "*.swift" -not -path "*/Pods/*" -not -path "*/.build/*" -not -path "*/.swiftpm/*")
    if [ ! -z "$SWIFT_FILES" ]; then
        swiftformat . --exclude Pods,.build,.swiftpm
        echo -e "${GREEN}Swift formatting completed${NC}"
    else
        echo -e "${YELLOW}No Swift files found to format.${NC}"
    fi
}

# Lint Swift files
lint_swift() {
    echo -e "\n${BLUE}Linting Swift files and fixing issues...${NC}"
    
    if ! command -v swiftlint &> /dev/null; then
        echo -e "${RED}SwiftLint not found. Run '.mentat/setup.sh' first.${NC}"
        return 1
    fi
    
    SWIFT_FILES=$(find . -name "*.swift" -not -path "*/Pods/*" -not -path "*/.build/*" -not -path "*/.swiftpm/*")
    if [ ! -z "$SWIFT_FILES" ]; then
        swiftlint --fix || true
        echo -e "${GREEN}Swift linting and fixing completed${NC}"
    else
        echo -e "${YELLOW}No Swift files found to lint.${NC}"
    fi
}

# Format C++/Objective-C files
format_cpp() {
    echo -e "\n${BLUE}Formatting C++/Objective-C/Objective-C++ files...${NC}"
    
    if ! command -v clang-format &> /dev/null; then
        echo -e "${RED}clang-format not found. Run '.mentat/setup.sh' first.${NC}"
        return 1
    fi
    
    CPP_FILES=$(find . -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.m" -o -name "*.mm" \) -not -path "*/Pods/*" -not -path "*/.build/*")
    if [ ! -z "$CPP_FILES" ]; then
        for file in $CPP_FILES; do
            echo "Formatting $file"
            clang-format -i "$file" || echo -e "${RED}Failed to format $file${NC}"
        done
        echo -e "${GREEN}C++/Objective-C formatting completed${NC}"
    else
        echo -e "${YELLOW}No C++/Objective-C/Objective-C++ files found to format.${NC}"
    fi
}

# Perform a basic Swift build to check for compilation errors
check_swift_build() {
    echo -e "\n${BLUE}Checking Swift build...${NC}"
    
    if [ -f "Package.swift" ]; then
        # Only build, don't run tests as they might be extensive
        swift build -c debug || {
            echo -e "${RED}Swift build failed!${NC}"
            return 1
        }
        echo -e "${GREEN}Swift build successful${NC}"
    else
        echo -e "${YELLOW}No Package.swift found, skipping build check.${NC}"
    fi
}

# Run all checks
format_swift
lint_swift
format_cpp
check_swift_build

echo -e "\n${GREEN}All pre-commit checks completed successfully!${NC}"
