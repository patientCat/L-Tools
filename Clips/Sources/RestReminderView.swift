import SwiftUI

struct RestReminderView: View {
    @ObservedObject var store: RestReminderStore
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> WORK_TIMER")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                Spacer()
                
                // Status indicator
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(store.statusText.uppercased())
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(statusColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            PixelDivider()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Timer Display
                    timerDisplaySection
                        .padding(.top, 8)
                    
                    PixelDivider()
                        .padding(.horizontal, 12)
                    
                    // Settings
                    settingsSection
                        .padding(.horizontal, 12)
                    
                    PixelDivider()
                        .padding(.horizontal, 12)
                    
                    // Controls
                    controlsSection
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
            }
        }
        .background(PixelTheme.background)
    }
    
    // MARK: - Timer Display
    
    private var timerDisplaySection: some View {
        VStack(spacing: 16) {
            // ASCII art timer frame
            VStack(spacing: 0) {
                Text("╔════════════════════════╗")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                
                Text("║                        ║")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                
                HStack {
                    Text("║")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                    Spacer()
                    Text(store.formattedRemainingTime)
                        .font(PixelTheme.pixelFontBold(size: 36))
                        .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.accent)
                    Spacer()
                    Text("║")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                }
                .frame(width: 200)
                
                Text("║                        ║")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                
                Text("╚════════════════════════╝")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
            }
            
            // Mode label
            Text(store.isRestTime ? "[ REST MODE ]" : "[ WORK MODE ]")
                .font(PixelTheme.pixelFontBold(size: 14))
                .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
            
            // Progress bar
            VStack(spacing: 4) {
                PixelProgressBar(
                    progress: timerProgress,
                    foregroundColor: store.isRestTime ? PixelTheme.primary : PixelTheme.secondary,
                    height: 12
                )
                .frame(width: 200)
                
                Text("\(Int(timerProgress * 100))% COMPLETE")
                    .font(PixelTheme.pixelFont(size: 10))
                    .foregroundColor(PixelTheme.textMuted)
            }
            
            // Status message
            if store.isEnabled && store.isRunning {
                HStack(spacing: 4) {
                    Text(">")
                        .foregroundColor(PixelTheme.primary)
                    Text(store.isRestTime ? "TAKE A BREAK..." : "FOCUS MODE ACTIVE")
                        .foregroundColor(PixelTheme.textSecondary)
                }
                .font(PixelTheme.pixelFont(size: 11))
            }
        }
    }
    
    private var timerProgress: CGFloat {
        guard store.isRunning else { return 0 }
        
        let totalSeconds: Double
        if store.isRestTime {
            totalSeconds = Double(store.restDurationMinutes * 60)
        } else {
            totalSeconds = Double(store.workDurationMinutes * 60)
        }
        
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (CGFloat(store.remainingSeconds) / CGFloat(totalSeconds))
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("> SETTINGS")
                .font(PixelTheme.pixelFontBold(size: 12))
                .foregroundColor(PixelTheme.primary)
            
            // Enable toggle
            HStack {
                Text("ENABLED:")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.textSecondary)
                Spacer()
                Button(action: { store.isEnabled.toggle() }) {
                    Text(store.isEnabled ? "[ ON ]" : "[ OFF ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(store.isEnabled ? PixelTheme.primary : PixelTheme.danger)
                }
                .buttonStyle(.plain)
            }
            .padding(8)
            .background(PixelTheme.cardBackground)
            .pixelBorder()
            
            // Work duration
            HStack {
                Text("WORK_TIME:")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.textSecondary)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: { decrementWork() }) {
                        Text("[-]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                    
                    Text("\(store.workDurationMinutes) MIN")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.accent)
                        .frame(width: 70)
                    
                    Button(action: { incrementWork() }) {
                        Text("[+]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                }
            }
            .padding(8)
            .background(PixelTheme.cardBackground)
            .pixelBorder()
            .opacity(store.isEnabled ? 1 : 0.5)
            
            // Rest duration
            HStack {
                Text("REST_TIME:")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.textSecondary)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: { decrementRest() }) {
                        Text("[-]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.primary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                    
                    Text("\(store.restDurationMinutes) MIN")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.primary)
                        .frame(width: 70)
                    
                    Button(action: { incrementRest() }) {
                        Text("[+]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.primary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                }
            }
            .padding(8)
            .background(PixelTheme.cardBackground)
            .pixelBorder()
            .opacity(store.isEnabled ? 1 : 0.5)
        }
    }
    
    private let workOptions = [15, 20, 25, 30, 45, 60, 90]
    private let restOptions = [3, 5, 10, 15, 20]
    
    private func incrementWork() {
        if let idx = workOptions.firstIndex(of: store.workDurationMinutes), idx < workOptions.count - 1 {
            store.workDurationMinutes = workOptions[idx + 1]
        }
    }
    
    private func decrementWork() {
        if let idx = workOptions.firstIndex(of: store.workDurationMinutes), idx > 0 {
            store.workDurationMinutes = workOptions[idx - 1]
        }
    }
    
    private func incrementRest() {
        if let idx = restOptions.firstIndex(of: store.restDurationMinutes), idx < restOptions.count - 1 {
            store.restDurationMinutes = restOptions[idx + 1]
        }
    }
    
    private func decrementRest() {
        if let idx = restOptions.firstIndex(of: store.restDurationMinutes), idx > 0 {
            store.restDurationMinutes = restOptions[idx - 1]
        }
    }
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            Text("> CONTROLS")
                .font(PixelTheme.pixelFontBold(size: 12))
                .foregroundColor(PixelTheme.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                if store.isRunning {
                    // Pause button
                    Button(action: { store.pauseTimer() }) {
                        Text("[ PAUSE ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.warning)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground, foregroundColor: PixelTheme.warning))
                    
                    // Stop button
                    Button(action: { store.stopTimer() }) {
                        Text("[ STOP ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.danger)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground, foregroundColor: PixelTheme.danger))
                } else if store.remainingSeconds > 0 {
                    // Resume button
                    Button(action: { store.resumeTimer() }) {
                        Text("[ RESUME ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.primary, foregroundColor: PixelTheme.background))
                    
                    // Reset button
                    Button(action: { store.stopTimer() }) {
                        Text("[ RESET ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground, foregroundColor: PixelTheme.textSecondary))
                } else {
                    // Start button
                    Button(action: { store.startTimer() }) {
                        Text("[ START ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(store.isEnabled ? PixelTheme.background : PixelTheme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(
                        backgroundColor: store.isEnabled ? PixelTheme.primary : PixelTheme.cardBackground,
                        foregroundColor: store.isEnabled ? PixelTheme.background : PixelTheme.textMuted
                    ))
                    .disabled(!store.isEnabled)
                }
            }
            
            // Skip rest button
            if store.isRestTime {
                Button(action: { store.skipRest() }) {
                    Text(">> SKIP REST")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var statusColor: Color {
        if !store.isEnabled {
            return PixelTheme.textMuted
        } else if !store.isRunning {
            return PixelTheme.warning
        } else if store.isRestTime {
            return PixelTheme.primary
        } else {
            return PixelTheme.secondary
        }
    }
}
