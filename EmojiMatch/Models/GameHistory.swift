import SwiftData
import Foundation

@Model
class GameHistory {
    var timeToComplete: TimeInterval
    var date: Date
    var isWin: Bool
    var matchStreak: Int
    var level: Int
    
    init(timeToComplete: TimeInterval, date: Date = Date(), isWin: Bool, matchStreak: Int = 0, level: Int = 1) {
        self.timeToComplete = timeToComplete
        self.date = date
        self.isWin = isWin
        self.matchStreak = matchStreak
        self.level = level
    }
} 