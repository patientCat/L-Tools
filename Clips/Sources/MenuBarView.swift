import SwiftUI
import AppKit

enum ClipsTab: String, CaseIterable {
    case history = "CLIPS"
    case keyValue = "KEYS"
    case reminder = "TIMER"
}

struct MenuBarView: View {
    @ObservedObject var historyStore: HistoryStore
    @ObservedObject var kvStore: KeyValueStore
    @ObservedObject var reminderStore: RestReminderStore
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
            // Pixel-style header
            HStack {
                Text("[ L-TOOLS ]")
                    .font(PixelTheme.pixelFontBold(size: 16))
                    .foregroundColor(PixelTheme.primary)
                Spacer()
                // Decorative pixels
                HStack(spacing: 2) {
                    Rectangle().fill(PixelTheme.danger).frame(width: 8, height: 8)
                    Rectangle().fill(PixelTheme.accent).frame(width: 8, height: 8)
                    Rectangle().fill(PixelTheme.primary).frame(width: 8, height: 8)
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
                } else if selectedTab == .keyValue {
                    KeyValueView(kvStore: kvStore, onCopyValue: onCopy)
                } else {
                    RestReminderView(store: reminderStore)
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
        .frame(width: 450, height: 500)
    }
    
    // MARK: - Tab Icon
    private func tabIcon(for tab: ClipsTab) -> String {
        switch tab {
        case .history: return "doc.on.clipboard"
        case .keyValue: return "key"
        case .reminder: return "bell"
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
                                onCopy: {
                                    if item.contentType == .text {
                                        onCopy(item.content)
                                    } else if let image = item.image {
                                        onCopyImage?(image)
                                    }
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
            .foregroundColor(isSelected ? PixelTheme.background : PixelTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Rectangle()
                    .fill(isSelected ? PixelTheme.primary : PixelTheme.cardBackground)
            )
            .overlay(
                Rectangle()
                    .stroke(isSelected ? PixelTheme.primary : PixelTheme.border, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pixel Clipboard Row
struct PixelClipboardRow: View {
    let item: ClipboardItem
    var onCopy: () -> Void
    
    @State private var isHovering = false
    @State private var showPreview = false
    @State private var hoverTimer: Timer?
    
    var body: some View {
        Button(action: onCopy) {
            HStack(spacing: 8) {
                // Type indicator
                Text(item.contentType == .image ? "[IMG]" : "[TXT]")
                    .font(PixelTheme.pixelFont(size: 10))
                    .foregroundColor(item.contentType == .image ? PixelTheme.secondary : PixelTheme.accent)
                
                // Content
                if item.contentType == .image {
                    if let thumbnail = item.thumbnail(maxSize: 24) {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .pixelBorder(color: PixelTheme.border, width: 1)
                    }
                    Text(item.content)
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.textSecondary)
                        .lineLimit(1)
                } else {
                    Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                Spacer()
                
                if isHovering {
                    Text("[COPY]")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(PixelTheme.primary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isHovering ? PixelTheme.primary.opacity(0.15) : PixelTheme.cardBackground)
            .pixelBorder(color: isHovering ? PixelTheme.primary : PixelTheme.border, width: 1)
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
            
            if let image = item.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 280, maxHeight: 280)
                    .pixelBorder()
            }
            
            Text(item.content)
                .font(PixelTheme.pixelFont(size: 11))
                .foregroundColor(PixelTheme.textSecondary)
        }
        .padding(12)
        .background(PixelTheme.background)
    }
}
