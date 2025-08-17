import SwiftUI
import SwiftData

struct LevelSelectionView: View {
    let selectedLevel: GameLevel
    let onLevelSelected: (GameLevel) -> Void
    @Query(sort: \GameHistory.date, order: .reverse) private var gameHistory: [GameHistory]
    @Environment(\.dismiss) private var dismiss
    @State private var currentSelectedLevel: GameLevel
    
    init(selectedLevel: GameLevel, onLevelSelected: @escaping (GameLevel) -> Void) {
        self.selectedLevel = selectedLevel
        self.onLevelSelected = onLevelSelected
        self._currentSelectedLevel = State(initialValue: selectedLevel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.purple.opacity(0.4),
                        Color.blue.opacity(0.2),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 10) {
                    List {
                        ForEach(GameLevel.allCases, id: \.rawValue) { level in
                            LevelRowView(
                                level: level,
                                isSelected: level == currentSelectedLevel,
                                isCompleted: hasCompletedLevel(level),
                                gameHistory: gameHistory,
                                onTap: {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    currentSelectedLevel = level
                                    onLevelSelected(level)
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    
                    // Footer with stats and action buttons
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.yellow)
                                Text("20 levels • Easy to Expert difficulty")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(.orange)
                                Text("60 seconds per game")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: { dismiss() }) {
                                HStack {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                onLevelSelected(currentSelectedLevel)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Play Level \(currentSelectedLevel.rawValue)")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.yellow)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Choose Your Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func hasCompletedLevel(_ level: GameLevel) -> Bool {
        return gameHistory.contains { $0.level == level.rawValue && $0.isWin }
    }
}

struct LevelRowView: View {
    let level: GameLevel
    let isSelected: Bool
    let isCompleted: Bool
    let gameHistory: [GameHistory]
    let onTap: () -> Void
    
    private var difficultyColor: Color {
        switch level.rawValue {
        case 1...5: return .green
        case 6...10: return .yellow
        case 11...15: return .orange
        default: return .red
        }
    }
    
    private var difficultyText: String {
        switch level.rawValue {
        case 1...5: return "Easy"
        case 6...10: return "Medium"
        case 11...15: return "Hard"
        default: return "Expert"
        }
    }
    
    private var bestTime: String? {
        let levelHistory = gameHistory.filter { $0.level == level.rawValue && $0.isWin }
        if let bestGame = levelHistory.min(by: { $0.timeToComplete < $1.timeToComplete }) {
            let minutes = Int(bestGame.timeToComplete) / 60
            let seconds = Int(bestGame.timeToComplete) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        return nil
    }
    
    private var completionCount: Int {
        return gameHistory.filter { $0.level == level.rawValue && $0.isWin }.count
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Level number and status
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.yellow : (isCompleted ? difficultyColor.opacity(0.3) : Color.white.opacity(0.1)))
                        .frame(width: 50, height: 50)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(isSelected ? .black : difficultyColor)
                    } else {
                        Text("\(level.rawValue)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isSelected ? .black : .white)
                    }
                    
                    // Selection indicator
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 56, height: 56)
                    }
                }
                
                // Level info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(level.label)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(difficultyText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(difficultyColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(difficultyColor.opacity(0.2))
                            )
                    }
                    
                    Text("\(level.numberOfPairs) pairs • \(level.emojis.prefix(3).joined()) ...")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Stats row
                    HStack(spacing: 16) {
                        if isCompleted {
                            if let bestTime = bestTime {
                                HStack(spacing: 4) {
                                    Image(systemName: "stopwatch")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue)
                                    Text("Best: \(bestTime)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            if completionCount > 1 {
                                HStack(spacing: 4) {
                                    Image(systemName: "repeat")
                                        .font(.system(size: 12))
                                        .foregroundColor(.green)
                                    Text("\(completionCount)x")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.green)
                                }
                            }
                        } else {
                            Text("Not completed")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                    }
                }
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white.opacity(0.5))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        Color.yellow.opacity(0.2) :
                        (isCompleted ? Color.white.opacity(0.05) : Color.white.opacity(0.02))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.yellow.opacity(0.6) :
                                (isCompleted ? difficultyColor.opacity(0.3) : Color.white.opacity(0.1)),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
