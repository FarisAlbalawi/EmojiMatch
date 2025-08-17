import SwiftUI

struct LevelProgressCard: View {
    let level: Int
    let gameHistory: [GameHistory]
    
    var body: some View {
        VStack(spacing: Theme.mediumSpacing) {
            Text("\(level)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(hasCompleted ? .green : Theme.textSecondary)
            
            Circle()
                .fill(hasCompleted ? Color.green : Theme.cardBackground)
                .frame(width: 8, height: 8)
        }
        .frame(width: 60, height: 60)
        .background(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .fill(hasCompleted ? Color.green.opacity(0.1) : Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                        .stroke(hasCompleted ? Color.green.opacity(0.5) : Theme.cardBorder, lineWidth: 1)
                )
        )
    }
    
    private var hasCompleted: Bool {
        gameHistory.contains { $0.level == level && $0.isWin }
    }
} 