import SwiftUI

struct StatsCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.largeSpacing) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: Theme.extraLargeIconSize, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: Theme.smallSpacing) {
                Text(value)
                    .font(Theme.statsValueFont)
                    .foregroundColor(Theme.textPrimary)
                
                Text(title)
                    .font(Theme.statsTitleFont)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.hugeSpacing)
        .background(
            RoundedRectangle(cornerRadius: Theme.extraLargeCornerRadius)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.extraLargeCornerRadius)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
} 