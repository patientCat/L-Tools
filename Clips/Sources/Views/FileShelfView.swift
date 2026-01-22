import SwiftUI
import AppKit

struct FileShelfView: View {
    @ObservedObject var store: FileShelfStore
    @State private var selection = Set<UUID>()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> FILE_SHELF")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                Text("[\(store.files.count)]")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.accent)
                Spacer()
                Button(action: { store.clear() }) {
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
            
            // Content
            ZStack {
                // Background drop target
                Color.clear
                    .contentShape(Rectangle())
                    .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                    }

                if store.files.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        Text("╔══════════════════╗")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.border)
                        Text("║  DROP FILES HERE ║")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.textSecondary)
                        Text("╚══════════════════╝")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.border)
                        Spacer()
                    }
                    .allowsHitTesting(false)
                } else {
                    List(selection: $selection) {
                        ForEach(store.files) { file in
                            FileShelfRow(file: file)
                                .listRowBackground(
                                    selection.contains(file.id) ? 
                                    PixelTheme.primary.opacity(0.2) : Color.clear
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                .contextMenu {
                                    Button("Delete") {
                                        store.removeFile(id: file.id)
                                    }
                                }
                                .onDrag {
                                    return NSItemProvider(object: file.url as NSURL)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(PixelTheme.background)
                    .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    DispatchQueue.main.async {
                        store.ingestFile(url: url)
                    }
                }
            }
        }
        return true
    }
}

struct FileShelfRow: View {
    let file: ShelvedFile
    
    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: file.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text(file.url.lastPathComponent)
                .font(PixelTheme.pixelFont(size: 12))
                .foregroundColor(PixelTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}