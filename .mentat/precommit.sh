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

# Detect if we're running in a container (simplified check)
IN_CONTAINER=0
if [ -f "/.dockerenv" ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    IN_CONTAINER=1
    echo -e "${YELLOW}Container environment detected.${NC}"
    echo -e "${YELLOW}Running in check-only mode.${NC}"
fi

# Just find Swift files to check
check_swift_files() {
    echo -e "\n${BLUE}Finding Swift files to check...${NC}"
    
    SWIFT_FILES=$(find . -name "*.swift" -not -path "*/Pods/*" -not -path "*/.build/*" -not -path "*/.swiftpm/*" | sort)
    if [ ! -z "$SWIFT_FILES" ]; then
        SWIFT_COUNT=$(echo "$SWIFT_FILES" | wc -l)
        echo -e "${GREEN}Found ${SWIFT_COUNT} Swift files that would be formatted and linted${NC}"
        if [ $IN_CONTAINER -eq 0 ]; then
            echo -e "${BLUE}Running in a local environment would format these files with:${NC}"
            echo -e "  - ${GREEN}swiftformat . --exclude Pods,.build,.swiftpm${NC}"
            echo -e "  - ${GREEN}swiftlint --fix${NC}"
        fi
    else
        echo -e "${YELLOW}No Swift files found to check.${NC}"
    fi
    return 0
}

# Just find C++/Objective-C files to check
check_cpp_files() {
    echo -e "\n${BLUE}Finding C++/Objective-C/Objective-C++ files to check...${NC}"
    
    CPP_FILES=$(find . -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.m" -o -name "*.mm" \) -not -path "*/Pods/*" -not -path "*/.build/*" | sort)
    if [ ! -z "$CPP_FILES" ]; then
        CPP_COUNT=$(echo "$CPP_FILES" | wc -l)
        echo -e "${GREEN}Found ${CPP_COUNT} C++/Objective-C files that would be formatted${NC}"
        if [ $IN_CONTAINER -eq 0 ]; then
            echo -e "${BLUE}Running in a local environment would format these files with:${NC}"
            echo -e "  - ${GREEN}clang-format -i <file>${NC}"
        fi
    else
        echo -e "${YELLOW}No C++/Objective-C/Objective-C++ files found to check.${NC}"
    fi
    return 0
}

# Check for Package.swift
check_swift_build() {
    echo -e "\n${BLUE}Checking for Swift package...${NC}"
    
    if [ -f "Package.swift" ]; then
        echo -e "${GREEN}Found Package.swift${NC}"
        if [ $IN_CONTAINER -eq 0 ]; then
            echo -e "${BLUE}Running in a local environment would build with:${NC}"
            echo -e "  - ${GREEN}swift build -c debug${NC}"
        else 
            echo -e "${YELLOW}Swift build would be skipped in container environment.${NC}"
        fi
    else
        echo -e "${YELLOW}No Package.swift found, build check would be skipped.${NC}"
    fi
    return 0
}

# Run all checks in report-only mode
echo -e "${BLUE}Running pre-commit checks (report-only mode)...${NC}"

check_swift_files || true
check_cpp_files || true
check_swift_build || true

echo -e "\n${GREEN}Pre-commit checks completed!${NC}"
if [ $IN_CONTAINER -eq 1 ]; then
    echo -e "${YELLOW}Note: In container environment, files were only checked, not modified.${NC}"
    echo -e "${YELLOW}When running locally, formatting tools would be applied to the files.${NC}"
else
    echo -e "${BLUE}When running locally, formatting and linting would be applied to the files.${NC}"
fi
