import SwiftUI

struct CountdownView: View {
    let onCountdownComplete: () -> Void
    @State private var currentNumber = 3
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @ObservedObject var gameModel: MatchCardsGameModel
    
    var body: some View {
        ZStack {
            // Background
            Theme.background
                .ignoresSafeArea()
            
            // Countdown number
            if currentNumber > 0 {
                Text("\(currentNumber)")
                    .font(.system(size: 200, weight: .black, design: .rounded))
                    .foregroundColor(Theme.primaryYellow)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(.easeOut(duration: 0.3), value: scale)
                    .animation(.easeOut(duration: 0.3), value: opacity)
            } else {
                Text("GO!")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(.green)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(.easeOut(duration: 0.3), value: scale)
                    .animation(.easeOut(duration: 0.3), value: opacity)
            }
        }
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        animateNumber()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if currentNumber > 1 {
                currentNumber -= 1
                animateNumber()
                
                // Play countdown sound
                if gameModel.isSoundEnabled {
                    SoundManager.playCountdownTick()
                }
            } else if currentNumber == 1 {
                currentNumber = 0
                animateGo()
                
                // Play start sound
                if gameModel.isSoundEnabled {
                    SoundManager.playCountdownStart()
                }
                
                // Complete countdown after GO! animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    timer.invalidate()
                    onCountdownComplete()
                }
            }
        }
    }
    
    private func animateNumber() {
        // Reset for new animation
        scale = 0.1
        opacity = 0
        
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 1.2
            opacity = 1.0
        }
        
        // Shrink slightly after appearing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.4)) {
                scale = 1.0
            }
        }
    }
    
    private func animateGo() {
        // Reset for GO! animation
        scale = 0.1
        opacity = 0
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            scale = 1.3
            opacity = 1.0
        }
        
        // Pulse effect for GO!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 1.1
            }
        }
    }
}
