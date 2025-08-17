
// MARK: - 3. Updated ContentView.swift (Complete implementation)

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var currentPage = 0
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    @StateObject private var gameModel = MatchCardsGameModel()
    @StateObject private var gameCenterManager = GameCenterManager.shared

    var body: some View {
        VerticalPageViewController(
            pages: [
                AnyView(
                    MatchCardsGameView(currentPage: $currentPage)
                        .environmentObject(revenueCatManager)
                        .environmentObject(gameModel)
                        .modelContainer(for: GameHistory.self)
                ),
                AnyView(LeaderboardView()),
            ],
            currentPage: $currentPage,
            isScrollEnabled: !gameModel.isGameActive
        )
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            print("🚀 App started with level: \(gameModel.currentLevel.rawValue)")
            setupGameCenterMigration()
        }
    }
    
    /// Setup GameCenter migration listeners at app level
    private func setupGameCenterMigration() {
        // Listen for GameCenter ready notification
        NotificationCenter.default.addObserver(
            forName: .gameCenterReadyForMigration,
            object: nil,
            queue: .main
        ) { _ in
            print("📢 GameCenter ready for migration (ContentView)")
            // The actual migration check will happen in MatchCardsGameView
        }
        
        // Listen for migration completion
        NotificationCenter.default.addObserver(
            forName: .gameCenterMigrationCompleted,
            object: nil,
            queue: .main
        ) { notification in
            if let levelCount = notification.userInfo?["levelCount"] as? Int {
                print("🎉 Migration completed for \(levelCount) levels (ContentView)")
            }
        }
        
        // Listen for migration failure
        NotificationCenter.default.addObserver(
            forName: .gameCenterMigrationFailed,
            object: nil,
            queue: .main
        ) { _ in
            print("⚠️ Migration failed (ContentView)")
        }
    }
}
