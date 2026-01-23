import SwiftUI
import AppKit

// MARK: - Terminal Theme (CLI/SkillsMP Inspired Style)
// 灵感来源: skillsmp.com - 终端/命令行风格设计
struct TerminalTheme {
    // 深色背景 - 类似 IDE/终端的配色
    static let background = Color(red: 0.06, green: 0.06, blue: 0.08)         // 接近纯黑
    static let cardBackground = Color(red: 0.09, green: 0.09, blue: 0.11)     // 稍亮的深色
    static let headerBackground = Color(red: 0.07, green: 0.07, blue: 0.09)   // 头部背景
    static let inputBackground = Color(red: 0.04, green: 0.04, blue: 0.06)    // 输入框背景
    
    // 主色调 - 终端绿色
    static let primary = Color(red: 0.0, green: 0.85, blue: 0.45)             // 经典终端绿
    static let primaryBright = Color(red: 0.2, green: 1.0, blue: 0.55)        // 高亮绿
    static let secondary = Color(red: 0.35, green: 0.75, blue: 0.95)          // 链接蓝
    static let accent = Color(red: 1.0, green: 0.85, blue: 0.3)               // 警告/高亮黄
    static let danger = Color(red: 0.95, green: 0.35, blue: 0.35)             // 错误红
    static let warning = Color(red: 1.0, green: 0.65, blue: 0.2)              // 橙色警告
    static let string = Color(red: 0.9, green: 0.6, blue: 0.4)                // 字符串色（橙棕）
    static let comment = Color(red: 0.45, green: 0.5, blue: 0.55)             // 注释灰
    
    // 文字颜色
    static let textPrimary = Color(red: 0.92, green: 0.93, blue: 0.94)        // 主文字（浅灰白）
    static let textSecondary = Color(red: 0.7, green: 0.72, blue: 0.74)       // 次要文字
    static let textMuted = Color(red: 0.45, green: 0.48, blue: 0.5)           // 暗淡文字
    static let textCode = Color(red: 0.8, green: 0.85, blue: 0.8)             // 代码文字（略带绿）
    
    // 边框
    static let border = Color(red: 0.2, green: 0.22, blue: 0.25)
    static let borderHighlight = Color(red: 0.3, green: 0.35, blue: 0.38)
    static let borderActive = Color(red: 0.0, green: 0.65, blue: 0.4)         // 活跃边框（绿）
    
    // 等宽字体 - 终端风格
    static func terminalFont(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
    
    static func terminalFontBold(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
    
    static func terminalFontLight(size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .monospaced)
    }
}

// MARK: - Terminal Border Modifier
struct TerminalBorder: ViewModifier {
    var color: Color = TerminalTheme.border
    var width: CGFloat = 1
    var cornerRadius: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: width)
            )
    }
}

// MARK: - Terminal Button Style
struct TerminalButtonStyle: ButtonStyle {
    var backgroundColor: Color = TerminalTheme.cardBackground
    var foregroundColor: Color = TerminalTheme.textPrimary
    var isSmall: Bool = false
    var isDestructive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TerminalTheme.terminalFont(size: isSmall ? 11 : 13))
            .foregroundColor(isDestructive ? TerminalTheme.danger : foregroundColor)
            .padding(.horizontal, isSmall ? 8 : 12)
            .padding(.vertical, isSmall ? 4 : 6)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isPressed ? backgroundColor.opacity(0.6) : backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        configuration.isPressed 
                            ? TerminalTheme.primary.opacity(0.5) 
                            : TerminalTheme.border,
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Terminal Card Modifier
struct TerminalCard: ViewModifier {
    var backgroundColor: Color = TerminalTheme.cardBackground
    var cornerRadius: CGFloat = 6
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(TerminalTheme.border, lineWidth: 1)
            )
    }
}

// MARK: - Terminal Progress Bar
struct TerminalProgressBar: View {
    var progress: CGFloat
    var foregroundColor: Color = TerminalTheme.primary
    var backgroundColor: Color = TerminalTheme.inputBackground
    var height: CGFloat = 6
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                
                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: height)
    }
}

// MARK: - Terminal Tag
struct TerminalTag: View {
    let text: String
    var color: Color = TerminalTheme.primary
    var isSelected: Bool = false
    
    var body: some View {
        Text(text)
            .font(TerminalTheme.terminalFont(size: 10))
            .foregroundColor(isSelected ? TerminalTheme.background : color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(isSelected ? color : color.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
    }
}

// MARK: - Terminal Divider
struct TerminalDivider: View {
    var color: Color = TerminalTheme.border
    var style: DividerStyle = .solid
    
    enum DividerStyle {
        case solid
        case dashed
        case comment  // 类似 // ----------
    }
    
    var body: some View {
        switch style {
        case .solid:
            Rectangle()
                .fill(color)
                .frame(height: 1)
        case .dashed:
            HStack(spacing: 4) {
                ForEach(0..<40, id: \.self) { _ in
                    Rectangle()
                        .fill(color)
                        .frame(width: 8, height: 1)
                }
            }
        case .comment:
            HStack(spacing: 4) {
                Text("//")
                    .font(TerminalTheme.terminalFont(size: 10))
                    .foregroundColor(TerminalTheme.comment)
                Rectangle()
                    .fill(color)
                    .frame(height: 1)
            }
        }
    }
}

// MARK: - Terminal Icon
struct TerminalIcon: View {
    let systemName: String
    var color: Color = TerminalTheme.textPrimary
    var size: CGFloat = 14
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .medium))
            .foregroundColor(color)
    }
}

