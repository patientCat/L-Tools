import Foundation

struct KeyValueItem: Identifiable, Codable, Equatable {
    let id: UUID
    var key: String
    var value: String
    var description: String
    var tags: [String]
    let createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), key: String, value: String, description: String = "", tags: [String] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.key = key
        self.value = value
        self.description = description
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

class KeyValueStore: ObservableObject {
    static let shared = KeyValueStore()
    
    private let storageKey = "ClipsKVStore"
    @Published private(set) var items: [KeyValueItem] = []
    
    // 所有已使用的标签
    var allTags: [String] {
        Array(Set(items.flatMap { $0.tags })).sorted()
    }
    
    private init() {
        load()
    }
    
    // MARK: - CRUD 操作
    
    func add(key: String, value: String, description: String = "", tags: [String] = []) {
        // 如果 key 已存在，则更新
        if let index = items.firstIndex(where: { $0.key == key }) {
            items[index].value = value
            items[index].description = description
            items[index].tags = tags
            items[index].updatedAt = Date()
        } else {
            let item = KeyValueItem(key: key, value: value, description: description, tags: tags)
            items.insert(item, at: 0)
        }
        save()
    }
    
    func get(_ key: String) -> String? {
        return items.first(where: { $0.key == key })?.value
    }
    
    func search(_ query: String, filterTag: String? = nil) -> [KeyValueItem] {
        var result = items
        
        // 按标签过滤
        if let tag = filterTag, !tag.isEmpty {
            result = result.filter { $0.tags.contains(tag) }
        }
        
        // 按关键词搜索
        if !query.isEmpty {
            result = result.filter {
                $0.key.localizedCaseInsensitiveContains(query) ||
                $0.value.localizedCaseInsensitiveContains(query) ||
                $0.description.localizedCaseInsensitiveContains(query) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(query) })
            }
        }
        
        return result
    }
    
    func update(id: UUID, key: String, value: String, description: String = "", tags: [String] = []) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].key = key
            items[index].value = value
            items[index].description = description
            items[index].tags = tags
            items[index].updatedAt = Date()
            save()
        }
    }
    
    func remove(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }
    
    func clear() {
        items.removeAll()
        save()
    }
    
    // MARK: - 持久化
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("❌ 保存 KV 存储失败: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            items = try JSONDecoder().decode([KeyValueItem].self, from: data)
        } catch {
            print("❌ 加载 KV 存储失败: \(error)")
        }
    }
}
