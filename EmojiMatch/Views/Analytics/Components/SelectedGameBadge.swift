import SwiftUI

struct SelectedGameBadge: View {
    let game: GameHistory
    let gameNumber: Int
    
    var body: some View {
        HStack(spacing: Theme.largeSpacing) {
            ZStack {
                Circle()
                    .fill(getPerformanceColor(for: game.timeToComplete).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "target")
                    .foregroundColor(getPerformanceColor(for: game.timeToComplete))
                    .font(.system(size: Theme.largeIconSize, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: Theme.smallSpacing) {
                HStack {
                    Text("Game #\(gameNumber)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Spacer()
                    
                    Text(getPerformanceText(for: game.timeToComplete))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(getPerformanceColor(for: game.timeToComplete))
                        .padding(.horizontal, Theme.mediumSpacing)
                        .padding(.vertical, Theme.smallSpacing)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.mediumSpacing)
                                .fill(getPerformanceColor(for: game.timeToComplete).opacity(0.2))
                        )
                }
                
                Text("Level \(game.level) • \(formatDetailedTime(game.timeToComplete)) • Streak: \(game.matchStreak)")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(Theme.extraLargeSpacing)
        .background(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                        .stroke(getPerformanceColor(for: game.timeToComplete).opacity(0.5), lineWidth: 1)
                )
        )
    }
    
    private func getPerformanceColor(for time: TimeInterval) -> Color {
        if time <= 30 { return .green }
        else if time <= 45 { return .yellow }
        else if time <= 55 { return .orange }
        else { return .red }
    }
    
    private func getPerformanceText(for time: TimeInterval) -> String {
        if time <= 30 { return "Excellent" }
        else if time <= 45 { return "Good" }
        else if time <= 55 { return "Average" }
        else { return "Slow" }
    }
    
    private func formatDetailedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
} 