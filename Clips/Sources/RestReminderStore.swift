import Foundation
import UserNotifications

class RestReminderStore: ObservableObject {
    static let shared = RestReminderStore()
    
    private let storageKey = "RestReminderSettings"
    
    // Settings
    @Published var isEnabled: Bool = false {
        didSet { save(); updateTimer() }
    }
    @Published var workDurationMinutes: Int = 30 {
        didSet { save(); updateTimer() }
    }
    @Published var restDurationMinutes: Int = 5 {
        didSet { save() }
    }
    
    // Timer state
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var isRestTime: Bool = false
    
    private var timer: Timer?
    private var notificationAuthorized: Bool = false
    
    private init() {
        load()
        requestNotificationPermission()
    }
    
    // MARK: - Notification Permission
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationAuthorized = granted
                if let error = error {
                    print("❌ 通知权限请求失败: \(error)")
                } else if granted {
                    print("✅ 通知权限已授权")
                } else {
                    print("⚠️ 通知权限被拒绝")
                }
            }
        }
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
        guard isEnabled else { return }
        
        isRunning = true
        isRestTime = false
        remainingSeconds = workDurationMinutes * 60
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        print("⏱️ 工作计时开始: \(workDurationMinutes) 分钟")
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingSeconds = 0
        isRestTime = false
        
        // Cancel pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        print("⏹️ 计时已停止")
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        print("⏸️ 计时已暂停")
    }
    
    func resumeTimer() {
        guard remainingSeconds > 0 else {
            startTimer()
            return
        }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        print("▶️ 计时已恢复")
    }
    
    func skipRest() {
        guard isRestTime else { return }
        startTimer()
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            if isRestTime {
                // Rest finished, start work again
                sendNotification(title: "休息结束", body: "开始新一轮工作吧！💪")
                startTimer()
            } else {
                // Work finished, time to rest
                sendNotification(title: "该休息了！", body: "你已经工作了 \(workDurationMinutes) 分钟，休息 \(restDurationMinutes) 分钟吧 ☕️")
                startRestTimer()
            }
            return
        }
        
        remainingSeconds -= 1
    }
    
    private func startRestTimer() {
        isRestTime = true
        remainingSeconds = restDurationMinutes * 60
        print("☕️ 休息时间开始: \(restDurationMinutes) 分钟")
    }
    
    private func updateTimer() {
        if isEnabled && !isRunning {
            startTimer()
        } else if !isEnabled && isRunning {
            stopTimer()
        }
    }
    
    // MARK: - Notification
    
    private func sendNotification(title: String, body: String) {
        guard notificationAuthorized else {
            print("⚠️ 无通知权限，无法发送通知")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // Immediate delivery
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 发送通知失败: \(error)")
            }
        }
    }
    
    // MARK: - Formatting
    
    var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var statusText: String {
        if !isEnabled {
            return "未启用"
        } else if !isRunning {
            return "已暂停"
        } else if isRestTime {
            return "休息中"
        } else {
            return "工作中"
        }
    }
    
    // MARK: - Persistence
    
    private func save() {
        let settings: [String: Any] = [
            "isEnabled": isEnabled,
            "workDurationMinutes": workDurationMinutes,
            "restDurationMinutes": restDurationMinutes
        ]
        UserDefaults.standard.set(settings, forKey: storageKey)
    }
    
    private func load() {
        guard let settings = UserDefaults.standard.dictionary(forKey: storageKey) else { return }
        
        if let enabled = settings["isEnabled"] as? Bool {
            isEnabled = enabled
        }
        if let work = settings["workDurationMinutes"] as? Int {
            workDurationMinutes = work
        }
        if let rest = settings["restDurationMinutes"] as? Int {
            restDurationMinutes = rest
        }
    }
}
