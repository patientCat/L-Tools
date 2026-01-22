import Foundation
import AppKit

enum ClipboardContentType: String, Codable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let contentType: ClipboardContentType
    let content: String  // 文本内容或图片描述
    let imageData: Data? // 图片数据（PNG格式）
    let timestamp: Date
    var isFavorite: Bool = false  // 收藏状态
    
    // 文本初始化
    init(id: UUID = UUID(), content: String, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.contentType = .text
        self.content = content
        self.imageData = nil
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
    
    // 图片初始化
    init(id: UUID = UUID(), image: NSImage, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.contentType = .image
        
        // 生成图片描述
        let size = image.size
        self.content = "图片 \(Int(size.width))×\(Int(size.height))"
        
        // 转换为 PNG 数据
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            self.imageData = pngData
        } else {
            self.imageData = nil
        }
        
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
    
    // 获取 NSImage（用于显示）
    var image: NSImage? {
        guard contentType == .image, let data = imageData else { return nil }
        return NSImage(data: data)
    }
    
    // 生成缩略图
    func thumbnail(maxSize: CGFloat = 60) -> NSImage? {
        guard let originalImage = image else { return nil }
        
        let originalSize = originalImage.size
        let scale = min(maxSize / originalSize.width, maxSize / originalSize.height, 1.0)
        let newSize = NSSize(width: originalSize.width * scale, height: originalSize.height * scale)
        
        let thumbnail = NSImage(size: newSize)
        thumbnail.lockFocus()
        originalImage.draw(in: NSRect(origin: .zero, size: newSize),
                          from: NSRect(origin: .zero, size: originalSize),
                          operation: .copy,
                          fraction: 1.0)
        thumbnail.unlockFocus()
        
        return thumbnail
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        if lhs.contentType != rhs.contentType { return false }
        switch lhs.contentType {
        case .text:
            return lhs.content == rhs.content
        case .image:
            return lhs.imageData == rhs.imageData
        }
    }
}

struct ShelvedFile: Identifiable, Codable, Equatable {
    let id: UUID
    let url: URL
    let addedDate: Date
    
    init(id: UUID = UUID(), url: URL, addedDate: Date = Date()) {
        self.id = id
        self.url = url
        self.addedDate = addedDate
    }
}
