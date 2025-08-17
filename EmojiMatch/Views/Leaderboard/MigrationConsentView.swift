import SwiftUI

struct MigrationConsentView: View {
    let gameHistory: [GameHistory]
    let onMigrate: () -> Void
    let onCancel: () -> Void
    let onDismiss: () -> Void
    
    @State private var isMigrating = false
    @State private var migrationProgress: Double = 0.0
    @State private var migrationComplete = false
    @State private var migrationFailed = false
    @State private var migratedLevels = 0
    @State private var currentLevel = 0
    
    // Calculate migration stats
    private var winningGames: [GameHistory] {
        gameHistory.filter { $0.isWin }
    }
    
    private var levelsToMigrate: Int {
        Set(winningGames.map { $0.level }).count
    }
    
    private var totalWins: Int {
        winningGames.count
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.9),
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.blue.opacity(0.9),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !isMigrating && !migrationComplete && !migrationFailed {
                            // Initial consent view
                            consentView
                        } else if isMigrating {
                            // Migration in progress view
                            migrationProgressView
                        } else if migrationComplete {
                            // Migration success view
                            migrationSuccessView
                        } else if migrationFailed {
                            // Migration failed view
                            migrationFailedView
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear {
            setupMigrationListeners()
        }
        .onDisappear {
            removeMigrationListeners()
        }
    }
    
    // MARK: - Consent View
    
    private var consentView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                }
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
                
                Text("Sync to Game Center")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Your local game progress is ready to sync!")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Stats card
            VStack(spacing: 16) {
                HStack {
                    StatItem(
                        icon: "trophy.fill",
                        title: "Levels Completed",
                        value: "\(levelsToMigrate)",
                        color: .yellow
                    )
                    
                    Spacer()
                    
                    StatItem(
                        icon: "checkmark.circle.fill",
                        title: "Total Wins",
                        value: "\(totalWins)",
                        color: .green
                    )
                }
                
                HStack {
                    StatItem(
                        icon: "clock.fill",
                        title: "Best Overall Time",
                        value: bestOverallTime,
                        color: .blue
                    )
                    
                    Spacer()
                    
                    StatItem(
                        icon: "flame.fill",
                        title: "Best Streak",
                        value: "\(bestStreak)",
                        color: .orange
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )

            
            // Buttons
            VStack(spacing: 12) {
                Button(action: startMigration) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Sync My Progress")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: cancelMigration) {
                    Text("Maybe Later")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Privacy note
            Text("Your data stays secure and private. You can disable this anytime in Settings.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Migration Progress View
    
    private var migrationProgressView: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: migrationProgress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.yellow, .orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: migrationProgress)
                    
                    Text("\(Int(migrationProgress * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Syncing Your Progress")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                if currentLevel > 0 {
                    Text("Uploading Level \(currentLevel)...")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("Preparing your data...")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Progress details
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Analyzing your game history")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Image(systemName: migratedLevels > 0 ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(migratedLevels > 0 ? .green : .white.opacity(0.3))
                    Text("Uploading best times (\(migratedLevels)/\(levelsToMigrate))")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    if migratedLevels == levelsToMigrate && levelsToMigrate > 0 {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                
                HStack {
                    Image(systemName: "circle")
                        .foregroundColor(.white.opacity(0.3))
                    Text("Finalizing sync")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            
            Text("Please keep the app open while we sync your data...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Migration Success View
    
    private var migrationSuccessView: some View {
        VStack(spacing: 32) {
            // Success animation
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                }
                .scaleEffect(1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: migrationComplete)
                
                Text("Sync Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your progress is now synced with Game Center")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Success stats
            VStack(spacing: 16) {
                HStack {
                    VStack(spacing: 4) {
                        Text("\(migratedLevels)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("Levels Synced")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("✅")
                            .font(.system(size: 24))
                        Text("Ready to Compete")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Text("Your best times are now on the global leaderboards!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Action button
            Button(action: onDismiss) {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Start Playing!")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.mint]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Migration Failed View
    
    private var migrationFailedView: some View {
        VStack(spacing: 32) {
            // Error state
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                }
                
                Text("Sync Incomplete")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Some of your data couldn't be synced right now")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Retry info
            VStack(spacing: 16) {
                Text("Don't worry! Your future games will sync automatically.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text("You can also try syncing again later from the leaderboards.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: startMigration) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Try Again")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onDismiss) {
                    Text("Continue Playing")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func StatItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    private func BenefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.yellow)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var bestOverallTime: String {
        if let bestGame = winningGames.min(by: { $0.timeToComplete < $1.timeToComplete }) {
            let minutes = Int(bestGame.timeToComplete) / 60
            let seconds = Int(bestGame.timeToComplete) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        return "--"
    }
    
    private var bestStreak: Int {
        winningGames.map { $0.matchStreak }.max() ?? 0
    }
    
    // MARK: - Actions
    
    private func startMigration() {
        isMigrating = true
        migrationProgress = 0.1
        onMigrate()
    }
    
    private func cancelMigration() {
        onCancel()
        onDismiss()
    }
    
    // MARK: - Migration Listeners
    
    private func setupMigrationListeners() {
        NotificationCenter.default.addObserver(
            forName: .gameCenterMigrationProgress,
            object: nil,
            queue: .main
        ) { notification in
            if let progress = notification.userInfo?["progress"] as? Double {
                migrationProgress = progress
            }
            if let level = notification.userInfo?["currentLevel"] as? Int {
                currentLevel = level
            }
            if let completed = notification.userInfo?["levelsCompleted"] as? Int {
                migratedLevels = completed
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .gameCenterMigrationCompleted,
            object: nil,
            queue: .main
        ) { notification in
            if let levelCount = notification.userInfo?["levelCount"] as? Int {
                migratedLevels = levelCount
            }
            migrationProgress = 1.0
            isMigrating = false
            migrationComplete = true
        }
        
        NotificationCenter.default.addObserver(
            forName: .gameCenterMigrationFailed,
            object: nil,
            queue: .main
        ) { _ in
            isMigrating = false
            migrationFailed = true
        }
    }
    
    private func removeMigrationListeners() {
        NotificationCenter.default.removeObserver(self, name: .gameCenterMigrationProgress, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gameCenterMigrationCompleted, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gameCenterMigrationFailed, object: nil)
    }
}
