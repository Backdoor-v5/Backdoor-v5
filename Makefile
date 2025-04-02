TARGET_CODESIGN = $(shell which ldid)

PLATFORM = iphoneos
NAME = backdoor
SCHEME ?= 'backdoor (Debug)'
RELEASE = Release-iphoneos
CONFIGURATION = Release

MACOSX_SYSROOT = $(shell xcrun -sdk macosx --show-sdk-path)
TARGET_SYSROOT = $(shell xcrun -sdk $(PLATFORM) --show-sdk-path)

APP_TMP         = $(TMPDIR)/$(NAME)
STAGE_DIR   = $(APP_TMP)/stage
APP_DIR     = $(APP_TMP)/Build/Products/$(RELEASE)/$(NAME).app

# Default CFLAGS if not provided externally
CFLAGS ?= -Onone

# Project settings to preserve during regeneration
BUNDLE_ID = kh.crysalis.backdoor
DEPLOYMENT_TARGET = 15.0
TEAM_ID ?= 
INFO_PLIST_PATH = iOS/Info.plist
MARKETING_VERSION = 1.4.0
CURRENT_PROJECT_VERSION = 5
BRIDGING_HEADER = Shared/Magic/backdoor-Bridging-Header.h

# Backup directory for project settings
BACKUP_DIR = .project_backup

# Mixed language source file support
OBJCPP_FILES = Shared/Magic/openssl_tools.mm Shared/Magic/zsign/Utils.mm Shared/Magic/zsign/zsign.mm

all: package

regenerate-project:
	@echo "📦 Backing up critical Xcode project settings before regeneration..."
	@mkdir -p $(BACKUP_DIR)/schemes $(BACKUP_DIR)/workspace
	@if [ -d "$(NAME).xcodeproj/xcshareddata/xcschemes" ]; then \
		cp -r $(NAME).xcodeproj/xcshareddata/xcschemes/* $(BACKUP_DIR)/schemes/ 2>/dev/null || true; \
	fi
	@if [ -d "$(NAME).xcodeproj/project.xcworkspace/xcshareddata" ]; then \
		cp -r $(NAME).xcodeproj/project.xcworkspace/xcshareddata $(BACKUP_DIR)/workspace/ 2>/dev/null || true; \
	fi
	@if [ -f "$(NAME).xcodeproj/project.pbxproj" ]; then \
		cp $(NAME).xcodeproj/project.pbxproj $(BACKUP_DIR)/project.pbxproj.bak 2>/dev/null || true; \
	fi
	
	@echo "🔄 Regenerating Xcode project from Package.swift..."
	@swift package generate-xcodeproj 2>/dev/null || { echo "⚠️ Swift Package Manager regeneration failed, continuing with existing project..."; exit 0; }
	
	@echo "🔙 Restoring critical project settings..."
	@mkdir -p $(NAME).xcodeproj/xcshareddata/xcschemes
	@if [ -d "$(BACKUP_DIR)/schemes" ] && [ -n "$(ls -A $(BACKUP_DIR)/schemes 2>/dev/null)" ]; then \
		cp -r $(BACKUP_DIR)/schemes/* $(NAME).xcodeproj/xcshareddata/xcschemes/ 2>/dev/null || true; \
	fi
	@mkdir -p $(NAME).xcodeproj/project.xcworkspace/xcshareddata
	@if [ -d "$(BACKUP_DIR)/workspace/xcshareddata" ] && [ -n "$(ls -A $(BACKUP_DIR)/workspace/xcshareddata 2>/dev/null)" ]; then \
		cp -r $(BACKUP_DIR)/workspace/xcshareddata/* $(NAME).xcodeproj/project.xcworkspace/xcshareddata/ 2>/dev/null || true; \
	fi
	
	@echo "⚙️ Configuring project for mixed language source files..."
	@# The mix of Swift, Objective-C, and C++ files will be handled through build settings
	@# We don't need to directly modify the project file, as we pass these settings to xcodebuild
	
	@echo "✅ Xcode project regenerated successfully."

# The REGENERATE_PROJECT flag controls whether to regenerate the project (default is on)
REGENERATE_PROJECT ?= 1

package:
ifeq ($(REGENERATE_PROJECT),1)
	@$(MAKE) regenerate-project || true
endif
	@rm -rf $(APP_TMP)
	
	@set -o pipefail; \
		xcodebuild \
		-jobs $(shell sysctl -n hw.ncpu) \
		-project '$(NAME).xcodeproj' \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-arch arm64 -sdk $(PLATFORM) \
		-derivedDataPath $(APP_TMP) \
		CODE_SIGNING_ALLOWED=NO \
		DSTROOT=$(APP_TMP)/install \
		ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO \
		SWIFT_OBJC_BRIDGING_HEADER="$(BRIDGING_HEADER)" \
		SWIFT_VERSION=5.0 \
		CLANG_ENABLE_MODULES=YES \
		CLANG_ENABLE_OBJC_ARC=YES \
		CLANG_CXX_LANGUAGE_STANDARD="gnu++17" \
		CLANG_CXX_LIBRARY="libc++" \
		CFLAGS="$(CFLAGS)" \
		PRODUCT_BUNDLE_IDENTIFIER="$(BUNDLE_ID)" \
		MARKETING_VERSION="$(MARKETING_VERSION)" \
		CURRENT_PROJECT_VERSION="$(CURRENT_PROJECT_VERSION)" \
		IPHONEOS_DEPLOYMENT_TARGET="$(DEPLOYMENT_TARGET)"
		
	@rm -rf Payload
	@rm -rf $(STAGE_DIR)/
	@mkdir -p $(STAGE_DIR)/Payload
	@mv $(APP_DIR) $(STAGE_DIR)/Payload/$(NAME).app 2>/dev/null || { \
		echo "⚠️  Build output not found at expected location. Searching..."; \
		find $(APP_TMP)/Build/Products -type d -name "*.app" | head -1 | xargs -I{} mv {} $(STAGE_DIR)/Payload/$(NAME).app 2>/dev/null || echo "⚠️  No app bundle found in build products."; \
	}
	@echo $(APP_TMP)
	@echo $(STAGE_DIR)
	
	@rm -rf $(STAGE_DIR)/Payload/$(NAME).app/_CodeSignature 2>/dev/null || true
	@ln -sf $(STAGE_DIR)/Payload Payload
	@rm -rf packages
	@mkdir -p packages

ifeq ($(TIPA),1)
	@zip -r9 packages/$(NAME)-ts.tipa Payload
else
	@zip -r9 packages/$(NAME).ipa Payload
endif

clean:
	@rm -rf $(STAGE_DIR)
	@rm -rf packages
	@rm -rf out.dmg
	@rm -rf Payload
	@rm -rf apple-include
	@rm -rf $(APP_TMP)
	@rm -rf $(BACKUP_DIR)

# Just clean the backup directory without removing other build artifacts
clean-backup:
	@rm -rf $(BACKUP_DIR)

.PHONY: apple-include regenerate-project clean-backup