import SwiftUI

struct GameOverMessageView: View {
    let onNewGame: () -> Void
    let isSubscribed: Bool
    
    // Add InterstitialViewModel only for non-subscribers
    @StateObject private var interstitialViewModel = InterstitialViewModel()
    
    var body: some View {
        VStack(spacing: Theme.enormousSpacing) {
            VStack(spacing: Theme.hugeSpacing) {
                Text("⏰")
                    .font(.system(size: Theme.massiveIconSize))
                
                Text("Time's Up!\nGame Over")
                    .font(Theme.titleFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.primaryYellow)
            .cornerRadius(Theme.hugeSpacing)
            
            // New Game Button - Show ad only for non-subscribers
            Button(action: handleNewGame) {
                Text("New Game")
                    .font(Theme.buttonFont)
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
        }
        .padding(Theme.hugeSpacing)
        .background(Theme.primaryYellow)
        .cornerRadius(Theme.hugeSpacing)
        .onAppear {
            // Load ad only for non-subscribers
            if !isSubscribed {
                loadInterstitialAd()
            }
        }
    }
    
    // MARK: - Ad Methods (only for non-subscribers)
    
    private func loadInterstitialAd() {
        guard !isSubscribed else { return }
        Task {
            await interstitialViewModel.loadAd()
        }
    }
    
    private func handleNewGame() {
        if isSubscribed {
            // Premium users skip ads
            onNewGame()
        } else {
            // Free users see ads
            showAdThenExecute {
                onNewGame()
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
}
