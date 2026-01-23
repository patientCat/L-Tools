import SwiftUI
import AppKit

// MARK: - Theme Type
enum AppTheme: String, CaseIterable, Identifiable {
    case pixel = "Pixel"
    case terminal = "Terminal"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .pixel: return "Pixel Art"
        case .terminal: return "Terminal CLI"
        }
    }
    
    var description: String {
        switch self {
        case .pixel: return "复古像素艺术风格"
        case .terminal: return "终端命令行风格"
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    private let themeKey = "selectedTheme"
    
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
        }
    }
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .pixel // 默认主题
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
}

// MARK: - Unified Theme Protocol
// 提供统一的主题接口，方便视图使用
struct Theme {
    static var current: ThemeColors {
        switch ThemeManager.shared.currentTheme {
        case .pixel:
            return PixelThemeColors()
        case .terminal:
            return TerminalThemeColors()
        }
    }
}

protocol ThemeColors {
    var background: Color { get }
    var cardBackground: Color { get }
    var headerBackground: Color { get }
    var primary: Color { get }
    var secondary: Color { get }
    var accent: Color { get }
    var danger: Color { get }
    var warning: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textMuted: Color { get }
    var border: Color { get }
    var borderHighlight: Color { get }
    
    func font(size: CGFloat) -> Font
    func fontBold(size: CGFloat) -> Font
}

struct PixelThemeColors: ThemeColors {
    var background: Color { PixelTheme.background }
    var cardBackground: Color { PixelTheme.cardBackground }
    var headerBackground: Color { PixelTheme.headerBackground }
    var primary: Color { PixelTheme.primary }
    var secondary: Color { PixelTheme.secondary }
    var accent: Color { PixelTheme.accent }
    var danger: Color { PixelTheme.danger }
    var warning: Color { PixelTheme.warning }
    var textPrimary: Color { PixelTheme.textPrimary }
    var textSecondary: Color { PixelTheme.textSecondary }
    var textMuted: Color { PixelTheme.textMuted }
    var border: Color { PixelTheme.border }
    var borderHighlight: Color { PixelTheme.borderHighlight }
    
    func font(size: CGFloat) -> Font { PixelTheme.pixelFont(size: size) }
    func fontBold(size: CGFloat) -> Font { PixelTheme.pixelFontBold(size: size) }
}

struct TerminalThemeColors: ThemeColors {
    var background: Color { TerminalTheme.background }
    var cardBackground: Color { TerminalTheme.cardBackground }
    var headerBackground: Color { TerminalTheme.headerBackground }
    var primary: Color { TerminalTheme.primary }
    var secondary: Color { TerminalTheme.secondary }
    var accent: Color { TerminalTheme.accent }
    var danger: Color { TerminalTheme.danger }
    var warning: Color { TerminalTheme.warning }
    var textPrimary: Color { TerminalTheme.textPrimary }
    var textSecondary: Color { TerminalTheme.textSecondary }
    var textMuted: Color { TerminalTheme.textMuted }
    var border: Color { TerminalTheme.border }
    var borderHighlight: Color { TerminalTheme.borderHighlight }
    
    func font(size: CGFloat) -> Font { TerminalTheme.terminalFont(size: size) }
    func fontBold(size: CGFloat) -> Font { TerminalTheme.terminalFontBold(size: size) }
}

// MARK: - Theme Picker View
struct ThemePickerView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("$ theme --select")
                    .font(TerminalTheme.terminalFontBold(size: 14))
                    .foregroundColor(TerminalTheme.primary)
                Spacer()
                Button(action: { dismiss() }) {
                    Text("[×]")
                        .font(TerminalTheme.terminalFont(size: 14))
                        .foregroundColor(TerminalTheme.danger)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(TerminalTheme.headerBackground)
            
            Divider()
                .background(TerminalTheme.border)
            
            // Theme Options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(AppTheme.allCases) { theme in
                        ThemeOptionCard(
                            theme: theme,
                            isSelected: themeManager.currentTheme == theme,
                            onSelect: {
                                themeManager.setTheme(theme)
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .frame(width: 320, height: 280)
        .background(TerminalTheme.background)
    }
}

struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Preview circle
                Circle()
                    .fill(previewColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? TerminalTheme.primary : TerminalTheme.border, lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(theme.displayName)
                            .font(TerminalTheme.terminalFontBold(size: 13))
                            .foregroundColor(isSelected ? TerminalTheme.primary : TerminalTheme.textPrimary)
                        
                        if isSelected {
                            Text("[active]")
                                .font(TerminalTheme.terminalFont(size: 10))
                                .foregroundColor(TerminalTheme.primary)
                        }
                    }
                    
                    Text(theme.description)
                        .font(TerminalTheme.terminalFont(size: 11))
                        .foregroundColor(TerminalTheme.textMuted)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(TerminalTheme.primary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? TerminalTheme.primary.opacity(0.1) : TerminalTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? TerminalTheme.primary : TerminalTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    var previewColor: Color {
        switch theme {
        case .pixel:
            return PixelTheme.primary
        case .terminal:
            return TerminalTheme.primary
        }
    }
}
