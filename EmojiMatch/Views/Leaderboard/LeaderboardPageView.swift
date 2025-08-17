import SwiftUI
import GameKit

struct LeaderboardPageView: View {
    let level: Int
    let topScores: [GKLeaderboard.Entry]
    let playerRank: Int?
    let isLoading: Bool
    let onLevelAppear: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Player Stats Card
            if let rank = playerRank {
                PlayerStatsCard(level: level, rank: rank)
                    .padding(.horizontal, 20)
            }
            
            // Top Scores List
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Top Players")
                        .font(.roundedBold(size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Swipe hint for first few levels
                    if level <= 3 {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("Swipe to browse levels")
                                .font(.roundedBold(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        
                        Text("Loading leaderboard...")
                            .font(.roundedBold(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    
                } else if topScores.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "trophy")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("No scores yet")
                            .font(.roundedBold(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Be the first to complete Level \(level)!")
                            .font(.roundedBold(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(topScores.enumerated()), id: \.offset) { index, entry in
                                LeaderboardRowView(
                                    rank: index + 1,
                                    entry: entry,
                                    isLocalPlayer: entry.player.gamePlayerID == GKLocalPlayer.local.gamePlayerID
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            onLevelAppear()
        }
    }
}
