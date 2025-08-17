import SwiftUI

struct WinMessageView: View {
    let currentLevel: GameLevel
    let completionTime: TimeInterval
    let onTryAgain: () -> Void
    let onNextLevel: () -> Void
    let isSubscribed: Bool
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    // Add InterstitialViewModel only for non-subscribers
    @StateObject private var interstitialViewModel = InterstitialViewModel()
    
    private var hasNextLevel: Bool {
        currentLevel.rawValue < GameLevel.allCases.count
    }
    
    private var nextLevel: GameLevel? {
        guard hasNextLevel else { return nil }
        return GameLevel(rawValue: currentLevel.rawValue + 1)
    }
    
    var body: some View {
        VStack(spacing: Theme.enormousSpacing) {
            VStack(spacing: Theme.hugeSpacing) {
                Text("🔥")
                    .font(.system(size: Theme.massiveIconSize))
                
                Text("You are on\nfire!")
                    .font(Theme.titleFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Text("Level \(currentLevel.rawValue) completed!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.primaryYellow)
            .cornerRadius(Theme.hugeSpacing)
            
            VStack(spacing: Theme.extraLargeSpacing) {
                // Share Button
                Button(action: shareResult) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                        Text("Share Result")
                            .font(Theme.buttonFont)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.mediumButtonHeight)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(Theme.largeCornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Try Again Button - Modified to show ad first
                Button(action: handleTryAgain) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                        Text("Try Again")
                            .font(Theme.buttonFont)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.mediumButtonHeight)
                    .background(.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                            .stroke(Color.black.opacity(0.5), lineWidth: 1)
                    )
                    .cornerRadius(Theme.largeCornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Next Level Button - Modified to show ad first
                if hasNextLevel {
                    Button(action: handleNextLevel) {
                        HStack {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .medium))
                            Text("Next Level")
                                .font(Theme.buttonFont)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.mediumButtonHeight)
                        .background(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                                .stroke(Color.black.opacity(0.5), lineWidth: 1)
                        )
                        .cornerRadius(Theme.largeCornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                } else {
                    // All levels completed
                    VStack(spacing: Theme.mediumSpacing) {
                        Text("🏆")
                            .font(.system(size: 40))
                        
                        Text("All levels completed!\nYou're a memory master!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.mediumButtonHeight + 20)
                    .background(Theme.primaryYellow.opacity(0.3))
                    .cornerRadius(Theme.largeCornerRadius)
                }
            }
        }
        .padding(Theme.hugeSpacing)
        .background(Theme.primaryYellow)
        .cornerRadius(Theme.hugeSpacing)
        .onAppear {
            prepareShareContent()
            // Load ad only for non-subscribers
            if !isSubscribed {
                loadInterstitialAd()
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }
    
    // MARK: - Ad Methods (only for non-subscribers)
    
    private func loadInterstitialAd() {
        guard !isSubscribed else { return }
        Task {
            await interstitialViewModel.loadAd()
        }
    }
    
    private func handleTryAgain() {
        if isSubscribed {
            // Premium users skip ads
            onTryAgain()
        } else {
            // Free users see ads
            showAdThenExecute {
                onTryAgain()
            }
        }
    }
    
    private func handleNextLevel() {
        if isSubscribed {
            // Premium users skip ads
            onNextLevel()
        } else {
            // Free users see ads
            showAdThenExecute {
                onNextLevel()
            }
        }
    }
    
    private func showAdThenExecute(completion: @escaping () -> Void) {
        guard !isSubscribed else {
            completion()
            return
        }
        
        // Check if ad is ready to show
        if interstitialViewModel.isAdReady {
            // Show the ad first
            interstitialViewModel.showAd()
            
            // Set up a completion handler for when the ad is dismissed
            interstitialViewModel.onAdDismissed = {
                // Execute the game action after ad is dismissed
                completion()
                
                // Pre-load the next ad for future use
                Task {
                    await interstitialViewModel.loadAd()
                }
            }
        } else {
            // No ad available, execute the action immediately
            completion()
            
            // Try to load an ad for next time
            Task {
                await interstitialViewModel.loadAd()
            }
        }
    }

    // MARK: - Existing Methods
    
    private func prepareShareContent() {
        // Create text content to share when view appears
        let emojiText = currentLevel.emojis.joined(separator: " ")
        let timeText = formatTime(completionTime)
        
        let textToShare = """
🧠 Just completed Level \(currentLevel.rawValue) in Emoji Match! 🔥

\(emojiText)

⏱️ Time: \(timeText)
🎯 Level: \(currentLevel.rawValue)
💪 Difficulty: \(difficultyText)

Can you beat my time? 

#EmojiMatchCards #MemoryGame #BrainTraining
"""
        
        shareItems = [textToShare]
    }
    
    private func shareResult() {
        // Only show sheet if we have content to share
        if !shareItems.isEmpty {
            showingShareSheet = true
        }
    }
    
    private var difficultyText: String {
        switch currentLevel.rawValue {
        case 1...5: return "Easy"
        case 6...10: return "Medium"
        case 11...15: return "Hard"
        default: return "Expert"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

// Share Sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        print("🔍 DEBUG: ShareSheet makeUIViewController called")
        print("🔍 DEBUG: activityItems = \(activityItems)")
        
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Ensure we're not excluding text sharing activities
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .print
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
