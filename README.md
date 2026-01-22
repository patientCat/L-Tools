# Clips - macOS 剪贴板历史管理器

一个简洁的 macOS 菜单栏应用，用于管理和访问剪贴板历史记录。

## 功能特性

- 🔄 自动监控剪贴板变化
- 📋 保存剪贴板历史记录
- 🖱️ 点击菜单栏图标快速访问
- ⚡ 快速复制历史内容
- 🎨 原生 macOS 界面设计

## 安装和使用

### 方法 1: 下载 DMG 安装（推荐）

从 [GitHub Releases](https://github.com/patientCat/Clips/releases) 下载最新的 DMG 文件，双击安装即可使用。

如何安装
![步骤一](/resources/install_step1.png)
因为我不是苹果认证的开发者所以安装会弹出
![步骤二](/resources/install_step2.png)
请进行
![步骤三](/resources/install_step3.png)

### 方法 2: 直接运行
```bash
# 双击运行
open Clips.app
```

### 方法 2: 从源码构建
```bash
# 使用提供的构建脚本
./build_app.sh

# 或者手动构建
cd Clips
swift build -c release
```

## 使用说明

1. **启动应用**: 双击 `Clips.app` 或在终端运行 `open Clips.app`
2. **访问历史**: 点击菜单栏中的剪贴板图标
3. **复制内容**: 在弹出菜单中点击任意历史项目即可复制
4. **退出应用**: 在弹出菜单中选择"退出"

## 技术栈

- **语言**: Swift
- **框架**: SwiftUI + AppKit
- **平台**: macOS 12.0+
- **架构**: ARM64 (Apple Silicon)

## 项目结构

```
clips/
├── Clips/                  # Swift 源码目录
│   ├── Sources/            # 源代码文件
│   │   ├── ClipsApp.swift  # 主应用和 AppDelegate
│   │   ├── MenuBarView.swift # 菜单栏界面
│   │   ├── ClipboardService.swift # 剪贴板服务
│   │   ├── HistoryStore.swift # 历史记录存储
│   │   └── Models.swift    # 数据模型
│   ├── Package.swift      # Swift Package 配置
│   └── ClipsApp           # 编译后的可执行文件
├── Clips.app/             # macOS App Bundle
├── build_app.sh          # 构建脚本
└── README.md             # 说明文档
```

## 开发说明

### 构建要求
- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本 (包含 Swift 5.8+)

### 重新构建
```bash
# 使用构建脚本（推荐）
./build_app.sh

# 或手动构建
cd Clips
swift build -c release
```

## 许可证

版权所有 © 2024. 保留所有权利。