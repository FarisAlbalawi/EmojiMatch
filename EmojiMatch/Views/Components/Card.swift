import SwiftUI

struct Card: View {
    let title: String
    let value: String
    let trend: TrendDirection
    let icon: String
    
    var body: some View {
        VStack(spacing: Theme.largeSpacing) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: trendIcon)
                    .foregroundColor(trendColor)
            }
            
            VStack(alignment: .leading, spacing: Theme.smallSpacing) {
                Text(value)
                    .font(Theme.cardValueFont)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(title)
                    .font(Theme.cardTitleFont)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 32, alignment: .top)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: Theme.mediumCardHeight)
        .padding(Theme.extraLargeSpacing)
        .background(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                )
        )
    }
    
    private var trendIcon: String {
        switch trend {
        case .improving: return "arrow.up.right"
        case .declining: return "arrow.down.right"
        case .neutral: return "minus"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .improving: return .green
        case .declining: return .red
        case .neutral: return .gray
        }
    }
} 