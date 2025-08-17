import SwiftUI
import GameKit

// MARK: - Player Detail View
struct PlayerDetailView: View {
    let entry: GKLeaderboard.Entry
    let rank: Int
    @Environment(\.dismiss) private var dismiss
    
    private var timeInSeconds: TimeInterval {
        return Double(entry.score) / 100.0
    }
    
    private var formattedTime: String {
        // All scores are now stored as centiseconds, so always convert
        let totalSeconds = Double(entry.score) / 100.0
        
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        let centiseconds = Int((totalSeconds.truncatingRemainder(dividingBy: 1)) * 100)

        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }

    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.blue.opacity(0.2),
                        Color.purple.opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            // Rank badge
                            ZStack {
                                Circle()
                                    .fill(rankColor.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .stroke(rankColor.opacity(0.4), lineWidth: 3)
                                    .frame(width: 80, height: 80)
                                
                                if rank <= 3 {
                                    Image(systemName: rankIcon)
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(rankColor)
                                } else {
                                    Text("\(rank)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(rankColor)
                                }
                            }
                            
                            Text(entry.player.displayName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Rank #\(rank)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Stats Cards
                        VStack(spacing: 16) {
                            // Time card
                            StatCard(
                                title: "Completion Time",
                                value: formattedTime,
                                subtitle: "Minutes:Seconds.Milliseconds",
                                color: .blue
                            )
                            
                            // Date card
                            StatCard(
                                title: "Achievement Date",
                                value: formatDetailedDate(entry.date),
                                subtitle: "When this score was achieved",
                                color: .green
                            )
                            
                            // Performance card
                            StatCard(
                                title: "Performance Rating",
                                value: performanceText,
                                subtitle: getPerformanceDescription(),
                                color: performanceColor
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Player Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.9, green: 0.9, blue: 0.9)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case 4...10: return .blue
        default: return .gray
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
    
    private var performanceColor: Color {
        switch timeInSeconds {
        case 0..<20: return .green
        case 20..<30: return .mint
        case 30..<40: return .yellow
        case 40..<50: return .orange
        default: return .red
        }
    }
    
    private var performanceText: String {
        switch timeInSeconds {
        case 0..<20: return "Lightning"
        case 20..<30: return "Blazing"
        case 30..<40: return "Great"
        case 40..<50: return "Good"
        default: return "Steady"
        }
    }
    
    private func getPerformanceDescription() -> String {
        switch timeInSeconds {
        case 0..<20: return "Exceptional speed - top tier performance"
        case 20..<30: return "Outstanding time - well above average"
        case 30..<40: return "Solid performance - good completion time"
        case 40..<50: return "Decent time - room for improvement"
        default: return "Completed successfully - keep practicing!"
        }
    }
    
    private func formatDetailedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
