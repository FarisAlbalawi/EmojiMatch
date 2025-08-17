import SwiftUI
import GameKit

struct LeaderboardRowView: View {
    let rank: Int
    let entry: GKLeaderboard.Entry
    let isLocalPlayer: Bool
    
    @State private var isAnimating = false
    @State private var showDetails = false
    
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

    
    private var displayName: String {
        return entry.player.displayName
    }
    
    var body: some View {
        Button(action: {
            showDetails.toggle()
            impactFeedback()
        }) {
            mainRowContent
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(rank) * 0.1)) {
                isAnimating = true
            }
        }
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .sheet(isPresented: $showDetails) {
            PlayerDetailView(entry: entry, rank: rank)
        }
    }
    
    private var mainRowContent: some View {
        HStack(spacing: 16) {
            // Enhanced Rank Badge
            rankBadge
            
            // Player Info Section
            VStack(alignment: .leading, spacing: 6) {
                // Player Name Row with improved layout
                HStack(spacing: 8) {
                    Text(displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isLocalPlayer ? .yellow : .white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(1)
                    
                    if isLocalPlayer {
                        youBadge
                    }
                    
                    Spacer(minLength: 0)
                }
                
                // Enhanced metadata row
                VStack(alignment: .leading, spacing: 6) {
                    // Date info
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(formatDate(entry.date))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    // Performance indicator
                    HStack(spacing: 4) {
                        Image(systemName: performanceIcon)
                            .font(.system(size: 11))
                            .foregroundColor(performanceColor)
                        
                        Text(performanceText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(performanceColor)
                        
                        // Rank change indicator (placeholder for future feature)
                        if rank <= 10 {
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green.opacity(0.7))
                                
                                Text("Top 10")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.green.opacity(0.7))
                            }
                        }
                    }
                }
            }
            
            // Enhanced Time Display
            timeDisplay
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(backgroundContent)
        .overlay(borderOverlay)
        .shadow(
            color: isLocalPlayer ? Color.yellow.opacity(0.3) : Color.black.opacity(0.2),
            radius: isLocalPlayer ? 8 : 4,
            x: 0,
            y: 2
        )
    }
    
    private var rankBadge: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            rankColor.opacity(0.3),
                            rankColor.opacity(0.1)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
            
            // Border ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            rankColor.opacity(0.6),
                            rankColor.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 50, height: 50)
            
            // Rank content
            Group {
                if rank <= 3 {
                    Image(systemName: rankIcon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(rankColor)
                        .shadow(color: rankColor.opacity(0.3), radius: 2, x: 0, y: 1)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(rankColor)
                }
            }
        }
        .scaleEffect(isLocalPlayer ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isLocalPlayer)
    }
    
    private var youBadge: some View {
        Text("YOU")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow, .orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.3), radius: 2, x: 0, y: 1)
            )
            .fixedSize()
    }
    
    private var timeDisplay: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // Main time
            Text(formattedTime)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(isLocalPlayer ? .yellow : .white)
                .shadow(color: isLocalPlayer ? .yellow.opacity(0.3) : .clear, radius: 2, x: 0, y: 1)
            
            // Time label with improvement indicator
            HStack(spacing: 4) {
                Text("Time")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                
                // Personal best indicator (placeholder)
                if isLocalPlayer && rank <= 5 {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow.opacity(0.7))
                }
            }
        }
    }
    
    private var backgroundContent: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(backgroundGradient)
            .overlay(
                // Subtle pattern overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white.opacity(0.1), location: 0.0),
                                .init(color: .clear, location: 0.3),
                                .init(color: .clear, location: 0.7),
                                .init(color: .white.opacity(0.05), location: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(borderGradient, lineWidth: isLocalPlayer ? 2 : 1)
            .overlay(
                // Highlight effect for top ranks
                Group {
                    if rank <= 3 {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        rankColor.opacity(0.3),
                                        .clear,
                                        rankColor.opacity(0.3)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
            )
    }
    
    // Enhanced background gradient
    private var backgroundGradient: LinearGradient {
        if isLocalPlayer {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.yellow.opacity(0.15),
                    Color.orange.opacity(0.1),
                    Color.white.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.08),
                    Color.white.opacity(0.04)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // Enhanced border gradient
    private var borderGradient: LinearGradient {
        if isLocalPlayer {
            return LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.9, green: 0.9, blue: 0.9) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
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
    
    // Enhanced performance indicators
    private var performanceColor: Color {
        switch timeInSeconds {
        case 0..<20: return .green
        case 20..<30: return .mint
        case 30..<40: return .yellow
        case 40..<50: return .orange
        default: return .red
        }
    }
    
    private var performanceIcon: String {
        switch timeInSeconds {
        case 0..<20: return "bolt.fill"
        case 20..<30: return "flame.fill"
        case 30..<40: return "checkmark.circle.fill"
        case 40..<50: return "clock.fill"
        default: return "tortoise.fill"
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's today
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today"
        }
        
        // Check if it's yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        
        // Check if it's within this week
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
           date > weekAgo {
            formatter.dateFormat = "EEEE" // Day of week
            return formatter.string(from: date)
        }
        
        // For older dates
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func impactFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}
