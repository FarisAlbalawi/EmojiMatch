import SwiftUI
import _SwiftData_SwiftUI
import GameKit

struct LeaderboardView: View {
    @StateObject private var gameCenterManager = GameCenterManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel = 1
    @State private var topScores: [GKLeaderboard.Entry] = []
    @State private var playerRank: Int?
    @State private var isLoading = false
    @State private var showMigrationSheet = false
    
    // Add migration check
    @Query(sort: \GameHistory.date, order: .reverse) private var gameHistory: [GameHistory]
    
    private let levels = Array(1...20)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.2),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if !gameCenterManager.isAuthenticated {
                        // Not authenticated view (existing code)
                        VStack(spacing: 24) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                            
                            Text("Connect to Game Center")
                                .font(.roundedBold(size: 24))
                                .foregroundColor(.white)
                            
                            Text("Sign in to Game Center to view leaderboards and compete with friends!")
                                .font(.roundedBold(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            // Migration info for v1.5
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New in v1.5:")
                                    .font(.roundedBold(size: 14))
                                    .foregroundColor(.yellow)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• Your existing best times will sync automatically")
                                    Text("• Compete with players worldwide")
                                    Text("• Track your global ranking")
                                    Text("• Secure cloud backup of your progress")
                                }
                                .font(.roundedBold(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            Button(action: {
                                gameCenterManager.retryAuthentication()
                            }) {
                                Text("Connect to Game Center")
                                    .font(.roundedBold(size: 18))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.yellow)
                                    .cornerRadius(16)
                            }
                            .padding(.horizontal, 40)
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxHeight: .infinity)
                        
                    } else {
                        // Authenticated view with migration option
                        VStack(spacing: 0) {
                            // Level indicator with migration button
                            HStack {
                                Text("Level \(selectedLevel)")
                                    .font(.roundedBold(size: 28))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Migration button (show if user has data but hasn't migrated)
                                if canShowMigrationButton {
                                    Button(action: {
                                        showMigrationSheet = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "icloud.and.arrow.up")
                                                .font(.system(size: 12, weight: .semibold))
                                            Text("Sync Data")
                                                .font(.roundedBold(size: 12))
                                        }
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(8)
                                        .shadow(color: .yellow.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Level selector menu
                                Menu {
                                    ForEach(levels, id: \.self) { level in
                                        Button("Level \(level)") {
                                            selectedLevel = level
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("\(selectedLevel)")
                                            .font(.roundedBold(size: 14))
                                            .foregroundColor(.yellow)
                                        
                                        Text("of")
                                            .font(.roundedBold(size: 12))
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        Text("\(levels.count)")
                                            .font(.roundedBold(size: 14))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                }
                                .menuStyle(BorderlessButtonMenuStyle())
                                .menuOrder(.fixed)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                            
                            // TabView for paging through levels (existing code)
                            TabView(selection: $selectedLevel) {
                                ForEach(levels, id: \.self) { level in
                                    LeaderboardPageView(
                                        level: level,
                                        topScores: level == selectedLevel ? topScores : [],
                                        playerRank: level == selectedLevel ? playerRank : nil,
                                        isLoading: level == selectedLevel ? isLoading : false,
                                        onLevelAppear: {
                                            if level == selectedLevel {
                                                loadLeaderboardData()
                                            }
                                        }
                                    )
                                    .tag(level)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .onChange(of: selectedLevel) { newLevel in
                                loadLeaderboardData()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Leaderboards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        loadLeaderboardData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1.0)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showMigrationSheet) {
            MigrationConsentView(
                gameHistory: gameHistory,
                onMigrate: {
                    // User agreed to migrate from leaderboard
                    GameCenterManager.shared.migrateGameHistoryWithProgress(gameHistory: gameHistory)
                },
                onCancel: {
                    // User declined migration from leaderboard
                    gameCenterManager.markMigrationDeclined()
                },
                onDismiss: {
                    // Dismiss the sheet
                    showMigrationSheet = false
                }
            )
            .presentationDetents([.fraction(0.9)])
            .presentationDragIndicator(.hidden)
        }
        .onAppear {
            if gameCenterManager.isAuthenticated {
                loadLeaderboardData()
            }
        }
    }
    
    // Check if migration button should be shown
    private var canShowMigrationButton: Bool {
        return gameCenterManager.shouldOfferMigration(
            gameHistory: gameHistory,
            isGameActive: false // Game is never active in leaderboard view
        )
    }
    
    private func loadLeaderboardData() {
        isLoading = true
        
        // Load top scores
        gameCenterManager.getTopScores(for: selectedLevel, limit: 25) { entries in
            topScores = entries ?? []
            isLoading = false
        }
        
        // Load player rank
        gameCenterManager.getPlayerRank(for: selectedLevel) { rank in
            playerRank = rank
        }
    }
}

// 8. Migration Sheet Preview (for SwiftUI previews)

#if DEBUG
struct MigrationConsentView_Previews: PreviewProvider {
    static var previews: some View {
        MigrationConsentView(
            gameHistory: [
                GameHistory(timeToComplete: 25.5, isWin: true, matchStreak: 8, level: 1),
                GameHistory(timeToComplete: 32.1, isWin: true, matchStreak: 6, level: 2),
                GameHistory(timeToComplete: 45.8, isWin: true, matchStreak: 4, level: 3),
                GameHistory(timeToComplete: 60.0, isWin: false, matchStreak: 2, level: 4),
            ],
            onMigrate: { print("Preview: Migrate") },
            onCancel: { print("Preview: Cancel") },
            onDismiss: { print("Preview: Dismiss") }
        )
        .preferredColorScheme(.dark)
    }
}
#endif
