import SwiftUI

struct StartGameView: View {
    let onStartGame: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.enormousSpacing) {
            VStack(spacing: Theme.hugeSpacing) {
                Text("🧠")
                    .font(.system(size: Theme.massiveIconSize))
                
                Text("Memory\nMatch Game")
                    .font(Theme.titleFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Text("Find all pairs within 60 seconds!")
                    .font(Theme.subtitleFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.primaryYellow)
            .cornerRadius(Theme.hugeSpacing)
            
            
            Button(action: onStartGame) {
                Text("Start Game")
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
    }
} 
