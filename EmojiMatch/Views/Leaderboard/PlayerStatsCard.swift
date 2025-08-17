import SwiftUI
import GameKit

struct PlayerStatsCard: View {
    let level: Int
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text("#\(rank)")
                    .font(.roundedBold(size: 16))
                    .foregroundColor(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Rank")
                    .font(.roundedBold(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Level \(level)")
                    .font(.roundedBold(size: 18))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(systemName: rankIcon)
                .font(.system(size: 24))
                .foregroundColor(rankColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(rankColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2...3: return "medal.fill"
        case 4...10: return "star.fill"
        default: return "person.fill"
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2...3: return .orange
        case 4...10: return .blue
        default: return .gray
        }
    }
}
