import Foundation

struct GameCard: Identifiable, Equatable {
    let id: Int
    let emoji: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
} 