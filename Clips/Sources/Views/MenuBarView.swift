import SwiftUI
import AppKit

enum ClipsTab: String, CaseIterable {
    case history = "CLIPS"
    case favorites = "FAVS"
    case keyValue = "KEYS"
    case json = "JSON"
    case reminder = "TIMER"
    case shelf = "SHELF"
}

struct MenuBarView: View {
    @ObservedObject var historyStore: HistoryStore
    @ObservedObject var kvStore: KeyValueStore
    @ObservedObject var reminderStore: RestReminderStore
    @ObservedObject var fileShelfStore: FileShelfStore
    var onCopy: (String) -> Void
    var onCopyImage: ((NSImage) -> Void)?
    var onQuit: () -> Void
    
    @State private var selectedTab: ClipsTab = .history
    @State private var searchText: String = ""
    
    var filteredHistory: [ClipboardItem] {
        if searchText.isEmpty {
            return historyStore.history
        }
        return historyStore.history.filter { 
            $0.content.localizedCaseInsensitiveContains(searchText) 
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Pixel-style header with glow effect
            HStack {
                Text("[ L-TOOLS ]")
                    .font(PixelTheme.pixelFontBold(size: 16))
                    .foregroundColor(PixelTheme.primary)
                    .shadow(color: PixelTheme.primary.opacity(0.5), radius: 4, x: 0, y: 0)
                Spacer()
                // Decorative pixels with glow
                HStack(spacing: 2) {
                    Rectangle().fill(PixelTheme.danger).frame(width: 8, height: 8)
                        .shadow(color: PixelTheme.danger.opacity(0.6), radius: 3)
                    Rectangle().fill(PixelTheme.accent).frame(width: 8, height: 8)
                        .shadow(color: PixelTheme.accent.opacity(0.6), radius: 3)
                    Rectangle().fill(PixelTheme.primary).frame(width: 8, height: 8)
                        .shadow(color: PixelTheme.primary.opacity(0.6), radius: 3)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(PixelTheme.headerBackground)
            
            PixelDivider(color: PixelTheme.primary)
            
            // Tab bar
            HStack(spacing: 4) {
                ForEach(ClipsTab.allCases, id: \.self) { tab in
                    PixelTabButton(
                        icon: tabIcon(for: tab),
                        title: tab.rawValue,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(PixelTheme.headerBackground)
            
            PixelDivider()
            
            // Content area
            ZStack {
                PixelTheme.background
                
                if selectedTab == .history {
                    historyView
                } else if selectedTab == .favorites {
                    favoritesView
                } else if selectedTab == .keyValue {
                    KeyValueView(kvStore: kvStore, onCopyValue: onCopy)
                } else if selectedTab == .json {
                    JsonFormatterView(onCopy: onCopy)
                } else if selectedTab == .reminder {
                    RestReminderView(store: reminderStore)
                } else {
                    FileShelfView(store: fileShelfStore)
                }
            }
            
            PixelDivider()
            
            // Footer
            HStack {
                Text("> READY_")
                    .font(PixelTheme.pixelFont(size: 11))
                    .foregroundColor(PixelTheme.textMuted)
                Spacer()
                Button(action: onQuit) {
                    Text("[ QUIT ]")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.danger)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(PixelTheme.headerBackground)
        }
        .background(PixelTheme.background)
        .frame(minWidth: 450, maxWidth: .infinity, minHeight: 550, maxHeight: .infinity)
    }
    
    // MARK: - Tab Icon
    private func tabIcon(for tab: ClipsTab) -> String {
        switch tab {
        case .history: return "doc.on.clipboard"
        case .favorites: return "star.fill"
        case .keyValue: return "key"
        case .json: return "curlybraces"
        case .reminder: return "bell"
        case .shelf: return "folder"
        }
    }
    
    // MARK: - History View
    private var historyView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> CLIPBOARD_HISTORY")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                Text("[\(historyStore.history.count)]")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.accent)
                Spacer()
                Button(action: { historyStore.clear() }) {
                    Text("[CLR]")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.danger)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Search bar
            HStack(spacing: 8) {
                Text(">")
                    .font(PixelTheme.pixelFont(size: 13))
                    .foregroundColor(PixelTheme.primary)
                TextField("SEARCH...", text: $searchText)
                    .font(PixelTheme.pixelFont(size: 13))
                    .foregroundColor(PixelTheme.textPrimary)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Text("[X]")
                            .font(PixelTheme.pixelFont(size: 11))
                            .foregroundColor(PixelTheme.danger)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(PixelTheme.cardBackground)
            .pixelBorder()
            .padding(.horizontal, 8)
            
            PixelDivider()
                .padding(.vertical, 4)
            
            if filteredHistory.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("╔══════════════════╗")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.border)
                    if searchText.isEmpty {
                        Text("║  NO DATA FOUND   ║")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.textSecondary)
                        Text("║  COPY TO START   ║")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.textMuted)
                    } else {
                        Text("║  NO MATCH FOUND  ║")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.textSecondary)
                    }
                    Text("╚══════════════════╝")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.border)
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredHistory) { item in
                            PixelClipboardRow(
                                item: item,
                                showFavoriteButton: true,
                                onCopy: {
                                    if item.contentType == .text {
                                        onCopy(item.content)
                                    } else if let image = item.image {
                                        onCopyImage?(image)
                                    }
                                },
                                onToggleFavorite: {
                                    historyStore.toggleFavorite(for: item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // MARK: - Favorites View
    private var favoritesView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> FAVORITES")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                Text("[\(historyStore.favorites.count)]")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.accent)
                Spacer()
                Button(action: { historyStore.clearFavorites() }) {
                    Text("[CLR]")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.danger)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            PixelDivider()
                .padding(.vertical, 4)
            
            if historyStore.favorites.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("╔══════════════════╗")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.border)
                    Text("║  NO FAVORITES    ║")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.textSecondary)
                    Text("║  STAR TO ADD     ║")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.textMuted)
                    Text("╚══════════════════╝")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.border)
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(historyStore.favorites) { item in
                            PixelClipboardRow(
                                item: item,
                                showFavoriteButton: true,
                                onCopy: {
                                    if item.contentType == .text {
                                        onCopy(item.content)
                                    } else if let image = item.image {
                                        onCopyImage?(image)
                                    }
                                },
                                onToggleFavorite: {
                                    historyStore.toggleFavorite(for: item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Pixel Tab Button
struct PixelTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(PixelTheme.pixelFont(size: 11))
            }
            .foregroundColor(isSelected ? PixelTheme.background : PixelTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Rectangle()
                    .fill(isSelected ? PixelTheme.primary : PixelTheme.cardBackground)
            )
            .overlay(
                Rectangle()
                    .stroke(isSelected ? PixelTheme.primary : PixelTheme.borderHighlight, lineWidth: 2)
            )
            .shadow(color: isSelected ? PixelTheme.primary.opacity(0.4) : .clear, radius: 4, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pixel Clipboard Row
struct PixelClipboardRow: View {
    let item: ClipboardItem
    let showFavoriteButton: Bool
    var onCopy: () -> Void
    var onToggleFavorite: (() -> Void)?
    
    @State private var isHovering = false
    @State private var showPreview = false
    @State private var hoverTimer: Timer?
    
    init(item: ClipboardItem, showFavoriteButton: Bool = false, onCopy: @escaping () -> Void, onToggleFavorite: (() -> Void)? = nil) {
        self.item = item
        self.showFavoriteButton = showFavoriteButton
        self.onCopy = onCopy
        self.onToggleFavorite = onToggleFavorite
    }
    
    var body: some View {
        Button(action: onCopy) {
            HStack(spacing: 8) {
                // Type indicator with glow
                Text(item.contentType == .image ? "[IMG]" : "[TXT]")
                    .font(PixelTheme.pixelFont(size: 10))
                    .foregroundColor(item.contentType == .image ? PixelTheme.secondary : PixelTheme.accent)
                    .shadow(color: (item.contentType == .image ? PixelTheme.secondary : PixelTheme.accent).opacity(0.5), radius: 2)
                
                // Content
                if item.contentType == .image {
                    if let thumbnail = item.thumbnail(maxSize: 24) {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .pixelBorder(color: PixelTheme.borderHighlight, width: 1)
                    }
                    Text(item.content)
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.textSecondary)
                        .lineLimit(3)
                } else {
                    Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.textPrimary)
                        .lineLimit(3)
                        .truncationMode(.tail)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if showFavoriteButton {
                        Button(action: {
                            onToggleFavorite?()
                        }) {
                            Image(systemName: item.isFavorite ? "star.fill" : "star")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(item.isFavorite ? PixelTheme.accent : PixelTheme.textSecondary)
                                .shadow(color: item.isFavorite ? PixelTheme.accent.opacity(0.6) : .clear, radius: 3)
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                    
                    if isHovering {
                        Text("[COPY]")
                            .font(PixelTheme.pixelFont(size: 10))
                            .foregroundColor(PixelTheme.primary)
                            .shadow(color: PixelTheme.primary.opacity(0.5), radius: 2)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .background(isHovering ? PixelTheme.primary.opacity(0.2) : PixelTheme.cardBackground)
            .pixelBorder(color: isHovering ? PixelTheme.primary : PixelTheme.borderHighlight, width: 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
            
            if item.contentType == .image {
                if hovering {
                    hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                        showPreview = true
                    }
                } else {
                    hoverTimer?.invalidate()
                    hoverTimer = nil
                    showPreview = false
                }
            }
        }
        .popover(isPresented: $showPreview, arrowEdge: .trailing) {
            PixelImagePreview(item: item)
        }
    }
}

// MARK: - Pixel Image Preview
struct PixelImagePreview: View {
    let item: ClipboardItem
    
    var body: some View {
        VStack(spacing: 8) {
            Text("[ IMAGE PREVIEW ]")
                .font(PixelTheme.pixelFontBold(size: 12))
                .foregroundColor(PixelTheme.primary)
                .shadow(color: PixelTheme.primary.opacity(0.5), radius: 3)
            
            if let image = item.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 280, maxHeight: 280)
                    .pixelBorder(color: PixelTheme.borderHighlight)
            }
            
            Text(item.content)
                .font(PixelTheme.pixelFont(size: 11))
                .foregroundColor(PixelTheme.textPrimary)
        }
        .padding(12)
        .background(PixelTheme.background)
    }
}
