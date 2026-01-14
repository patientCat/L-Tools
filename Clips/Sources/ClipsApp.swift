import SwiftUI
import AppKit
import Carbon
import UserNotifications

@main
enum ClipsAppMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

// MARK: - Global Hotkey Manager
class HotkeyManager {
    static let shared = HotkeyManager()
    
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var callback: (() -> Void)?
    
    // 默认快捷键: Command + Shift + V
    private let defaultKeyCode: UInt32 = 9  // V 键
    private let defaultModifiers: UInt32 = UInt32(cmdKey | shiftKey)
    
    private init() {}
    
    func register(callback: @escaping () -> Void) {
        self.callback = callback
        
        // 注册事件处理器
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.callback?()
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
        
        if status != noErr {
            print("❌ 无法安装事件处理器: \(status)")
            return
        }
        
        // 注册热键 (Command + Shift + V)
        let hotKeyID = EventHotKeyID(signature: OSType(0x434C4950), id: 1)  // "CLIP"
        
        let registerStatus = RegisterEventHotKey(
            defaultKeyCode,
            defaultModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerStatus != noErr {
            print("❌ 无法注册热键: \(registerStatus)")
        } else {
            print("✅ 全局快捷键已注册: ⌘⇧V")
        }
    }
    
    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
    
    deinit {
        unregister()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover!
    var floatingWindow: NSWindow?
    var mainWindow: NSWindow?
    
    let clipboardService = ClipboardService()
    var historyStore: HistoryStore!
    let kvStore = KeyValueStore.shared
    let reminderStore = RestReminderStore.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置通知代理，确保前台也能显示通知
        UNUserNotificationCenter.current().delegate = self
        
        // Initialize Core Services
        historyStore = HistoryStore(clipboardService: clipboardService)
        
        // 先启动监控，确保能捕获剪贴板变化
        clipboardService.startMonitoring()
        
        // 创建主窗口
        createMainWindow()
        
        // 尝试创建状态栏图标
        setupStatusItem()
        
        // 注册全局快捷键 (Command + Shift + V)
        HotkeyManager.shared.register { [weak self] in
            DispatchQueue.main.async {
                self?.showFloatingWindow()
            }
        }
        
        // 请求辅助功能权限（用于全局快捷键）
        requestAccessibilityPermission()
        
        // 设置应用菜单（包含快捷键）
        setupMainMenu()
        
        // 激活应用
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func setupMainMenu() {
        let mainMenu = NSMenu()
        
        // 应用菜单
        let appMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        
        appMenu.addItem(NSMenuItem(title: "关于 L-Tools", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "隐藏 L-Tools", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"))
        appMenu.addItem(NSMenuItem(title: "隐藏其他", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem(title: "显示全部", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "退出 L-Tools", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        mainMenu.addItem(appMenuItem)
        
        // 文件菜单
        let fileMenu = NSMenu(title: "文件")
        let fileMenuItem = NSMenuItem()
        fileMenuItem.submenu = fileMenu
        
        let closeItem = NSMenuItem(title: "关闭窗口", action: #selector(closeCurrentWindow), keyEquivalent: "w")
        closeItem.target = self
        fileMenu.addItem(closeItem)
        
        mainMenu.addItem(fileMenuItem)
        
        // 窗口菜单
        let windowMenu = NSMenu(title: "窗口")
        let windowMenuItem = NSMenuItem()
        windowMenuItem.submenu = windowMenu
        
        windowMenu.addItem(NSMenuItem(title: "最小化", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"))
        
        mainMenu.addItem(windowMenuItem)
        
        NSApp.mainMenu = mainMenu
    }
    
    @objc func closeCurrentWindow() {
        if let window = NSApp.keyWindow {
            window.close()
        }
    }
    
    private func createMainWindow() {
        let menuView = MenuBarView(
            historyStore: historyStore,
            kvStore: kvStore,
            reminderStore: reminderStore,
            onCopy: { [weak self] content in
                self?.clipboardService.copyToClipboard(content)
            },
            onCopyImage: { [weak self] image in
                self?.clipboardService.copyImageToClipboard(image)
            },
            onQuit: {
                NSApplication.shared.terminate(nil)
            }
        )
        
        let hostingController = NSHostingController(rootView: menuView)
        
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 550),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        mainWindow?.contentViewController = hostingController
        mainWindow?.title = "L-Tools"
        mainWindow?.center()
        mainWindow?.makeKeyAndOrderFront(nil)
    }
    
    private func setupStatusItem() {
        // 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let statusItem = statusItem, let button = statusItem.button else {
            print("❌ 无法创建菜单栏按钮")
            return
        }
        
        // 使用系统图标
        if let image = NSImage(systemSymbolName: "wrench.and.screwdriver", accessibilityDescription: "L-Tools") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "L"
        }
        
        button.action = #selector(statusItemClicked(_:))
        button.target = self
        
        // 创建 Popover
        let menuView = MenuBarView(
            historyStore: historyStore,
            kvStore: kvStore,
            reminderStore: reminderStore,
            onCopy: { [weak self] content in
                self?.clipboardService.copyToClipboard(content)
                self?.closePopover(sender: nil)
            },
            onCopyImage: { [weak self] image in
                self?.clipboardService.copyImageToClipboard(image)
                self?.closePopover(sender: nil)
            },
            onQuit: {
                NSApplication.shared.terminate(nil)
            }
        )
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 450, height: 550)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: menuView)
        
        print("✅ 菜单栏图标已设置")
    }
    
    @objc func statusItemClicked(_ sender: AnyObject?) {
        togglePopover(sender)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregister()
    }
    
    private func requestAccessibilityPermission() {
        // 先检查是否已授权，不弹窗
        let trusted = AXIsProcessTrusted()
        if !trusted {
            // 只有未授权时才提示（设置 prompt: true）
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
            print("⚠️ 需要辅助功能权限才能使用全局快捷键")
        } else {
            print("✅ 辅助功能权限已授权")
        }
    }
    
    // MARK: - Floating Window (用于快捷键唤出)
    func showFloatingWindow() {
        if let window = floatingWindow, window.isVisible {
            closeFloatingWindow()
            return
        }
        
        let menuView = MenuBarView(
            historyStore: historyStore,
            kvStore: kvStore,
            reminderStore: reminderStore,
            onCopy: { [weak self] content in
                self?.clipboardService.copyToClipboard(content)
                self?.closeFloatingWindow()
            },
            onCopyImage: { [weak self] image in
                self?.clipboardService.copyImageToClipboard(image)
                self?.closeFloatingWindow()
            },
            onQuit: {
                NSApplication.shared.terminate(nil)
            }
        )
        
        let hostingController = NSHostingController(rootView: menuView)
        
        // 获取鼠标位置或屏幕中心
        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        
        let windowWidth: CGFloat = 450
        let windowHeight: CGFloat = 550
        
        // 计算窗口位置（在鼠标附近或屏幕中心）
        var windowX = mouseLocation.x - windowWidth / 2
        var windowY = mouseLocation.y - windowHeight / 2
        
        // 确保窗口在屏幕内
        windowX = max(screenFrame.minX + 10, min(windowX, screenFrame.maxX - windowWidth - 10))
        windowY = max(screenFrame.minY + 10, min(windowY, screenFrame.maxY - windowHeight - 10))
        
        let window = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.backgroundColor = NSColor.windowBackgroundColor
        window.isReleasedWhenClosed = false
        
        // 添加圆角
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 12
        window.contentView?.layer?.masksToBounds = true
        
        floatingWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // 监听窗口失去焦点时关闭
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResignKey(_:)),
            name: NSWindow.didResignKeyNotification,
            object: window
        )
    }
    
    @objc func windowDidResignKey(_ notification: Notification) {
        closeFloatingWindow()
    }
    
    func closeFloatingWindow() {
        if let window = floatingWindow {
            NotificationCenter.default.removeObserver(self, name: NSWindow.didResignKeyNotification, object: window)
            window.close()
            floatingWindow = nil
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let statusItem = statusItem, let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // 当应用在前台时也显示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 显示横幅、播放声音
        completionHandler([.banner, .sound])
    }
    
    // 用户点击通知时的处理
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // 激活应用
        NSApp.activate(ignoringOtherApps: true)
        completionHandler()
    }
}
