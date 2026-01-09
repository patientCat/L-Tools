#!/bin/bash
# 创建 macOS .icns 图标文件

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SVG_FILE="$SCRIPT_DIR/icon.svg"
ICONSET_DIR="$SCRIPT_DIR/AppIcon.iconset"
ICNS_FILE="$SCRIPT_DIR/L-Tools.app/Contents/Resources/AppIcon.icns"

# 检查是否安装了必要工具
if ! command -v rsvg-convert &> /dev/null; then
    echo "正在使用 sips 转换（macOS 原生）..."
    USE_SIPS=1
else
    USE_SIPS=0
fi

# 创建 iconset 目录
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# 定义所需尺寸
sizes=(16 32 64 128 256 512)

if [ "$USE_SIPS" = "1" ]; then
    # 使用 qlmanage 将 SVG 转为 PNG（macOS 原生方式）
    echo "转换 SVG 到 PNG..."
    qlmanage -t -s 1024 -o "$SCRIPT_DIR" "$SVG_FILE" 2>/dev/null || true
    
    # 如果 qlmanage 失败，尝试使用 Python
    if [ ! -f "$SCRIPT_DIR/icon.svg.png" ]; then
        echo "使用备用方案..."
        # 创建简单的 PNG 使用 Python
        python3 << 'PYEOF'
import os
import subprocess

# 使用 cairosvg 如果可用
try:
    import cairosvg
    cairosvg.svg2png(url='/Users/luke/rust/clips/icon.svg', 
                     write_to='/Users/luke/rust/clips/icon_1024.png',
                     output_width=1024, output_height=1024)
    print("使用 cairosvg 转换成功")
except ImportError:
    print("cairosvg 不可用，跳过 PNG 转换")
    exit(1)
PYEOF
        BASE_PNG="$SCRIPT_DIR/icon_1024.png"
    else
        mv "$SCRIPT_DIR/icon.svg.png" "$SCRIPT_DIR/icon_1024.png"
        BASE_PNG="$SCRIPT_DIR/icon_1024.png"
    fi
    
    # 生成各尺寸
    for size in "${sizes[@]}"; do
        sips -z $size $size "$BASE_PNG" --out "$ICONSET_DIR/icon_${size}x${size}.png" 2>/dev/null
        double=$((size * 2))
        if [ $double -le 1024 ]; then
            sips -z $double $double "$BASE_PNG" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" 2>/dev/null
        fi
    done
else
    # 使用 rsvg-convert
    for size in "${sizes[@]}"; do
        rsvg-convert -w $size -h $size "$SVG_FILE" > "$ICONSET_DIR/icon_${size}x${size}.png"
        double=$((size * 2))
        rsvg-convert -w $double -h $double "$SVG_FILE" > "$ICONSET_DIR/icon_${size}x${size}@2x.png"
    done
fi

# 生成 icns 文件
echo "生成 icns 文件..."
mkdir -p "$(dirname "$ICNS_FILE")"
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"

# 清理
rm -rf "$ICONSET_DIR"
rm -f "$SCRIPT_DIR/icon_1024.png"

echo "图标已创建: $ICNS_FILE"
