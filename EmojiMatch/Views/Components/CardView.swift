import SwiftUI

struct CardView: View {
    let card: GameCard
    let onTap: () -> Void
    @ObservedObject var gameModel: MatchCardsGameModel
    
    var body: some View {
        Button(action: {
            onTap()
            if gameModel.isSoundEnabled {
                SoundManager.playCardFlip()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .fill(cardColor)
                    .frame(height: gameModel.currentLevel.cardHeight)
                
                if card.isMatched || card.isFlipped {
                    Text(card.emoji)
                        .font(.system(size: emojiSize))
                        .opacity(card.isMatched || card.isFlipped ? 1 : 0)
                }
            }
            .rotation3DEffect(
                .degrees(card.isFlipped || card.isMatched ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.3), value: card.isFlipped)
            .animation(.easeInOut(duration: 0.5), value: card.isMatched)
        }
        .disabled(card.isMatched || card.isFlipped)
    }
    
    private var cardCornerRadius: CGFloat {
        gameModel.currentLevel.cardHeight > 100 ? Theme.largeCornerRadius : Theme.mediumCornerRadius
    }
    
    private var emojiSize: CGFloat {
        switch gameModel.currentLevel.numberOfPairs {
        case 6: return Theme.hugeIconSize
        case 8: return 35
        case 10: return 32
        default: return 32
        }
    }
    
    private var cardColor: Color {
        if card.isMatched {
            return Theme.primaryYellow
        } else if card.isFlipped {
            return Theme.primaryPurple
        } else {
            return Theme.secondaryPurple
        }
    }
} 