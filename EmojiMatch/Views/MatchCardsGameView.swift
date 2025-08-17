import SwiftUI
import SwiftData

struct MatchCardsGameView: View {
    @Binding var currentPage: Int // Add this binding
    @EnvironmentObject var gameModel: MatchCardsGameModel
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    @StateObject private var gameCenterManager = GameCenterManager.shared
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameHistory.date, order: .reverse) private var gameHistory: [GameHistory]
    @State private var showHistory = false
    @State private var showLevelSelection = false
    @State private var dragOffset: CGSize = .zero
    @State private var showSubscription = false
    
    // Migration sheet state
    @State private var showMigrationSheet = false
    @State private var migrationCheckCompleted = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                // NEW: Countdown overlay
                if gameModel.showCountdown {
                    CountdownView(
                        onCountdownComplete: {
                            gameModel.startGameAfterCountdown()
                        },
                        gameModel: gameModel
                    )
                    .zIndex(1) // Ensure countdown appears above everything
                } else {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.smallSpacing) {
                                Text("EMOJI\nMATCH")
                                    .font(.custom("ArialRoundedMTBold", size: 20))
                                    .foregroundColor(Theme.textPrimary)
                                    .multilineTextAlignment(.leading)
                                
                                Text(gameModel.currentLevel.label)
                                    .font(.custom("ArialRoundedMTBold", size: 14))
                                    .foregroundColor(Theme.primaryYellow)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: Theme.largeSpacing) {
                                // Premium subscription button (only if not subscribed)
                                if !revenueCatManager.isSubscribed && !gameModel.isGameActive {
                                    Button(action: {
                                        showSubscription = true
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: Theme.largeIconSize, weight: .medium))
                                                .foregroundColor(.black)
                                        }
                                        .shadow(color: .yellow.opacity(0.3), radius: 5, x: 0, y: 2)
                                        .scaleEffect(1.05)
                                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                
                                
                                // Sound button (always visible)
                                Button(action: {
                                    gameModel.toggleSound()
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                            .fill(Theme.background)
                                            .frame(width: 44, height: 44)
                                        
                                        RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                            .stroke(Theme.textPrimary, lineWidth: 1)
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: gameModel.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                            .font(.system(size: Theme.largeIconSize, weight: .medium))
                                            .foregroundColor(Theme.textPrimary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if gameModel.isGameActive {
                                    // Cancel button (only during active game)
                                    Button(action: {
                                        gameModel.cancelGame()
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                                .fill(Theme.background)
                                                .frame(width: 44, height: 44)
                                            
                                            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                                .stroke(Color.red, lineWidth: 1)
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: "xmark")
                                                .font(.system(size: Theme.largeIconSize, weight: .medium))
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    // Level selection and history buttons (when game is not active)
                                    Button(action: {
                                        showLevelSelection = true
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                                .fill(Theme.background)
                                                .frame(width: 44, height: 44)
                                            
                                            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                                .stroke(Theme.textPrimary, lineWidth: 1)
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: "gamecontroller.fill")
                                                .font(.system(size: Theme.largeIconSize, weight: .medium))
                                                .foregroundColor(Theme.textPrimary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        showHistory = true
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                                .fill(Theme.background)
                                                .frame(width: 44, height: 44)
                                            
                                            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                                .stroke(Theme.textPrimary, lineWidth: 1)
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: "trophy.fill")
                                                .font(.system(size: Theme.largeIconSize, weight: .medium))
                                                .foregroundColor(Theme.textPrimary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, Theme.hugeSpacing)
                        .padding(.top, Theme.hugeSpacing)
                        
                        Spacer()
                        
                        
                        // Timer
                        VStack(spacing: Theme.smallSpacing) {
                            if let bestTime = gameModel.getBestTimeForCurrentLevel(from: gameHistory) {
                                Text(bestTime)
                                    .font(Theme.bestTimeFont)
                                    .foregroundColor(Theme.primaryYellow)
                            }
                            
                            Text(gameModel.formatTime(gameModel.currentTime))
                                .font(Theme.timerFont)
                                .foregroundColor(Theme.textPrimary)
                        }
                        .padding(.bottom, 40)
                        
                        // Game Board
                        if gameModel.showStartScreen {
                            StartGameView(
                                onStartGame: {
                                    gameModel.startNewGame()
                                }
                            )
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .padding(.horizontal, Theme.hugeSpacing)
                        } else if gameModel.showGameOverMessage {
                            GameOverMessageView(
                                onNewGame: {
                                    gameModel.startNewGame()
                                },
                                isSubscribed: revenueCatManager.isSubscribed
                            )
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .padding(.horizontal, Theme.hugeSpacing)
                        } else if gameModel.showWinMessage {
                            WinMessageView(
                                currentLevel: gameModel.currentLevel,
                                completionTime: gameModel.currentTime,
                                onTryAgain: {
                                    gameModel.startNewGameSameLevel()
                                },
                                onNextLevel: {
                                    gameModel.advanceToNextLevel()
                                },
                                isSubscribed: revenueCatManager.isSubscribed
                            )
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .padding(.horizontal, Theme.hugeSpacing)
                        } else {
                            GameBoardView(gameModel: gameModel)
                                .frame(maxWidth: .infinity, maxHeight: 500)
                                .padding(.horizontal, Theme.hugeSpacing)
                        }
                        
                        Spacer()
                        
                        Spacer()
                        
                        if !gameModel.isGameActive {
                            VStack(spacing: 4) {
                                Text("Leaderboards")
                                    .font(.roundedBold(size: 18))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.bottom, 8)
                                
                                Image(systemName: "chevron.compact.down")
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 10)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeInOut, value: gameModel.isGameActive)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage = 1
                                }
                            }
                        }
                    }
                    .offset(y: dragOffset.height)
                    
                    
                }
                
            }
            
            .sheet(isPresented: $showMigrationSheet) {
                MigrationConsentView(
                    gameHistory: gameHistory,
                    onMigrate: {
                        // User agreed to migrate
                        gameModel.migrateToGameCenterWithProgress(gameHistory: gameHistory)
                    },
                    onCancel: {
                        // User declined migration
                        gameCenterManager.markMigrationDeclined()
                    },
                    onDismiss: {
                        // Dismiss the sheet
                        showMigrationSheet = false
                    }
                )
                .presentationDetents([.fraction(0.9)])
                .presentationDragIndicator(.hidden)
            }
            
            .onAppear {
                gameModel.setModelContext(modelContext)
                setupGameCenterMigration()
            }
            .onChange(of: gameCenterManager.isAuthenticated) { isAuthenticated in
                if isAuthenticated && !migrationCheckCompleted {
                    checkAndOfferMigration()
                }
            }
            .onChange(of: gameModel.isGameActive) { isGameActive in
                if !isGameActive && !migrationCheckCompleted {
                    checkAndOfferMigration()
                }
            }
            
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            
            .sheet(isPresented: $showHistory) {
                PlayerHistoryView(gameHistory: gameHistory)
            }
            .sheet(isPresented: $showLevelSelection) {
                LevelSelectionView(selectedLevel: gameModel.currentLevel) { level in
                    gameModel.setLevel(level)
                    // If game is completed, show start screen for new level
                    if gameModel.showWinMessage {
                        gameModel.showStartScreen = true
                        gameModel.showWinMessage = false
                    }
                }
            }
        }
        .onAppear {
            gameModel.setModelContext(modelContext)
        }
    }
    
    private func setupGameCenterMigration() {
        // Listen for GameCenter ready notification
        NotificationCenter.default.addObserver(
            forName: .gameCenterReadyForMigration,
            object: nil,
            queue: .main
        ) { _ in
            checkAndOfferMigration()
        }
    }
    
    private func checkAndOfferMigration() {
        guard !migrationCheckCompleted else { return }
        
        // Small delay to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let shouldOffer = gameCenterManager.shouldOfferMigration(
                gameHistory: gameHistory,
                isGameActive: gameModel.isGameActive
            )
            
            if shouldOffer {
                print("🎯 Showing migration consent sheet")
                showMigrationSheet = true
            }
            
            migrationCheckCompleted = true
        }
    }
    
}
