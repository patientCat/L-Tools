import SwiftUI

struct KeyValueView: View {
    @ObservedObject var kvStore: KeyValueStore
    var onCopyValue: (String) -> Void
    
    @State private var searchText: String = ""
    @State private var selectedTag: String? = nil
    @State private var showAddSheet: Bool = false
    @State private var editingItem: KeyValueItem? = nil
    
    var filteredItems: [KeyValueItem] {
        kvStore.search(searchText, filterTag: selectedTag)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> KEY_VAULT")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                Text("[\(kvStore.items.count)]")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.accent)
                Spacer()
                Button(action: { showAddSheet = true }) {
                    Text("[+ADD]")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.primary)
                }
                .buttonStyle(.plain)
                Button(action: { kvStore.clear() }) {
                    Text("[CLR]")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.danger)
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Tag filter bar
            if !kvStore.allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        PixelTagButton(
                            tag: "ALL",
                            isSelected: selectedTag == nil,
                            action: { selectedTag = nil }
                        )
                        
                        ForEach(kvStore.allTags, id: \.self) { tag in
                            PixelTagButton(
                                tag: tag.uppercased(),
                                isSelected: selectedTag == tag,
                                action: { selectedTag = selectedTag == tag ? nil : tag }
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .background(PixelTheme.headerBackground)
            }
            
            // Search bar
            HStack(spacing: 8) {
                Text(">")
                    .font(PixelTheme.pixelFont(size: 13))
                    .foregroundColor(PixelTheme.primary)
                TextField("SEARCH KEYS...", text: $searchText)
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
            
            if filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("╔══════════════════╗")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.border)
                    if searchText.isEmpty && selectedTag == nil {
                        Text("║   VAULT EMPTY    ║")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.textSecondary)
                        Text("║  [+] TO ADD KEY  ║")
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
                        ForEach(filteredItems) { item in
                            PixelKeyValueRow(
                                item: item,
                                onCopy: { onCopyValue(item.value) },
                                onEdit: { editingItem = item },
                                onDelete: { kvStore.remove(id: item.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
        .background(PixelTheme.background)
        .sheet(isPresented: $showAddSheet) {
            PixelAddKeyValueSheet(kvStore: kvStore, isPresented: $showAddSheet)
        }
        .sheet(item: $editingItem) { item in
            PixelEditKeyValueSheet(kvStore: kvStore, item: item, isPresented: Binding(
                get: { editingItem != nil },
                set: { if !$0 { editingItem = nil } }
            ))
        }
    }
}

// MARK: - Pixel Tag Button
struct PixelTagButton: View {
    let tag: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(PixelTheme.pixelFont(size: 10))
                .foregroundColor(isSelected ? PixelTheme.background : PixelTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Rectangle()
                        .fill(isSelected ? PixelTheme.accent : PixelTheme.accent.opacity(0.2))
                )
                .overlay(
                    Rectangle()
                        .stroke(PixelTheme.accent, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pixel Key Value Row
struct PixelKeyValueRow: View {
    let item: KeyValueItem
    var onCopy: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var isHovering = false
    @State private var showValue = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // Key
                Text(item.key)
                    .font(PixelTheme.pixelFontBold(size: 13))
                    .foregroundColor(PixelTheme.accent)
                    .lineLimit(1)
                
                Spacer()
                
                if isHovering {
                    HStack(spacing: 8) {
                        Button(action: onCopy) {
                            Text("[CPY]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(PixelTheme.secondary)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onEdit) {
                            Text("[EDT]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(PixelTheme.warning)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onDelete) {
                            Text("[DEL]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(PixelTheme.danger)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Description
            if !item.description.isEmpty {
                Text("> \(item.description)")
                    .font(PixelTheme.pixelFont(size: 11))
                    .foregroundColor(PixelTheme.textSecondary)
                    .lineLimit(1)
            }
            
            // Value
            HStack(spacing: 8) {
                Text("VAL:")
                    .font(PixelTheme.pixelFont(size: 11))
                    .foregroundColor(PixelTheme.textMuted)
                
                if showValue {
                    Text(item.value)
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.primary)
                        .lineLimit(1)
                } else {
                    Text(String(repeating: "*", count: min(item.value.count, 16)))
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textMuted)
                }
                
                Button(action: { showValue.toggle() }) {
                    Text(showValue ? "[HIDE]" : "[SHOW]")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(PixelTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            
            // Tags
            if !item.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(item.tags, id: \.self) { tag in
                        PixelTag(text: tag.uppercased(), color: PixelTheme.secondary)
                    }
                }
            }
        }
        .padding(10)
        .background(isHovering ? PixelTheme.primary.opacity(0.1) : PixelTheme.cardBackground)
        .pixelBorder(color: isHovering ? PixelTheme.primary : PixelTheme.border, width: 1)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Pixel Add Sheet
struct PixelAddKeyValueSheet: View {
    @ObservedObject var kvStore: KeyValueStore
    @Binding var isPresented: Bool
    
    @State private var key: String = ""
    @State private var value: String = ""
    @State private var description: String = ""
    @State private var tagsText: String = ""
    
    var tags: [String] {
        tagsText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("[ ADD NEW KEY ]")
                .font(PixelTheme.pixelFontBold(size: 16))
                .foregroundColor(PixelTheme.primary)
            
            PixelDivider()
            
            VStack(alignment: .leading, spacing: 12) {
                // Key field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> KEY *")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("ENTER_KEY_NAME", text: $key)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .padding(8)
                        .background(PixelTheme.background)
                        .pixelBorder()
                }
                
                // Value field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> VALUE *")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    SecureField("ENTER_SECRET_VALUE", text: $value)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .padding(8)
                        .background(PixelTheme.background)
                        .pixelBorder()
                }
                
                // Description field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> DESC")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("OPTIONAL_DESCRIPTION", text: $description)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .padding(8)
                        .background(PixelTheme.background)
                        .pixelBorder()
                }
                
                // Tags field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> TAGS")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("TAG1, TAG2, TAG3", text: $tagsText)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .padding(8)
                        .background(PixelTheme.background)
                        .pixelBorder()
                    
                    // Existing tags
                    if !kvStore.allTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                Text("EXISTING:")
                                    .font(PixelTheme.pixelFont(size: 10))
                                    .foregroundColor(PixelTheme.textMuted)
                                ForEach(kvStore.allTags, id: \.self) { tag in
                                    Button(action: {
                                        if !tags.contains(tag) {
                                            tagsText = tagsText.isEmpty ? tag : "\(tagsText), \(tag)"
                                        }
                                    }) {
                                        PixelTag(text: tag.uppercased(), color: PixelTheme.textSecondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            
            PixelDivider()
            
            // Buttons
            HStack {
                Button(action: { isPresented = false }) {
                    Text("[ CANCEL ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.textSecondary)
                }
                .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground))
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button(action: {
                    if !key.isEmpty && !value.isEmpty {
                        kvStore.add(key: key, value: value, description: description, tags: tags)
                        isPresented = false
                    }
                }) {
                    Text("[ SAVE ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(key.isEmpty || value.isEmpty ? PixelTheme.textMuted : PixelTheme.background)
                }
                .buttonStyle(PixelButtonStyle(
                    backgroundColor: key.isEmpty || value.isEmpty ? PixelTheme.cardBackground : PixelTheme.primary,
                    foregroundColor: key.isEmpty || value.isEmpty ? PixelTheme.textMuted : PixelTheme.background
                ))
                .keyboardShortcut(.return)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 400)
        .background(PixelTheme.background)
    }
}

// MARK: - Pixel Edit Sheet
struct PixelEditKeyValueSheet: View {
    @ObservedObject var kvStore: KeyValueStore
    let item: KeyValueItem
    @Binding var isPresented: Bool
    
    @State private var key: String = ""
    @State private var value: String = ""
    @State private var description: String = ""
    @State private var tagsText: String = ""
    
    var tags: [String] {
        tagsText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("[ EDIT KEY ]")
                .font(PixelTheme.pixelFontBold(size: 16))
                .foregroundColor(PixelTheme.warning)
            
            PixelDivider()
            
            VStack(alignment: .leading, spacing: 12) {
                // Key field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> KEY *")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("KEY", text: $key)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .padding(8)
                        .background(PixelTheme.background)
                        .pixelBorder()
                }
                
                // Value field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> VALUE *")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    SecureField("VALUE", text: $value)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .padding(8)
                        .background(PixelTheme.background)
                        .pixelBorder()
                }
                
                // Description field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> DESC")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("DESCRIPTION", text: $description)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .padding(8)
                        .background(PixelTheme.background)
                        .pixelBorder()
                }
                
                // Tags field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> TAGS")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("TAG1, TAG2", text: $tagsText)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .padding(8)
                        .background(PixelTheme.background)
                        .pixelBorder()
                    
                    // Existing tags
                    if !kvStore.allTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                Text("EXISTING:")
                                    .font(PixelTheme.pixelFont(size: 10))
                                    .foregroundColor(PixelTheme.textMuted)
                                ForEach(kvStore.allTags, id: \.self) { tag in
                                    Button(action: {
                                        if !tags.contains(tag) {
                                            tagsText = tagsText.isEmpty ? tag : "\(tagsText), \(tag)"
                                        }
                                    }) {
                                        PixelTag(text: tag.uppercased(), color: PixelTheme.textSecondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            
            PixelDivider()
            
            // Buttons
            HStack {
                Button(action: { isPresented = false }) {
                    Text("[ CANCEL ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.textSecondary)
                }
                .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground))
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button(action: {
                    if !key.isEmpty && !value.isEmpty {
                        kvStore.update(id: item.id, key: key, value: value, description: description, tags: tags)
                        isPresented = false
                    }
                }) {
                    Text("[ UPDATE ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(key.isEmpty || value.isEmpty ? PixelTheme.textMuted : PixelTheme.background)
                }
                .buttonStyle(PixelButtonStyle(
                    backgroundColor: key.isEmpty || value.isEmpty ? PixelTheme.cardBackground : PixelTheme.warning,
                    foregroundColor: key.isEmpty || value.isEmpty ? PixelTheme.textMuted : PixelTheme.background
                ))
                .keyboardShortcut(.return)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 400)
        .background(PixelTheme.background)
        .onAppear {
            key = item.key
            value = item.value
            description = item.description
            tagsText = item.tags.joined(separator: ", ")
        }
    }
}
