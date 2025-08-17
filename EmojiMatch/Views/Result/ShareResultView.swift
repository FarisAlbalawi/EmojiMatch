import SwiftUI
import UIKit

struct ShareResultView: View {
    let level: GameLevel
    let completionTime: TimeInterval
    let isWin: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.purple.opacity(0.4),
                    Color.blue.opacity(0.2),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // Header with logo
                VStack(spacing: 12) {
                    Text("MATCH\nCARDS")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .tracking(2)
                    
                    Text("🧠 Memory Game 🧠")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.yellow)
                }
                .padding(.top, 30)
                
                // Achievement banner
                VStack(spacing: 8) {
                    Text("🔥 LEVEL COMPLETED! 🔥")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                        .tracking(1)
                    
                    Text("Level \(level.rawValue) • \(difficultyText)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(difficultyColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(difficultyColor.opacity(0.2))
                        )
                }
                
                // Game board replica
                VStack(spacing: 16) {
                    Text("Completed Pairs")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Mini game grid
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: level.gridColumns),
                        spacing: 6
                    ) {
                        ForEach(createMiniCards(), id: \.id) { card in
                            MiniCardView(card: card)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // Time display
                VStack(spacing: 8) {
                    Text("COMPLETION TIME")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                    
                    Text(formatTime(completionTime))
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    Text(getPerformanceText(for: completionTime))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(getPerformanceColor(for: completionTime))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(getPerformanceColor(for: completionTime).opacity(0.2))
                        )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(getPerformanceColor(for: completionTime).opacity(0.3), lineWidth: 2)
                        )
                )
                
                Spacer()
                
                // Footer
                VStack(spacing: 6) {
                    Text("Challenge your memory!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Download Match Cards Game")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.yellow)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
        .frame(width: 400, height: 700)
    }
    
    // Create mini cards that represent the actual game
    private func createMiniCards() -> [GameCard] {
        var cards: [GameCard] = []
        let emojis = level.emojis
        let numberOfPairs = level.numberOfPairs
        
        for i in 0..<numberOfPairs {
            let emoji = emojis[i % emojis.count]
            cards.append(GameCard(id: i * 2, emoji: emoji, isFlipped: true, isMatched: true))
            cards.append(GameCard(id: i * 2 + 1, emoji: emoji, isFlipped: true, isMatched: true))
        }
        
        return cards.shuffled()
    }
    
    private var difficultyText: String {
        switch level.rawValue {
        case 1...5: return "EASY"
        case 6...10: return "MEDIUM"
        case 11...15: return "HARD"
        default: return "EXPERT"
        }
    }
    
    private var difficultyColor: Color {
        switch level.rawValue {
        case 1...5: return .green
        case 6...10: return .yellow
        case 11...15: return .orange
        default: return .red
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    private func getPerformanceColor(for time: TimeInterval) -> Color {
        if time <= 30 { return .green }
        else if time <= 45 { return .yellow }
        else if time <= 55 { return .orange }
        else { return .red }
    }
    
    private func getPerformanceText(for time: TimeInterval) -> String {
        if time <= 30 { return "EXCELLENT" }
        else if time <= 45 { return "GOOD" }
        else if time <= 55 { return "AVERAGE" }
        else { return "SLOW" }
    }
}

// Mini card component for the share view
struct MiniCardView: View {
    let card: GameCard
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.yellow)
                .frame(height: miniCardHeight)
            
            Text(card.emoji)
                .font(.system(size: emojiSize))
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var miniCardHeight: CGFloat {
        // Adjust based on grid size for optimal fit
        switch card.emoji.count {
        case 6: return 45  // 3x4 grid
        case 8: return 35  // 4x4 grid
        case 10: return 32 // 4x5 grid
        default: return 32
        }
    }
    
    private var emojiSize: CGFloat {
        switch card.emoji.count {
        case 6: return 22
        case 8: return 18
        case 10: return 16
        default: return 16
        }
    }
}

// Extension to convert SwiftUI View to UIImage
extension View {
    func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.bounds = CGRect(origin: .zero, size: CGSize(width: 400, height: 700))
        controller.view.backgroundColor = UIColor.clear
        
        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        return image
    }
}
