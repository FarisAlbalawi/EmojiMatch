@preconcurrency import GameKit
import SwiftUI

class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()
    
    @Published var isAuthenticated = false
    @Published var localPlayer = GKLocalPlayer.local
    @Published var isLoading = false
    
    // Migration tracking properties
    private let migrationConsentDeclinedKey = "GameCenter_MigrationDeclined_v1_5"
    private let hasMigratedToGameCenterKey = "GameCenter_HasMigrated_v1_5"
    private let appVersionKey = "GameCenter_LastMigratedVersion"
    private let migrationInProgressKey = "GameCenter_MigrationInProgress"
    
    // Current app version for migration
    private let currentAppVersion = "1.5"
    
    // Leaderboard IDs for each level
    private let leaderboardIDs: [Int: String] = [
        1: "com.emojimatch.level1_best_time",
        2: "com.emojimatch.level2_best_time",
        3: "com.emojimatch.level3_best_time",
        4: "com.emojimatch.level4_best_time",
        5: "com.emojimatch.level5_best_time",
        6: "com.emojimatch.level6_best_time",
        7: "com.emojimatch.level7_best_time",
        8: "com.emojimatch.level8_best_time",
        9: "com.emojimatch.level9_best_time",
        10: "com.emojimatch.level10_best_time",
        11: "com.emojimatch.level11_best_time",
        12: "com.emojimatch.level12_best_time",
        13: "com.emojimatch.level13_best_time",
        14: "com.emojimatch.level14_best_time",
        15: "com.emojimatch.level15_best_time",
        16: "com.emojimatch.level16_best_time",
        17: "com.emojimatch.level17_best_time",
        18: "com.emojimatch.level18_best_time",
        19: "com.emojimatch.level19_best_time",
        20: "com.emojimatch.level20_best_time"
    ]
    
    override init() {
        super.init()
        authenticateUser()
    }
    
    // MARK: - Migration Methods
    
    /// Check if migration is needed for version 1.5
    private func shouldMigrateGameHistory() -> Bool {
        guard isAuthenticated else {
            print("🔄 GameCenter not authenticated, skipping migration check")
            return false
        }
        
        let hasMigrated = UserDefaults.standard.bool(forKey: hasMigratedToGameCenterKey)
        let lastMigratedVersion = UserDefaults.standard.string(forKey: appVersionKey)
        let migrationInProgress = UserDefaults.standard.bool(forKey: migrationInProgressKey)
        
        print("🔍 Migration check:")
        print("   - Has migrated to v1.5: \(hasMigrated)")
        print("   - Last migrated version: \(lastMigratedVersion ?? "none")")
        print("   - Migration in progress: \(migrationInProgress)")
        print("   - Current version: \(currentAppVersion)")
        
        // Don't migrate if already in progress
        if migrationInProgress {
            print("⚠️ Migration already in progress, skipping")
            return false
        }
        
        // Migrate if:
        // 1. Never migrated to v1.5 before, OR
        // 2. Last migrated version is different from current version
        let shouldMigrate = !hasMigrated || lastMigratedVersion != currentAppVersion
        
        print("🎯 Should migrate: \(shouldMigrate)")
        return shouldMigrate
    }
    
    /// Migrate game history to GameCenter
    func migrateGameHistoryToGameCenter(gameHistory: [GameHistory]) {
        guard shouldMigrateGameHistory() else {
            print("🔄 GameCenter migration not needed")
            return
        }
        
        // Mark migration as in progress
        UserDefaults.standard.set(true, forKey: migrationInProgressKey)
        
        print("🚀 Starting GameCenter migration for \(gameHistory.count) total games")
        
        // Filter only winning games (since we only track best times)
        let winningGames = gameHistory.filter { $0.isWin }
        print("📊 Found \(winningGames.count) winning games to process")
        
        // Group by level to find best time for each level
        let groupedByLevel = Dictionary(grouping: winningGames) { $0.level }
        
        var migrationResults: [Int: TimeInterval] = [:]
        let totalLevels = groupedByLevel.keys.count
        
        print("🎮 Processing \(totalLevels) levels...")
        
        for (level, games) in groupedByLevel {
            // Find the best (fastest) time for this level
            if let bestGame = games.min(by: { $0.timeToComplete < $1.timeToComplete }) {
                migrationResults[level] = bestGame.timeToComplete
                print("📤 Level \(level): Best time \(String(format: "%.2f", bestGame.timeToComplete))s from \(games.count) games")
            }
        }
        
        // Submit all best times to GameCenter
        submitMigrationScores(migrationResults) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.completeMigration(levelCount: migrationResults.count)
                } else {
                    self?.failMigration()
                }
            }
        }
    }
    
    /// Submit migration scores to GameCenter
    private func submitMigrationScores(_ scores: [Int: TimeInterval], completion: @escaping (Bool) -> Void) {
        guard !scores.isEmpty else {
            print("⚠️ No scores to migrate")
            completion(true)
            return
        }
        
        print("📤 Submitting \(scores.count) scores to GameCenter...")
        
        let dispatchGroup = DispatchGroup()
        var successCount = 0
        var failureCount = 0
        
        for (level, timeInSeconds) in scores {
            dispatchGroup.enter()
            
            // Submit score with proper error handling
            submitScoreWithCompletion(level: level, timeInSeconds: timeInSeconds) { success in
                if success {
                    successCount += 1
                    print("✅ Level \(level): Successfully submitted \(String(format: "%.2f", timeInSeconds))s")
                } else {
                    failureCount += 1
                    print("❌ Level \(level): Failed to submit score")
                }
                dispatchGroup.leave()
            }
            
            // Add small delay to prevent overwhelming GameCenter
            Thread.sleep(forTimeInterval: 0.2)
        }
        
        dispatchGroup.notify(queue: .main) {
            let totalScores = scores.count
            print("📊 Migration submission complete:")
            print("   - Successful: \(successCount)/\(totalScores)")
            print("   - Failed: \(failureCount)/\(totalScores)")
            
            // Consider migration successful if at least 80% of scores were submitted
            let successRate = Double(successCount) / Double(totalScores)
            let migrationSuccessful = successRate >= 0.8
            
            completion(migrationSuccessful)
        }
    }
    
    /// Submit score with completion callback
    private func submitScoreWithCompletion(level: Int, timeInSeconds: TimeInterval, completion: @escaping (Bool) -> Void) {
        guard let leaderboardID = leaderboardIDs[level] else {
            print("❌ No leaderboard ID found for level \(level)")
            completion(false)
            return
        }
        
        let scoreValue = Int(timeInSeconds * 100) // Convert to centiseconds
        
        Task {
            do {
                let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
                if let leaderboard = leaderboards.first {
                    try await leaderboard.submitScore(scoreValue, context: 0, player: GKLocalPlayer.local)
                    completion(true)
                } else {
                    print("❌ Leaderboard not found for level \(level)")
                    completion(false)
                }
            } catch {
                print("❌ Failed to submit score for level \(level): \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Complete migration successfully
    private func completeMigration(levelCount: Int) {
        UserDefaults.standard.set(true, forKey: hasMigratedToGameCenterKey)
        UserDefaults.standard.set(currentAppVersion, forKey: appVersionKey)
        UserDefaults.standard.set(false, forKey: migrationInProgressKey)
        
        print("✅ GameCenter migration completed successfully!")
        print("🎉 Migrated best times for \(levelCount) levels to GameCenter")
        
        // Post notification for UI updates
        NotificationCenter.default.post(
            name: .gameCenterMigrationCompleted,
            object: nil,
            userInfo: ["levelCount": levelCount]
        )
        
        // Show user notification
        showMigrationSuccessNotification(levelCount: levelCount)
    }
    
    /// Handle migration failure
    private func failMigration() {
        UserDefaults.standard.set(false, forKey: migrationInProgressKey)
        
        print("❌ GameCenter migration failed")
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .gameCenterMigrationFailed, object: nil)
        
        // Show user notification
        showMigrationFailureNotification()
    }
    
    /// Show success notification to user
    private func showMigrationSuccessNotification(levelCount: Int) {
        print("🎉 Migration Success: Your best times for \(levelCount) levels have been synced to Game Center!")
        
        // You can implement a toast notification or banner here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Optional: Show an alert or toast to the user
            self.presentMigrationAlert(
                title: "Game Center Sync Complete!",
                message: "Your best times for \(levelCount) levels have been synced to Game Center leaderboards."
            )
        }
    }
    
    /// Show failure notification to user
    private func showMigrationFailureNotification() {
        print("⚠️ Migration failed - scores will be synced as you play new games")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presentMigrationAlert(
                title: "Game Center Sync",
                message: "Some scores couldn't be synced to Game Center. Don't worry - your future games will be tracked automatically!"
            )
        }
    }
    
    /// Present migration alert to user
    private func presentMigrationAlert(title: String, message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            rootViewController.present(alert, animated: true)
        }
    }
    
    /// Check for migration after successful authentication
    private func checkForGameHistoryMigration() {
        print("🔍 Checking for GameCenter migration need...")
        
        // Post notification that GameCenter is ready for migration
        NotificationCenter.default.post(name: .gameCenterReadyForMigration, object: nil)
    }
    
    /// Reset migration status (for testing purposes)
    func resetMigrationStatus() {
        UserDefaults.standard.removeObject(forKey: hasMigratedToGameCenterKey)
        UserDefaults.standard.removeObject(forKey: appVersionKey)
        UserDefaults.standard.removeObject(forKey: migrationInProgressKey)
        print("🔄 Migration status reset - next authentication will trigger migration")
    }
    
    // MARK: - Existing Authentication Methods (Updated)
    
    func authenticateUser() {
        print("🔍 Starting GameCenter authentication...")
        print("🔍 Current authentication status: \(GKLocalPlayer.local.isAuthenticated)")
        
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ GameCenter authentication failed: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                } else if let viewController = viewController {
                    print("📱 GameCenter requires authentication UI")
                    self?.presentViewController(viewController)
                } else if GKLocalPlayer.local.isAuthenticated {
                    print("✅ GameCenter authenticated successfully")
                    print("✅ Player: \(GKLocalPlayer.local.displayName)")
                    self?.isAuthenticated = true
                    
                    // UPDATED: Trigger migration check after successful authentication
                    self?.checkForGameHistoryMigration()
                    
                } else {
                    print("⚠️ GameCenter authentication cancelled or unavailable")
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    // ... (keep all your existing methods: submitScore, showLeaderboard, etc.)
    // I'm only showing the new/updated methods to avoid repetition
    
    func submitScore(level: Int, timeInSeconds: TimeInterval) {
        guard isAuthenticated else {
            print("⚠️ GameCenter not authenticated, cannot submit score")
            return
        }
        
        guard let leaderboardID = leaderboardIDs[level] else {
            print("❌ No leaderboard ID found for level \(level)")
            return
        }
        
        let scoreValue = Int(timeInSeconds * 100)
        
        Task {
            do {
                let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
                if let leaderboard = leaderboards.first {
                    try await leaderboard.submitScore(scoreValue, context: 0, player: GKLocalPlayer.local)
                    print("✅ Score submitted successfully for level \(level): \(timeInSeconds)s (\(scoreValue) centiseconds)")
                } else {
                    print("❌ Leaderboard not found for level \(level)")
                }
            } catch {
                print("❌ Failed to submit score for level \(level): \(error.localizedDescription)")
            }
        }
    }

    // Manual retry method for authentication
    func retryAuthentication() {
        print("🔄 Retrying GameCenter authentication...")
        authenticateUser()
    }
    
    // Check if GameCenter is available
    func isGameCenterAvailable() -> Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    
    private func presentViewController(_ viewController: UIViewController) {
        print("📱 Attempting to present GameCenter authentication...")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            print("✅ Found root view controller, presenting authentication")
            rootViewController.present(viewController, animated: true) {
                print("📱 GameCenter authentication UI presented")
            }
        } else {
            print("❌ Could not find root view controller to present authentication")
        }
    }
    

    // Show leaderboard for specific level using modern API
    func showLeaderboard(for level: Int) {
        guard isAuthenticated else {
            print("⚠️ GameCenter not authenticated, cannot show leaderboard")
            return
        }
        
        guard let leaderboardID = leaderboardIDs[level] else {
            print("❌ No leaderboard ID found for level \(level)")
            return
        }
        
        let leaderboardViewController = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        leaderboardViewController.gameCenterDelegate = self
        
        presentViewController(leaderboardViewController)
    }
    
    // Show all leaderboards
    func showAllLeaderboards() {
        guard isAuthenticated else {
            print("⚠️ GameCenter not authenticated, cannot show leaderboards")
            return
        }
        
        let leaderboardViewController = GKGameCenterViewController(state: .leaderboards)
        leaderboardViewController.gameCenterDelegate = self
        
        presentViewController(leaderboardViewController)
    }
    
    // Get player's best score for a level using modern API with centisecond precision
    func getPlayerScore(for level: Int, completion: @escaping (TimeInterval?) -> Void) {
        guard isAuthenticated else {
            completion(nil)
            return
        }
        
        guard let leaderboardID = leaderboardIDs[level] else {
            completion(nil)
            return
        }
        
        Task {
            do {
                let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
                guard let leaderboard = leaderboards.first else {
                    completion(nil)
                    return
                }
                
                let (localPlayerEntry, _, _) = try await leaderboard.loadEntries(
                    for: .global,
                    timeScope: .allTime,
                    range: NSRange(location: 1, length: 1)
                )
                
                DispatchQueue.main.async {
                    if let playerEntry = localPlayerEntry {
                        // Convert back from centiseconds to seconds with decimal precision
                        let timeInSeconds = Double(playerEntry.score) / 100.0
                        completion(timeInSeconds)
                    } else {
                        completion(nil)
                    }
                }
                
            } catch {
                print("❌ Failed to load player score for level \(level): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // Get top scores for a level using modern API with centisecond precision
    func getTopScores(for level: Int, limit: Int = 10, completion: @escaping ([GKLeaderboard.Entry]?) -> Void) {
        guard isAuthenticated else {
            completion(nil)
            return
        }
        
        guard let leaderboardID = leaderboardIDs[level] else {
            completion(nil)
            return
        }
        
        Task {
            do {
                let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
                guard let leaderboard = leaderboards.first else {
                    completion(nil)
                    return
                }
                
                let (_, topEntries, _) = try await leaderboard.loadEntries(
                    for: .global,
                    timeScope: .allTime,
                    range: NSRange(location: 1, length: limit)
                )
                
                DispatchQueue.main.async {
                    completion(topEntries)
                }
                
            } catch {
                print("❌ Failed to load top scores for level \(level): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // Get player's rank for a level using modern API
    func getPlayerRank(for level: Int, completion: @escaping (Int?) -> Void) {
        guard isAuthenticated else {
            completion(nil)
            return
        }
        
        guard let leaderboardID = leaderboardIDs[level] else {
            completion(nil)
            return
        }
        
        Task {
            do {
                let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
                guard let leaderboard = leaderboards.first else {
                    completion(nil)
                    return
                }
                
                let (localPlayerEntry, _, _) = try await leaderboard.loadEntries(
                    for: .global,
                    timeScope: .allTime,
                    range: NSRange(location: 1, length: 1)
                )
                
                DispatchQueue.main.async {
                    if let playerEntry = localPlayerEntry {
                        completion(playerEntry.rank)
                    } else {
                        completion(nil)
                    }
                }
                
            } catch {
                print("❌ Failed to load player rank for level \(level): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // Challenge friends to beat your score
    func challengeFriends(level: Int, timeInSeconds: TimeInterval) {
        guard isAuthenticated else {
            print("⚠️ GameCenter not authenticated, cannot challenge friends")
            return
        }
        
        let challengeComposeController = GKGameCenterViewController(state: .challenges)
        challengeComposeController.gameCenterDelegate = self
        
        presentViewController(challengeComposeController)
    }
}

// MARK: - GKGameCenterControllerDelegate
extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

extension Notification.Name {
    static let gameCenterMigrationProgress = Notification.Name("GameCenterMigrationProgress")
    static let gameCenterReadyForMigration = Notification.Name("GameCenterReadyForMigration")
    static let gameCenterMigrationCompleted = Notification.Name("GameCenterMigrationCompleted")
    static let gameCenterMigrationFailed = Notification.Name("GameCenterMigrationFailed")
}

// MARK: - 2. Updated MatchCardsGameModel.swift (Add this method)

extension MatchCardsGameModel {
    /// Trigger GameCenter migration if needed
    func migrateToGameCenterIfNeeded(gameHistory: [GameHistory]) {
        print("🔄 Requesting GameCenter migration with \(gameHistory.count) games")
        GameCenterManager.shared.migrateGameHistoryToGameCenter(gameHistory: gameHistory)
    }
}


extension GameCenterManager {
    
    // Add these properties to track migration consent
    
    /// Check if user has declined migration
    private func hasUserDeclinedMigration() -> Bool {
        return UserDefaults.standard.bool(forKey: migrationConsentDeclinedKey)
    }
    
    /// Mark that user declined migration
    func markMigrationDeclined() {
        UserDefaults.standard.set(true, forKey: migrationConsentDeclinedKey)
        print("🚫 User declined GameCenter migration")
    }
    
    /// Check if migration should be offered to user
    func shouldOfferMigration(gameHistory: [GameHistory], isGameActive: Bool) -> Bool {
        // Don't offer if:
        // 1. Not authenticated to GameCenter
        guard isAuthenticated else {
            print("🔍 No migration offer: Not authenticated")
            return false
        }
        
        // 2. Game is currently active
        guard !isGameActive else {
            print("🔍 No migration offer: Game is active")
            return false
        }
        
        // 3. User already declined
        guard !hasUserDeclinedMigration() else {
            print("🔍 No migration offer: User previously declined")
            return false
        }
        
        // 4. Already migrated
        guard shouldMigrateGameHistory() else {
            print("🔍 No migration offer: Already migrated")
            return false
        }
        
        // 5. No winning games to migrate
        let winningGames = gameHistory.filter { $0.isWin }
        guard !winningGames.isEmpty else {
            print("🔍 No migration offer: No winning games to migrate")
            return false
        }
        
        // 6. Migration already in progress
        let migrationInProgress = UserDefaults.standard.bool(forKey: migrationInProgressKey)
        guard !migrationInProgress else {
            print("🔍 No migration offer: Migration already in progress")
            return false
        }
        
        print("✅ Should offer migration: \(winningGames.count) winning games ready")
        return true
    }
    
    /// Enhanced migration with progress reporting
    func migrateGameHistoryWithProgress(gameHistory: [GameHistory]) {
        guard shouldMigrateGameHistory() else {
            print("🔄 GameCenter migration not needed")
            return
        }
        
        // Mark migration as in progress
        UserDefaults.standard.set(true, forKey: migrationInProgressKey)
        
        print("🚀 Starting GameCenter migration with progress tracking")
        
        // Filter and process games
        let winningGames = gameHistory.filter { $0.isWin }
        let groupedByLevel = Dictionary(grouping: winningGames) { $0.level }
        
        var migrationResults: [Int: TimeInterval] = [:]
        let totalLevels = groupedByLevel.keys.count
        
        // Report initial progress
        NotificationCenter.default.post(
            name: .gameCenterMigrationProgress,
            object: nil,
            userInfo: [
                "progress": 0.2,
                "currentLevel": 0,
                "levelsCompleted": 0
            ]
        )
        
        // Process each level
        for (level, games) in groupedByLevel {
            if let bestGame = games.min(by: { $0.timeToComplete < $1.timeToComplete }) {
                migrationResults[level] = bestGame.timeToComplete
            }
        }
        
        // Submit scores with progress updates
        submitMigrationScoresWithProgress(migrationResults) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.completeMigration(levelCount: migrationResults.count)
                } else {
                    self?.failMigration()
                }
            }
        }
    }
    
    /// Submit scores with progress reporting
    private func submitMigrationScoresWithProgress(_ scores: [Int: TimeInterval], completion: @escaping (Bool) -> Void) {
        guard !scores.isEmpty else {
            completion(true)
            return
        }
        
        let sortedScores = scores.sorted { $0.key < $1.key }
        let totalScores = sortedScores.count
        var completedScores = 0
        var successCount = 0
        
        // Process scores sequentially for better progress tracking
        func processNextScore(index: Int) {
            guard index < sortedScores.count else {
                let successRate = Double(successCount) / Double(totalScores)
                completion(successRate >= 0.8)
                return
            }
            
            let (level, timeInSeconds) = sortedScores[index]
            
            // Report progress
            let progress = 0.2 + (Double(index) / Double(totalScores)) * 0.6 // 20% to 80%
            NotificationCenter.default.post(
                name: .gameCenterMigrationProgress,
                object: nil,
                userInfo: [
                    "progress": progress,
                    "currentLevel": level,
                    "levelsCompleted": completedScores
                ]
            )
            
            // Submit score
            submitScoreWithCompletion(level: level, timeInSeconds: timeInSeconds) { success in
                completedScores += 1
                if success {
                    successCount += 1
                }
                
                // Update progress
                let newProgress = 0.2 + (Double(completedScores) / Double(totalScores)) * 0.6
                NotificationCenter.default.post(
                    name: .gameCenterMigrationProgress,
                    object: nil,
                    userInfo: [
                        "progress": newProgress,
                        "currentLevel": level,
                        "levelsCompleted": completedScores
                    ]
                )
                
                // Small delay before next submission
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    processNextScore(index: index + 1)
                }
            }
        }
        
        // Start processing
        processNextScore(index: 0)
    }
}
