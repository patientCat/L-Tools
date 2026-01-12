import SwiftUI
import AppKit

// MARK: - Pixel Art Theme
struct PixelTheme {
    // Pixel-style colors (retro game palette)
    static let background = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.2)
    static let headerBackground = Color(red: 0.12, green: 0.12, blue: 0.18)
    
    static let primary = Color(red: 0.4, green: 0.8, blue: 0.4)      // Green (like old terminals)
    static let secondary = Color(red: 0.3, green: 0.6, blue: 0.9)    // Blue
    static let accent = Color(red: 1.0, green: 0.8, blue: 0.2)       // Yellow/Gold
    static let danger = Color(red: 0.9, green: 0.3, blue: 0.3)       // Red
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.2)      // Orange
    
    static let textPrimary = Color(red: 0.9, green: 0.95, blue: 0.9)
    static let textSecondary = Color(red: 0.6, green: 0.65, blue: 0.6)
    static let textMuted = Color(red: 0.4, green: 0.45, blue: 0.4)
    
    static let border = Color(red: 0.3, green: 0.35, blue: 0.3)
    static let borderHighlight = Color(red: 0.5, green: 0.55, blue: 0.5)
    
    // Pixel font - use monospaced for that retro feel
    static func pixelFont(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static func pixelFontBold(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
}

// MARK: - Pixel Border Modifier
struct PixelBorder: ViewModifier {
    var color: Color = PixelTheme.border
    var width: CGFloat = 2
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .stroke(color, lineWidth: width)
            )
            .overlay(
                // Inner highlight (top-left)
                Rectangle()
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.5), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .padding(width)
            )
    }
}

// MARK: - Pixel Button Style
struct PixelButtonStyle: ButtonStyle {
    var backgroundColor: Color = PixelTheme.cardBackground
    var foregroundColor: Color = PixelTheme.textPrimary
    var isSmall: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PixelTheme.pixelFont(size: isSmall ? 11 : 13))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, isSmall ? 8 : 12)
            .padding(.vertical, isSmall ? 4 : 6)
            .background(
                ZStack {
                    Rectangle()
                        .fill(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
                    
                    // Pixel border effect
                    Rectangle()
                        .stroke(PixelTheme.border, lineWidth: 2)
                    
                    // Highlight on top/left
                    if !configuration.isPressed {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(PixelTheme.borderHighlight)
                                .frame(height: 2)
                            Spacer()
                        }
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(PixelTheme.borderHighlight)
                                .frame(width: 2)
                            Spacer()
                        }
                    }
                    
                    // Shadow on bottom/right when not pressed
                    if !configuration.isPressed {
                        VStack(spacing: 0) {
                            Spacer()
                            Rectangle()
                                .fill(Color.black.opacity(0.5))
                                .frame(height: 2)
                        }
                        HStack(spacing: 0) {
                            Spacer()
                            Rectangle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 2)
                        }
                    }
                }
            )
            .offset(y: configuration.isPressed ? 2 : 0)
    }
}

// MARK: - Pixel Card Modifier
struct PixelCard: ViewModifier {
    var backgroundColor: Color = PixelTheme.cardBackground
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .overlay(
                Rectangle()
                    .stroke(PixelTheme.border, lineWidth: 2)
            )
    }
}

// MARK: - Pixel Progress Bar
struct PixelProgressBar: View {
    var progress: CGFloat
    var foregroundColor: Color = PixelTheme.primary
    var backgroundColor: Color = PixelTheme.cardBackground
    var height: CGFloat = 16
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(backgroundColor)
                
                // Progress
                Rectangle()
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
                
                // Pixel segments overlay
                HStack(spacing: 2) {
                    ForEach(0..<Int(geometry.size.width / 8), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 2)
                    }
                }
            }
            .overlay(
                Rectangle()
                    .stroke(PixelTheme.border, lineWidth: 2)
            )
        }
        .frame(height: height)
    }
}

// MARK: - Pixel Tag
struct PixelTag: View {
    let text: String
    var color: Color = PixelTheme.accent
    var isSelected: Bool = false
    
    var body: some View {
        Text(text)
            .font(PixelTheme.pixelFont(size: 10))
            .foregroundColor(isSelected ? PixelTheme.background : color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Rectangle()
                    .fill(isSelected ? color : color.opacity(0.2))
            )
            .overlay(
                Rectangle()
                    .stroke(color, lineWidth: 1)
            )
    }
}

// MARK: - Pixel Divider
struct PixelDivider: View {
    var color: Color = PixelTheme.border
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 2)
    }
}

// MARK: - Pixel Icon (8-bit style symbols)
struct PixelIcon: View {
    let systemName: String
    var color: Color = PixelTheme.textPrimary
    var size: CGFloat = 16
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(color)
    }
}

// MARK: - View Extensions
extension View {
    func pixelBorder(color: Color = PixelTheme.border, width: CGFloat = 2) -> some View {
        modifier(PixelBorder(color: color, width: width))
    }
    
    func pixelCard(backgroundColor: Color = PixelTheme.cardBackground) -> some View {
        modifier(PixelCard(backgroundColor: backgroundColor))
    }
    
    func pixelText() -> some View {
        self.font(PixelTheme.pixelFont(size: 13))
            .foregroundColor(PixelTheme.textPrimary)
    }
    
    func pixelHeadline() -> some View {
        self.font(PixelTheme.pixelFontBold(size: 14))
            .foregroundColor(PixelTheme.primary)
    }
    
    func pixelCaption() -> some View {
        self.font(PixelTheme.pixelFont(size: 11))
            .foregroundColor(PixelTheme.textSecondary)
    }
}

// MARK: - Pixel Text Field Style
struct PixelTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(PixelTheme.pixelFont(size: 13))
            .foregroundColor(PixelTheme.textPrimary)
            .padding(8)
            .background(PixelTheme.background)
            .overlay(
                Rectangle()
                    .stroke(PixelTheme.border, lineWidth: 2)
            )
    }
}

// MARK: - Blinking Cursor Effect
struct BlinkingCursor: View {
    @State private var isVisible = true
    
    var body: some View {
        Rectangle()
            .fill(PixelTheme.primary)
            .frame(width: 8, height: 16)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    isVisible.toggle()
                }
            }
    }
}