// MARK: - Terminal Prompt
struct TerminalPrompt: View {
    var symbol: String = "$"
    var color: Color = TerminalTheme.primary
    
    var body: some View {
        Text(symbol)
            .font(TerminalTheme.terminalFontBold(size: 13))
            .foregroundColor(color)
    }
}

// MARK: - Terminal Command Text
struct TerminalCommand: View {
    let command: String
    var arguments: String? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            Text(command)
                .font(TerminalTheme.terminalFontBold(size: 12))
                .foregroundColor(TerminalTheme.secondary)
            if let args = arguments {
                Text(args)
                    .font(TerminalTheme.terminalFont(size: 12))
                    .foregroundColor(TerminalTheme.textSecondary)
            }
        }
    }
}

// MARK: - Blinking Terminal Cursor
struct TerminalCursor: View {
    @State private var isVisible = true
    var color: Color = TerminalTheme.primary
    var width: CGFloat = 8
    var height: CGFloat = 16
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: height)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isVisible.toggle()
                }
            }
    }
}

// MARK: - Terminal Code Block
struct TerminalCodeBlock: View {
    let code: String
    var language: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let lang = language {
                HStack {
                    Text("// \(lang)")
                        .font(TerminalTheme.terminalFont(size: 10))
                        .foregroundColor(TerminalTheme.comment)
                    Spacer()
                }
            }
            
            Text(code)
                .font(TerminalTheme.terminalFont(size: 12))
                .foregroundColor(TerminalTheme.textCode)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(TerminalTheme.inputBackground)
                .terminalBorder()
        }
    }
}

// MARK: - Terminal Status Indicator
struct TerminalStatus: View {
    let status: Status
    var text: String? = nil
    
    enum Status {
        case success
        case error
        case warning
        case info
        case loading
    }
    
    var statusColor: Color {
        switch status {
        case .success: return TerminalTheme.primary
        case .error: return TerminalTheme.danger
        case .warning: return TerminalTheme.warning
        case .info: return TerminalTheme.secondary
        case .loading: return TerminalTheme.accent
        }
    }
    
    var statusSymbol: String {
        switch status {
        case .success: return "✓"
        case .error: return "✗"
        case .warning: return "!"
        case .info: return "i"
        case .loading: return "◌"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text("[\(statusSymbol)]")
                .font(TerminalTheme.terminalFontBold(size: 11))
                .foregroundColor(statusColor)
            
            if let text = text {
                Text(text)
                    .font(TerminalTheme.terminalFont(size: 11))
                    .foregroundColor(TerminalTheme.textSecondary)
            }
        }
    }
}

// MARK: - View Extensions for Terminal Theme
extension View {
    func terminalBorder(color: Color = TerminalTheme.border, width: CGFloat = 1, cornerRadius: CGFloat = 4) -> some View {
        modifier(TerminalBorder(color: color, width: width, cornerRadius: cornerRadius))
    }
    
    func terminalCard(backgroundColor: Color = TerminalTheme.cardBackground, cornerRadius: CGFloat = 6) -> some View {
        modifier(TerminalCard(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
    
    func terminalText() -> some View {
        self.font(TerminalTheme.terminalFont(size: 13))
            .foregroundColor(TerminalTheme.textPrimary)
    }
    
    func terminalHeadline() -> some View {
        self.font(TerminalTheme.terminalFontBold(size: 14))
            .foregroundColor(TerminalTheme.primary)
    }
    
    func terminalCaption() -> some View {
        self.font(TerminalTheme.terminalFont(size: 11))
            .foregroundColor(TerminalTheme.textSecondary)
    }
    
    func terminalComment() -> some View {
        self.font(TerminalTheme.terminalFont(size: 11))
            .foregroundColor(TerminalTheme.comment)
    }
}

// MARK: - Terminal Text Field Style
struct TerminalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 6) {
            Text(">")
                .font(TerminalTheme.terminalFontBold(size: 13))
                .foregroundColor(TerminalTheme.primary)
            
            configuration
                .font(TerminalTheme.terminalFont(size: 13))
                .foregroundColor(TerminalTheme.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(TerminalTheme.inputBackground)
        .terminalBorder(color: TerminalTheme.border)
    }
}

// MARK: - Terminal Section Header
struct TerminalSectionHeader: View {
    let title: String
    var count: Int? = nil
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            Text("$")
                .font(TerminalTheme.terminalFontBold(size: 12))
                .foregroundColor(TerminalTheme.primary)
            
            if let iconName = icon {
                Image(systemName: iconName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(TerminalTheme.secondary)
            }
            
            Text(title)
                .font(TerminalTheme.terminalFontBold(size: 12))
                .foregroundColor(TerminalTheme.textPrimary)
            
            if let count = count {
                Text("(\(count))")
                    .font(TerminalTheme.terminalFont(size: 11))
                    .foregroundColor(TerminalTheme.accent)
            }
            
            Spacer()
        }
    }
}

// MARK: - Terminal Empty State
struct TerminalEmptyState: View {
    let message: String
    var submessage: String? = nil
    
    var body: some View {
        VStack(spacing: 8) {
            Text("/*")
                .font(TerminalTheme.terminalFont(size: 12))
                .foregroundColor(TerminalTheme.comment)
            
            Text(message)
                .font(TerminalTheme.terminalFont(size: 12))
                .foregroundColor(TerminalTheme.textSecondary)
            
            if let sub = submessage {
                Text(sub)
                    .font(TerminalTheme.terminalFont(size: 11))
                    .foregroundColor(TerminalTheme.textMuted)
            }
            
            Text("*/")
                .font(TerminalTheme.terminalFont(size: 12))
                .foregroundColor(TerminalTheme.comment)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
