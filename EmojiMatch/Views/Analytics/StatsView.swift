import SwiftUI

struct StatsView: View {
    let gameHistory: [GameHistory]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.massiveSpacing) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Theme.extraLargeSpacing), count: 2), spacing: Theme.extraLargeSpacing) {
                    StatsCard(
                        icon: "gamecontroller.fill",
                        title: "Games Played",
                        value: "\(gameHistory.count)",
                        color: .blue
                    )
                    
                    StatsCard(
                        icon: "trophy.fill",
                        title: "Games Won",
                        value: "\(gameHistory.filter { $0.isWin }.count)",
                        color: .green
                    )
                    
                    StatsCard(
                        icon: "percent",
                        title: "Win Rate",
                        value: winRate,
                        color: .orange
                    )
                    
                    StatsCard(
                        icon: "stopwatch.fill",
                        title: "Best Time",
                        value: bestTimeText,
                        color: .purple
                    )
                }
                
                VStack(alignment: .leading, spacing: Theme.extraLargeSpacing) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.yellow)
                        Text("Level Progress")
                            .font(Theme.chartTitleFont)
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Theme.largeSpacing), count: 4), spacing: Theme.largeSpacing) {
                        ForEach(1...20, id: \.self) { level in
                            LevelProgressCard(level: level, gameHistory: gameHistory)
                        }
                    }
                }
                .padding(Theme.hugeSpacing)
                .background(
                    RoundedRectangle(cornerRadius: Theme.hugeSpacing)
                        .fill(Theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.hugeSpacing)
                                .stroke(Theme.cardBorder, lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, Theme.hugeSpacing)
            .padding(.vertical, Theme.hugeSpacing)
        }
    }
    
    private var winRate: String {
        guard !gameHistory.isEmpty else { return "0%" }
        let rate = (Double(gameHistory.filter { $0.isWin }.count) / Double(gameHistory.count)) * 100
        return "\(Int(rate))%"
    }
    
    private var bestTimeText: String {
        if let bestGame = gameHistory.filter({ $0.isWin }).min(by: { $0.timeToComplete < $1.timeToComplete }) {
            return formatTime(bestGame.timeToComplete)
        } else {
            return "--"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 