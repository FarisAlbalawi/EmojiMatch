import SwiftUI
import SwiftData
import Foundation

class MatchCardsGameModel: ObservableObject {
    @Published var cards: [GameCard] = []
    @Published var flippedCards: [GameCard] = []
    @Published var currentTime: TimeInterval = 0
    @Published var timeRemaining: TimeInterval = 60.0
    @Published var showWinMessage = false
    @Published var showGameOverMessage = false
    @Published var showStartScreen = true
    @Published var showCountdown = false
    @Published var isProcessingMatch = false
    @Published var isSoundEnabled = true
    @Published var currentLevel: GameLevel = .level1 {
        didSet {
            // Save to UserDefaults whenever level changes
            saveCurrentLevel()
        }
    }
    
    private var timer: Timer?
    private var startTime: Date?
    private let gameTimeLimit: TimeInterval = 60.0
    private var matchStreak = 0
    private var modelContext: ModelContext?
    
    // UserDefaults key for storing current level
    private let currentLevelKey = "MatchCards_CurrentLevel"
    
    init() {
        // Load saved level on initialization
        loadCurrentLevel()
    }
    
    var isGameActive: Bool {
        return !showStartScreen && !showWinMessage && !showGameOverMessage
    }
    
    // MARK: - UserDefaults Methods
    
    private func saveCurrentLevel() {
        UserDefaults.standard.set(currentLevel.rawValue, forKey: currentLevelKey)
        print("🔍 Saved current level: \(currentLevel.rawValue)")
    }
    
    private func loadCurrentLevel() {
        let savedLevelValue = UserDefaults.standard.integer(forKey: currentLevelKey)
        
        // If no saved level (returns 0), start with level 1
        if savedLevelValue == 0 {
            currentLevel = .level1
            print("🔍 No saved level found, starting with Level 1")
        } else if let savedLevel = GameLevel(rawValue: savedLevelValue) {
            currentLevel = savedLevel
            print("🔍 Loaded saved level: \(savedLevel.rawValue)")
        } else {
            // Fallback to level 1 if saved value is invalid
            currentLevel = .level1
            print("🔍 Invalid saved level (\(savedLevelValue)), defaulting to Level 1")
        }
    }
    
    // MARK: - Game Control Methods
    
    func startNewGameSameLevel() {
        startNewGame()
    }
    
    func setLevel(_ level: GameLevel) {
        if isGameActive {
            cancelGame()
        }
        currentLevel = level // This will automatically save via didSet
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    func saveGameResult(context: ModelContext, isWin: Bool) {
        let gameResult = GameHistory(
            timeToComplete: currentTime,
            date: Date(),
            isWin: isWin,
            matchStreak: matchStreak,
            level: currentLevel.rawValue
        )
        context.insert(gameResult)
        
        do {
            try context.save()
            
            // ADDED: Trigger review request after saving game result
            if isWin {
                ReviewService.shared.gameCompleted()
                
                // NEW: Submit score to GameCenter leaderboard when game is won
                submitScoreToGameCenter()
            }
        } catch {
            print("Failed to save game result: \(error)")
        }
    }
    
    // NEW: Submit score to GameCenter
    private func submitScoreToGameCenter() {
        let gameCenterManager = GameCenterManager.shared
        
        // Only submit if player is authenticated and game was won
        guard gameCenterManager.isAuthenticated else {
            print("⚠️ Not submitting to GameCenter: not authenticated")
            return
        }
        
        // Submit the completion time for the current level
        gameCenterManager.submitScore(level: currentLevel.rawValue, timeInSeconds: currentTime)
        print("🏆 Attempting to submit score to GameCenter: Level \(currentLevel.rawValue), Time: \(currentTime)s")
    }
    
    // UPDATED: Start countdown instead of going directly to game
    func startNewGame() {
        showStartScreen = false
        showWinMessage = false
        showGameOverMessage = false
        showCountdown = true
        isProcessingMatch = false
        flippedCards.removeAll()
        currentTime = 0
        timeRemaining = gameTimeLimit
        matchStreak = 0
        createCards()
    }
    
    func startGameAfterCountdown() {
        showCountdown = false
        startTime = Date()
        startTimer()
    }
    
    func cancelGame() {
        timer?.invalidate()
        timer = nil
        showStartScreen = true
        showWinMessage = false
        showGameOverMessage = false
        showCountdown = false
        isProcessingMatch = false
        flippedCards.removeAll()
        currentTime = 0
        timeRemaining = gameTimeLimit
        startTime = nil
        matchStreak = 0
        cards.removeAll()
    }
    
    func advanceToNextLevel() {
        // Advance to next level if available
        if currentLevel.rawValue < GameLevel.allCases.count {
            if let nextLevel = GameLevel(rawValue: currentLevel.rawValue + 1) {
                currentLevel = nextLevel // This will automatically save via didSet
                print("🚀 Advanced to next level: \(nextLevel.rawValue)")
            }
        }
        startNewGame()
    }
    
    private func createCards() {
        var newCards: [GameCard] = []
        let emojis = currentLevel.emojis
        let numberOfPairs = currentLevel.numberOfPairs
        
        for i in 0..<numberOfPairs {
            let emoji = emojis[i % emojis.count]
            newCards.append(GameCard(id: i * 2, emoji: emoji))
            newCards.append(GameCard(id: i * 2 + 1, emoji: emoji))
        }
        
        cards = newCards.shuffled()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if let startTime = self.startTime {
                self.currentTime = Date().timeIntervalSince(startTime)
                self.timeRemaining = max(0, self.gameTimeLimit - self.currentTime)
                
                if self.timeRemaining <= 0 {
                    self.timer?.invalidate()
                    if self.isSoundEnabled {
                        SoundManager.playLose()
                    }
                    if let context = self.modelContext {
                        self.saveGameResult(context: context, isWin: false)
                    }
                    self.showGameOverMessage = true
                }
            }
        }
    }
    
