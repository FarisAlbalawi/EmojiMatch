import SwiftUI

struct LevelCard: View {
    let level: GameLevel
    let isSelected: Bool
    let isAnimated: Bool
    let onTap: () -> Void
    
    // iPad detection
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var cardHeight: CGFloat {
        isIPad ? 160 : 140
    }
    
    private var difficultyColor: Color {
        switch level.rawValue {
        case 1...5: return .green
        case 6...10: return .yellow
        case 11...15: return .orange
        default: return .red
        }
    }
    
    private var difficultyText: String {
        switch level.rawValue {
        case 1...5: return "Easy"
        case 6...10: return "Medium"
        case 11...15: return "Hard"
        default: return "Expert"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background with gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected ?
                                [Color.yellow, Color.orange] :
                                [Color.white.opacity(0.1), Color.white.opacity(0.05)]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [difficultyColor.opacity(0.6), difficultyColor.opacity(0.2)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                VStack(spacing: isIPad ? 16 : 12) {
                    // Level header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(level.label)
                                .font(.system(size: isIPad ? 22 : 18, weight: .bold))
                                .foregroundColor(isSelected ? .black : .white)
                            
                            Text(difficultyText)
                                .font(.system(size: isIPad ? 14 : 12, weight: .medium))
                                .foregroundColor(isSelected ? .black.opacity(0.7) : difficultyColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isSelected ? Color.black.opacity(0.1) : difficultyColor.opacity(0.2))
                                )
                        }
                        
                        Spacer()
                        
                        // Completion indicator
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.black.opacity(0.2) : Color.white.opacity(0.1))
                                .frame(width: isIPad ? 40 : 32, height: isIPad ? 40 : 32)
                            
                            Text("\(level.numberOfPairs)")
                                .font(.system(size: isIPad ? 16 : 14, weight: .bold))
                                .foregroundColor(isSelected ? .black : .white)
                        }
                    }
                    
                    // Emoji preview
                    VStack(spacing: 8) {
                        HStack(spacing: isIPad ? 8 : 6) {
                            ForEach(Array(level.emojis.prefix(4)), id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: isIPad ? 20 : 18))
                                    .scaleEffect(isAnimated ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimated)
                            }
                            if level.emojis.count > 4 {
                                Text("...")
                                    .font(.system(size: isIPad ? 18 : 16))
                                    .foregroundColor(isSelected ? .black.opacity(0.5) : .white.opacity(0.5))
                            }
                        }
                        
                        Text("\(level.numberOfPairs) pairs to match")
                            .font(.system(size: isIPad ? 13 : 11, weight: .medium))
                            .foregroundColor(isSelected ? .black.opacity(0.6) : .white.opacity(0.6))
                    }
                    
                    Spacer()
                }
                .padding(isIPad ? 20 : 16)
                
                // Selection overlay effect
                if isSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 3)
                        .opacity(0.8)
                }
            }
            .frame(height: cardHeight)
            .scaleEffect(isAnimated ? 0.95 : 1.0)
            .shadow(
                color: isSelected ? Color.yellow.opacity(0.4) : difficultyColor.opacity(0.2),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 4
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isAnimated)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
