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
            // 标题栏
            HStack {
                Text("密钥存储 (\(kvStore.items.count))")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                Button("清空") {
                    kvStore.clear()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            // 标签过滤栏
            if !kvStore.allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        // 全部标签
                        TagButton(
                            tag: "全部",
                            isSelected: selectedTag == nil,
                            action: { selectedTag = nil }
                        )
                        
                        ForEach(kvStore.allTags, id: \.self) { tag in
                            TagButton(
                                tag: tag,
                                isSelected: selectedTag == tag,
                                action: { selectedTag = selectedTag == tag ? nil : tag }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            }
            
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索 Key、Value、描述或标签...", text: $searchText)
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
            
            if filteredItems.isEmpty {
                VStack {
                    Spacer()
                    if searchText.isEmpty && selectedTag == nil {
                        Image(systemName: "key")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                        Text("暂无存储的密钥")
                            .foregroundColor(.secondary)
                        Text("点击 + 添加新的 Key-Value")
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
                    ForEach(filteredItems) { item in
                        KeyValueRow(
                            item: item,
                            onCopy: { onCopyValue(item.value) },
                            onEdit: { editingItem = item },
                            onDelete: { kvStore.remove(id: item.id) }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddKeyValueSheet(kvStore: kvStore, isPresented: $showAddSheet)
        }
        .sheet(item: $editingItem) { item in
            EditKeyValueSheet(kvStore: kvStore, item: item, isPresented: Binding(
                get: { editingItem != nil },
                set: { if !$0 { editingItem = nil } }
            ))
        }
    }
}

// MARK: - Tag Button
struct TagButton: View {
    let tag: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Key Value Row
struct KeyValueRow: View {
    let item: KeyValueItem
    var onCopy: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var isHovering = false
    @State private var showValue = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Key
                Text(item.key)
                    .font(.headline)
                    .lineLimit(1)
                
                // 描述（如果有）
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Value
                HStack {
                    if showValue {
                        Text(item.value)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text(String(repeating: "•", count: min(item.value.count, 12)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Button(action: { showValue.toggle() }) {
                        Image(systemName: showValue ? "eye.slash" : "eye")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                // 标签
                if !item.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.2))
                                .foregroundColor(.accentColor)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
            
            if isHovering {
                HStack(spacing: 8) {
                    Button(action: onCopy) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .help("复制 Value")
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(.plain)
                    .help("编辑")
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .help("删除")
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Add Sheet
struct AddKeyValueSheet: View {
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
            Text("添加新密钥")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Key *")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("输入 Key（如：github_token）", text: $key)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Value *")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入 Value（如：密码）", text: $value)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("描述")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("简要描述（可选）", text: $description)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("标签")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("用逗号分隔多个标签（如：工作,GitHub）", text: $tagsText)
                    .textFieldStyle(.roundedBorder)
                
                // 显示已有标签供快速选择
                if !kvStore.allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            Text("已有:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            ForEach(kvStore.allTags, id: \.self) { tag in
                                Button(action: {
                                    if !tags.contains(tag) {
                                        tagsText = tagsText.isEmpty ? tag : "\(tagsText), \(tag)"
                                    }
                                }) {
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.secondary.opacity(0.2))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            HStack {
                Button("取消") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("保存") {
                    if !key.isEmpty && !value.isEmpty {
                        kvStore.add(key: key, value: value, description: description, tags: tags)
                        isPresented = false
                    }
                }
                .keyboardShortcut(.return)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .padding()
        .frame(width: 380)
    }
}

// MARK: - Edit Sheet
struct EditKeyValueSheet: View {
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
            Text("编辑密钥")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Key *")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Key", text: $key)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Value *")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("Value", text: $value)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("描述")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("简要描述（可选）", text: $description)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("标签")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("用逗号分隔多个标签", text: $tagsText)
                    .textFieldStyle(.roundedBorder)
                
                // 显示已有标签供快速选择
                if !kvStore.allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            Text("已有:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            ForEach(kvStore.allTags, id: \.self) { tag in
                                Button(action: {
                                    if !tags.contains(tag) {
                                        tagsText = tagsText.isEmpty ? tag : "\(tagsText), \(tag)"
                                    }
                                }) {
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.secondary.opacity(0.2))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            HStack {
                Button("取消") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("保存") {
                    if !key.isEmpty && !value.isEmpty {
                        kvStore.update(id: item.id, key: key, value: value, description: description, tags: tags)
                        isPresented = false
                    }
                }
                .keyboardShortcut(.return)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .padding()
        .frame(width: 380)
        .onAppear {
            key = item.key
            value = item.value
            description = item.description
            tagsText = item.tags.joined(separator: ", ")
        }
    }
}
