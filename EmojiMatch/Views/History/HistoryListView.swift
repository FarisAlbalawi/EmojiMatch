import SwiftUI

struct HistoryListView: View {
    let gameHistory: [GameHistory]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.largeSpacing) {
                ForEach(gameHistory.prefix(50), id: \.date) { game in
                    EnhancedHistoryRowView(game: game)
                }
            }
            .padding(.horizontal, Theme.hugeSpacing)
            .padding(.vertical, Theme.hugeSpacing)
        }
    }
} 