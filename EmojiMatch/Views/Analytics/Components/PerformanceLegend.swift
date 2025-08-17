import SwiftUI

struct PerformanceLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.mediumSpacing) {
            Text("Performance Legend")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
            
            HStack(spacing: Theme.extraLargeSpacing) {
                LegendItem(color: .green, text: "Excellent (≤30s)")
                LegendItem(color: .yellow, text: "Good (31-45s)")
            }
            
            HStack(spacing: Theme.extraLargeSpacing) {
                LegendItem(color: .orange, text: "Average (46-55s)")
                LegendItem(color: .red, text: "Slow (>55s)")
            }
        }
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
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(text)
                .font(Theme.legendFont)
                .foregroundColor(Theme.textSecondary)
        }
    }
} 