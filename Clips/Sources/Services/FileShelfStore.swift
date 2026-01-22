import Foundation
import Combine
import AppKit

class FileShelfStore: ObservableObject {
    @Published var files: [ShelvedFile] = []
    private let storageKey = "ClipsFileShelf"
    private let fileManager = FileManager.default
    
    private var shelfDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let shelfDir = appSupport.appendingPathComponent("Clips/Shelf")
        try? fileManager.createDirectory(at: shelfDir, withIntermediateDirectories: true)
        return shelfDir
    }
    
    init() {
        load()
    }
    
    func ingestFile(url: URL) {
        // Ensure destination directory exists
        let destinationDir = shelfDirectory
        let destinationURL = destinationDir.appendingPathComponent(url.lastPathComponent)
        
        // Handle name collision
        var finalDestinationURL = destinationURL
        var counter = 1
        while fileManager.fileExists(atPath: finalDestinationURL.path) {
            let fileName = url.deletingPathExtension().lastPathComponent
            let fileExt = url.pathExtension
            let newName = "\(fileName) \(counter).\(fileExt)"
            finalDestinationURL = destinationDir.appendingPathComponent(newName)
            counter += 1
        }
        
        do {
            // Move file
            try fileManager.moveItem(at: url, to: finalDestinationURL)
            print("📦 Moved file to shelf: \(finalDestinationURL.path)")
            
            // Add to model
            let newFile = ShelvedFile(url: finalDestinationURL)
            DispatchQueue.main.async {
                self.files.append(newFile)
                self.save()
            }
        } catch {
            print("❌ Failed to move file to shelf: \(error)")
        }
    }
    
    func removeFile(id: UUID) {
        if let index = files.firstIndex(where: { $0.id == id }) {
            let file = files[index]
            // We do NOT delete the file from disk when removing from list if it was dragged out?
            // Wait, if user clicks 'X', we should probably delete it from the shelf storage too.
            // If user drags it out, the system might have moved it or copied it.
            // For now, let's delete from disk to avoid orphans.
            try? fileManager.removeItem(at: file.url)
            
            files.remove(at: index)
            save()
        }
    }
    
    func clear() {
        // Remove all files from disk
        for file in files {
            try? fileManager.removeItem(at: file.url)
        }
        files.removeAll()
        save()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(files)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save shelf: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            files = try JSONDecoder().decode([ShelvedFile].self, from: data)
        } catch {
            print("Failed to load shelf: \(error)")
        }
    }
}
