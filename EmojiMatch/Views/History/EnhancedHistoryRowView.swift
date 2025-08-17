import SwiftUI

struct EnhancedHistoryRowView: View {
    let game: GameHistory
    
    var body: some View {
        HStack(spacing: Theme.extraLargeSpacing) {
            ZStack {
                Circle()
                    .fill(game.isWin ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: game.isWin ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: Theme.extraLargeIconSize))
                    .foregroundColor(game.isWin ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: Theme.smallSpacing) {
                HStack {
                    Text(game.isWin ? "Victory" : "Time Out")
                        .font(Theme.historyTitleFont)
                        .foregroundColor(Theme.textPrimary)
                    
                    Spacer()
                    
                    Text("Level \(game.level)")
                        .font(Theme.historySubtitleFont)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, Theme.mediumSpacing)
                        .padding(.vertical, Theme.smallSpacing)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.mediumSpacing)
                                .fill(Color.yellow.opacity(0.2))
                        )
                }
                
                Text(game.date, style: .date)
                    .font(Theme.historySubtitleFont)
                    .foregroundColor(Theme.textTertiary)
                
                if game.isWin {
                    HStack(spacing: Theme.largeSpacing) {
                        HStack(spacing: Theme.smallSpacing) {
                            Image(systemName: "stopwatch")
                                .font(.system(size: Theme.smallIconSize))
                                .foregroundColor(.blue)
                            Text(formatTime(game.timeToComplete))
                                .font(Theme.historyTimeFont)
                                .foregroundColor(Theme.textPrimary)
                        }
                        
                        if game.matchStreak > 0 {
                            HStack(spacing: Theme.smallSpacing) {
                                Image(systemName: "flame")
                                    .font(.system(size: Theme.smallIconSize))
                                    .foregroundColor(.orange)
                                Text("\(game.matchStreak)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(Theme.extraLargeSpacing)
        .background(
            RoundedRectangle(cornerRadius: Theme.extraLargeCornerRadius)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.extraLargeCornerRadius)
                        .stroke(game.isWin ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
} 