    func selectCard(_ card: GameCard) {
        guard !card.isFlipped && !card.isMatched && !isProcessingMatch && flippedCards.count < 2 && timeRemaining > 0 else { return }
        
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFlipped = true
            flippedCards.append(cards[index])
            
            if flippedCards.count == 2 {
                isProcessingMatch = true
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        guard flippedCards.count == 2 else { return }
        
        let firstCard = flippedCards[0]
        let secondCard = flippedCards[1]
        
        if firstCard.emoji == secondCard.emoji {
            matchStreak += 1
            if isSoundEnabled {
                SoundManager.playMatch()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let firstIndex = self.cards.firstIndex(where: { $0.id == firstCard.id }),
                   let secondIndex = self.cards.firstIndex(where: { $0.id == secondCard.id }) {
                    self.cards[firstIndex].isMatched = true
                    self.cards[secondIndex].isMatched = true
                }
                self.flippedCards.removeAll()
                self.isProcessingMatch = false
                self.checkForWin()
            }
        } else {
            if isSoundEnabled {
                SoundManager.playNoMatch()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let firstIndex = self.cards.firstIndex(where: { $0.id == firstCard.id }),
                   let secondIndex = self.cards.firstIndex(where: { $0.id == secondCard.id }) {
                    self.cards[firstIndex].isFlipped = false
                    self.cards[secondIndex].isFlipped = false
                }
                self.flippedCards.removeAll()
                self.isProcessingMatch = false
            }
        }
    }
    
    private func checkForWin() {
        if cards.allSatisfy({ $0.isMatched }) {
            timer?.invalidate()
            if isSoundEnabled {
                SoundManager.playWin()
            }
            if let context = modelContext {
                saveGameResult(context: context, isWin: true)
            }
            showWinMessage = true
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    func getBestTimeForCurrentLevel(from history: [GameHistory]) -> String? {
        let levelHistory = history.filter { $0.level == currentLevel.rawValue && $0.isWin }
        
        if let bestGame = levelHistory.min(by: { $0.timeToComplete < $1.timeToComplete }) {
            return formatTime(bestGame.timeToComplete)
        } else {
            return nil
        }
    }
}


extension MatchCardsGameModel {
    /// Trigger GameCenter migration with progress tracking
    func migrateToGameCenterWithProgress(gameHistory: [GameHistory]) {
        print("🔄 Starting GameCenter migration with progress tracking")
        GameCenterManager.shared.migrateGameHistoryWithProgress(gameHistory: gameHistory)
    }
}
