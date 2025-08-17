import SwiftUI

struct ProgressChartView: View {
    let gameHistory: [GameHistory]
    @State private var selectedGameIndex: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.massiveSpacing) {
                VStack(alignment: .leading, spacing: Theme.extraLargeSpacing) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.yellow)
                        Text("Performance Trend")
                            .font(Theme.chartTitleFont)
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    // Selected Game Info Badge
                    if let selectedIndex = selectedGameIndex,
                       selectedIndex < recentGames.count {
                        let selectedGame = recentGames[selectedIndex]
                        SelectedGameBadge(game: selectedGame, gameNumber: selectedIndex + 1)
                    }
                    
                    if !recentGames.isEmpty {
                        EnhancedPerformanceChart(
                            games: recentGames,
                            selectedIndex: $selectedGameIndex
                        )
                    } else {
                        VStack(spacing: Theme.extraLargeSpacing) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: Theme.hugeIconSize))
                                .foregroundColor(Theme.textSecondary)
                            
                            Text("Complete more games to see your progress!")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Performance Legend
                    if !recentGames.isEmpty {
                        PerformanceLegend()
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
                
                // Improvement Metrics
                VStack(alignment: .leading, spacing: Theme.extraLargeSpacing) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.yellow)
                        Text("Memory Improvement")
                            .font(Theme.chartTitleFont)
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Theme.extraLargeSpacing), count: 2), spacing: Theme.extraLargeSpacing) {
                        Card(
                            title: "Avg. Completion Time",
                            value: averageTime,
                            trend: timeTrend,
                            icon: "stopwatch"
                        )
                        
                        Card(
                            title: "Match Streak",
                            value: "\(averageStreak)",
                            trend: streakTrend,
                            icon: "flame"
                        )
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
    
    private var recentGames: [GameHistory] {
        Array(gameHistory.filter { $0.isWin }.prefix(20).reversed())
    }
    
    private var averageTime: String {
        let winGames = gameHistory.filter { $0.isWin }
        guard !winGames.isEmpty else { return "--" }
        let avg = winGames.reduce(0) { $0 + $1.timeToComplete } / Double(winGames.count)
        let minutes = Int(avg) / 60
        let seconds = Int(avg) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var timeTrend: TrendDirection {
        let winGames = gameHistory.filter { $0.isWin }
        guard winGames.count >= 2 else { return .neutral }
        
        let recent = Array(winGames.prefix(5))
        let older = Array(winGames.dropFirst(5).prefix(5))
        
        guard !recent.isEmpty && !older.isEmpty else { return .neutral }
        
        let recentAvg = recent.reduce(0) { $0 + $1.timeToComplete } / Double(recent.count)
        let olderAvg = older.reduce(0) { $0 + $1.timeToComplete } / Double(older.count)
        
        if recentAvg < olderAvg * 0.95 {
            return .improving
        } else if recentAvg > olderAvg * 1.05 {
            return .declining
        } else {
            return .neutral
        }
    }
    
    private var averageStreak: Int {
        let winGames = gameHistory.filter { $0.isWin }
        guard !winGames.isEmpty else { return 0 }
        return Int(winGames.reduce(0) { $0 + $1.matchStreak } / winGames.count)
    }
    
    private var streakTrend: TrendDirection {
        let winGames = gameHistory.filter { $0.isWin }
        guard winGames.count >= 2 else { return .neutral }
        
        let recent = Array(winGames.prefix(5))
        let older = Array(winGames.dropFirst(5).prefix(5))
        
        guard !recent.isEmpty && !older.isEmpty else { return .neutral }
        
        let recentAvg = recent.reduce(0) { $0 + $1.matchStreak } / recent.count
        let olderAvg = older.reduce(0) { $0 + $1.matchStreak } / older.count
        
        if recentAvg > olderAvg {
            return .improving
        } else if recentAvg < olderAvg {
            return .declining
        } else {
            return .neutral
        }
    }
} 
