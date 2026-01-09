import SwiftUI

enum ClipsTab: String, CaseIterable {
    case history = "剪贴板"
    case keyValue = "密钥"
}

struct MenuBarView: View {
    @ObservedObject var historyStore: HistoryStore
    @ObservedObject var kvStore: KeyValueStore
    var onCopy: (String) -> Void
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
            // Tab 切换
            HStack(spacing: 0) {
                ForEach(ClipsTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        HStack {
                            Image(systemName: tab == .history ? "doc.on.clipboard" : "key")
                            Text(tab.rawValue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedTab == tab ? Color.accentColor.opacity(0.2) : Color.clear)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 根据选中的 Tab 显示不同内容
            if selectedTab == .history {
                historyView
            } else {
                KeyValueView(kvStore: kvStore, onCopyValue: onCopy)
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Quit L-Tools") {
                    onQuit()
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 450, height: 500)
    }
    
    // MARK: - History View
    private var historyView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("剪贴板历史 (\(historyStore.history.count))")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Button("Clear") {
                    historyStore.clear()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(NSColor.textBackgroundColor))
            
            Divider()
            
            if filteredHistory.isEmpty {
                VStack {
                    Spacer()
                    if searchText.isEmpty {
                        Text("暂无剪贴板记录")
                            .foregroundColor(.secondary)
                        Text("复制内容后会自动显示")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("未找到匹配内容")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredHistory) { item in
                        ClipboardRow(item: item, onCopy: { onCopy(item.content) })
                    }
                }
            }
        }
    }
}

// MARK: - Clipboard Row
struct ClipboardRow: View {
    let item: ClipboardItem
    var onCopy: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: onCopy) {
            HStack {
                Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                if isHovering {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isHovering ? Color.accentColor.opacity(0.15) : Color.clear)
            .cornerRadius(6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
