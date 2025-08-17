import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .black : Theme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.smallButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(isSelected ? Color.yellow : Theme.cardBackground)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 