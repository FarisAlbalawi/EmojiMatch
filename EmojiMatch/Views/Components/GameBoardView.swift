import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameModel: MatchCardsGameModel
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: Theme.largeSpacing), count: gameModel.currentLevel.gridColumns)
        
        LazyVGrid(columns: columns, spacing: Theme.largeSpacing) {
            ForEach(gameModel.cards) { card in
                CardView(card: card, onTap: {
                    gameModel.selectCard(card)
                }, gameModel: gameModel)
            }
        }
    }
} 