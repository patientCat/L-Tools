#!/bin/bash
# 创建 macOS .icns 图标文件

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SVG_FILE="$SCRIPT_DIR/icon.svg"
PNG_FILE="$SCRIPT_DIR/icon.png"
ICONSET_DIR="$SCRIPT_DIR/AppIcon.iconset"
ICNS_FILE="$SCRIPT_DIR/L-Tools.app/Contents/Resources/AppIcon.icns"

# 创建 iconset 目录
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# 定义所需尺寸
sizes=(16 32 64 128 256 512)

# 检查是否有 PNG 图标文件
if [ -f "$PNG_FILE" ]; then
    echo "使用 PNG 图标: $PNG_FILE"
    BASE_PNG="$PNG_FILE"
elif [ -f "$SCRIPT_DIR/icon_1024.png" ]; then
    echo "使用 PNG 图标: icon_1024.png"
    BASE_PNG="$SCRIPT_DIR/icon_1024.png"
elif [ -f "$SVG_FILE" ]; then
    echo "从 SVG 转换图标..."
    # 检查是否安装了必要工具
    if ! command -v rsvg-convert &> /dev/null; then
        echo "正在使用 sips 转换（macOS 原生）..."
        USE_SIPS=1
    else
        USE_SIPS=0
    fi

    if [ "$USE_SIPS" = "1" ]; then
        # 使用 qlmanage 将 SVG 转为 PNG（macOS 原生方式）
        echo "转换 SVG 到 PNG..."
        qlmanage -t -s 1024 -o "$SCRIPT_DIR" "$SVG_FILE" 2>/dev/null || true
        
        if [ -f "$SCRIPT_DIR/icon.svg.png" ]; then
            mv "$SCRIPT_DIR/icon.svg.png" "$SCRIPT_DIR/icon_temp.png"
            BASE_PNG="$SCRIPT_DIR/icon_temp.png"
        else
            echo "SVG 转换失败"
            exit 1
        fi
    else
        # 使用 rsvg-convert
        rsvg-convert -w 1024 -h 1024 "$SVG_FILE" > "$SCRIPT_DIR/icon_temp.png"
        BASE_PNG="$SCRIPT_DIR/icon_temp.png"
    fi
else
    echo "错误: 未找到图标文件 (icon.png, icon_1024.png 或 icon.svg)"
    exit 1
fi

# 生成各尺寸
for size in "${sizes[@]}"; do
    sips -z $size $size "$BASE_PNG" --out "$ICONSET_DIR/icon_${size}x${size}.png" 2>/dev/null
    double=$((size * 2))
    if [ $double -le 1024 ]; then
        sips -z $double $double "$BASE_PNG" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" 2>/dev/null
    fi
done

# 生成 icns 文件
echo "生成 icns 文件..."
mkdir -p "$(dirname "$ICNS_FILE")"
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"

# 清理临时文件
rm -rf "$ICONSET_DIR"
rm -f "$SCRIPT_DIR/icon_temp.png"

echo "图标已创建: $ICNS_FILE"
