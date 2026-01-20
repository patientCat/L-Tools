# L-Tools macOS App Makefile

# 编译器和标志
SWIFTC = swiftc
SWIFT_FLAGS = -O -framework AppKit -framework Carbon -framework UserNotifications

# 目录
SRC_DIR = L-Tools/Sources
APP_BUNDLE = L-Tools.app
APP_CONTENTS = $(APP_BUNDLE)/Contents
APP_MACOS = $(APP_CONTENTS)/MacOS
APP_RESOURCES = $(APP_CONTENTS)/Resources

# 源文件
SOURCES = $(SRC_DIR)/Models/Models.swift \
          $(SRC_DIR)/Services/ClipboardService.swift \
          $(SRC_DIR)/Services/HistoryStore.swift \
          $(SRC_DIR)/Services/KeyValueStore.swift \
          $(SRC_DIR)/Services/RestReminderStore.swift \
          $(SRC_DIR)/Theme/PixelTheme.swift \
          $(SRC_DIR)/Views/KeyValueView.swift \
          $(SRC_DIR)/Views/JsonFormatterView.swift \
          $(SRC_DIR)/Views/RestReminderView.swift \
          $(SRC_DIR)/Views/MenuBarView.swift \
          $(SRC_DIR)/App/LToolsApp.swift

# 输出
EXECUTABLE = LToolsApp
OUTPUT = $(APP_MACOS)/$(EXECUTABLE)

# 图标
ICON_SVG = icon.svg
ICON_ICNS = $(APP_RESOURCES)/AppIcon.icns

.PHONY: all clean run build bundle icon dist

# 默认目标：构建完整的 App Bundle
all: bundle

# 仅编译可执行文件
build: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES)
	@echo "🔨 编译 Swift 源文件..."
	$(SWIFTC) $(SWIFT_FLAGS) -o $@ $(SOURCES)
	@echo "✅ 编译完成: $@"

# 创建 App Bundle
bundle: $(EXECUTABLE)
	@echo "📁 创建 App Bundle..."
	@rm -rf $(APP_BUNDLE)
	@mkdir -p $(APP_MACOS) $(APP_RESOURCES)
	@cp $(EXECUTABLE) $(OUTPUT)
	@chmod +x $(OUTPUT)
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(APP_CONTENTS)/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(APP_CONTENTS)/Info.plist
	@echo '<plist version="1.0">' >> $(APP_CONTENTS)/Info.plist
	@echo '<dict>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>CFBundleExecutable</key><string>LToolsApp</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>CFBundleIdentifier</key><string>com.luke.LTools</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>CFBundleName</key><string>L-Tools</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>CFBundleDisplayName</key><string>L-Tools</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>CFBundleIconFile</key><string>AppIcon</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>CFBundleShortVersionString</key><string>1.0</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>CFBundleVersion</key><string>1</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>CFBundlePackageType</key><string>APPL</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>LSUIElement</key><false/>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>NSPrincipalClass</key><string>NSApplication</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>NSHighResolutionCapable</key><true/>' >> $(APP_CONTENTS)/Info.plist
	@echo '    <key>LSMinimumSystemVersion</key><string>12.0</string>' >> $(APP_CONTENTS)/Info.plist
	@echo '</dict>' >> $(APP_CONTENTS)/Info.plist
	@echo '</plist>' >> $(APP_CONTENTS)/Info.plist
	@echo "🎨 生成应用图标..."
	@./create_icns.sh
	@echo "🔐 签名 App Bundle..."
	@codesign --force --deep --sign - $(APP_BUNDLE)
	@echo "🎉 App Bundle 创建完成: $(APP_BUNDLE)"

# 生成图标
icon:
	@echo "🎨 生成应用图标..."
	@./create_icns.sh

# 创建分发包
dist: bundle
	@echo "📦 创建分发包..."
	@mkdir -p dist
	@rm -rf dist/*
	@cp -R $(APP_BUNDLE) dist/
	@cd dist && hdiutil create -volname "L-Tools" -srcfolder $(APP_BUNDLE) -ov -format UDZO L-Tools.dmg
	@echo "🎉 分发包创建完成: dist/L-Tools.dmg"

# 运行应用
run: bundle
	@echo "🚀 启动 L-Tools..."
	@open $(APP_BUNDLE)

# 清理
clean:
	@echo "🧹 清理..."
	@rm -rf $(APP_BUNDLE) $(EXECUTABLE) Clips.app ClipsApp dist
	@echo "✅ 清理完成"

# 帮助
help:
	@echo "L-Tools Makefile 使用说明:"
	@echo "  make          - 编译并创建 App Bundle"
	@echo "  make build    - 仅编译可执行文件"
	@echo "  make bundle   - 创建完整的 App Bundle"
	@echo "  make icon     - 生成应用图标"
	@echo "  make dist     - 创建 DMG 分发包"
	@echo "  make run      - 编译并运行应用"
	@echo "  make clean    - 清理编译产物"
	@echo "  make help     - 显示帮助信息"
