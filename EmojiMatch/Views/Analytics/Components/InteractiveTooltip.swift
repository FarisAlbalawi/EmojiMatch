import SwiftUI

struct InteractiveTooltip: View {
    let game: GameHistory
    let gameNumber: Int
    let position: CGPoint
    let containerSize: CGSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.mediumSpacing) {
            HStack {
                Text("Game #\(gameNumber)")
                    .font(Theme.tooltipFont)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Text(getPerformanceText(for: game.timeToComplete))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(getPerformanceColor(for: game.timeToComplete))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(getPerformanceColor(for: game.timeToComplete).opacity(0.2))
                    )
            }
            
            VStack(alignment: .leading, spacing: Theme.smallSpacing) {
                HStack {
                    Image(systemName: "stopwatch")
                        .foregroundColor(.yellow)
                        .font(.system(size: Theme.smallIconSize))
                    Text(formatDetailedTime(game.timeToComplete))
                        .font(Theme.tooltipSubtitleFont)
                        .foregroundColor(Theme.textPrimary)
                }
                
                HStack {
                    Image(systemName: "gamecontroller")
                        .foregroundColor(.blue)
                        .font(.system(size: Theme.smallIconSize))
                    Text("Level \(game.level)")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textPrimary)
                }
                
                HStack {
                    Image(systemName: "flame")
                        .foregroundColor(.orange)
                        .font(.system(size: Theme.smallIconSize))
                    Text("\(game.matchStreak) matches")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textPrimary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.purple)
                        .font(.system(size: Theme.smallIconSize))
                    Text(game.date, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textPrimary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .fill(Color.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                        .stroke(getPerformanceColor(for: game.timeToComplete), lineWidth: 1)
                )
        )
        .position(
            x: min(max(position.x, 100), containerSize.width - 100),
            y: position.y > containerSize.height / 2 ? position.y - 80 : position.y + 80
        )
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut(duration: 0.2), value: gameNumber)
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