import SwiftUI

struct EnhancedPerformanceChart: View {
    let games: [GameHistory]
    @Binding var selectedIndex: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.largeSpacing) {
            HStack {
                Text("Completion Time (seconds)")
                    .font(Theme.chartLabelFont)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("Recent → Latest")
                    .font(Theme.chartLabelFont)
                    .foregroundColor(Theme.textSecondary)
            }
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let maxTime = games.map { $0.timeToComplete }.max() ?? 60
                let minTime = games.map { $0.timeToComplete }.min() ?? 0
                let timeRange = max(maxTime - minTime, 1)
                
                ZStack {
                    // Grid lines
                    ForEach(0..<5) { i in
                        let y = height * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                        .stroke(Theme.cardBorder, lineWidth: 1)
                    }
                    
                    // Area fill under the chart
                    Path { path in
                        guard !games.isEmpty else { return }
                        
                        // Start from bottom left
                        path.move(to: CGPoint(x: 0, y: height))
                        
                        // Add points along the line
                        for (index, game) in games.enumerated() {
                            let x = width * CGFloat(index) / CGFloat(max(games.count - 1, 1))
                            let normalizedTime = (game.timeToComplete - minTime) / timeRange
                            let y = height * (1 - normalizedTime)
                            
                            if index == 0 {
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        
                        // Close the area by going to bottom right and back to start
                        if let lastIndex = games.indices.last {
                            let lastX = width * CGFloat(lastIndex) / CGFloat(max(games.count - 1, 1))
                            path.addLine(to: CGPoint(x: lastX, y: height))
                            path.addLine(to: CGPoint(x: 0, y: height))
                        }
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.3),
                                Color.orange.opacity(0.1),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Chart line
                    Path { path in
                        for (index, game) in games.enumerated() {
                            let x = width * CGFloat(index) / CGFloat(max(games.count - 1, 1))
                            let normalizedTime = (game.timeToComplete - minTime) / timeRange
                            let y = height * (1 - normalizedTime)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Interactive data points
                    ForEach(Array(games.enumerated()), id: \.offset) { index, game in
                        let x = width * CGFloat(index) / CGFloat(max(games.count - 1, 1))
                        let normalizedTime = (game.timeToComplete - minTime) / timeRange
                        let y = height * (1 - normalizedTime)
                        let isSelected = selectedIndex == index
                        let performanceColor = getPerformanceColor(for: game.timeToComplete)
                        
                        Button(action: {
                            if selectedIndex == index {
                                selectedIndex = nil
                            } else {
                                selectedIndex = index
                            }
                        }) {
                            ZStack {
                                // Glow ring for selected point
                                if isSelected {
                                    Circle()
                                        .stroke(performanceColor, lineWidth: 3)
                                        .frame(width: 20, height: 20)
                                        .opacity(0.7)
                                        .scaleEffect(1.2)
                                        .animation(.easeInOut(duration: 0.3), value: isSelected)
                                }
                                
                                // Shadow
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)
                                    .offset(x: 1, y: 1)
                                
                                // Main point
                                Circle()
                                    .fill(performanceColor)
                                    .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)
                                    .scaleEffect(isSelected ? 1.5 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: isSelected)
                            }
                        }
                        .position(x: x, y: y)
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Tooltip overlay
                    if let selectedIndex = selectedIndex,
                       selectedIndex < games.count {
                        let game = games[selectedIndex]
                        let x = width * CGFloat(selectedIndex) / CGFloat(max(games.count - 1, 1))
                        let normalizedTime = (game.timeToComplete - minTime) / timeRange
                        let y = height * (1 - normalizedTime)
                        
                        InteractiveTooltip(
                            game: game,
                            gameNumber: selectedIndex + 1,
                            position: CGPoint(x: x, y: y),
                            containerSize: CGSize(width: width, height: height)
                        )
                    }
                }
            }
            .frame(height: 200)
        }
    }
    
    private func getPerformanceColor(for time: TimeInterval) -> Color {
        // Performance thresholds (in seconds)
        if time <= 30 { return .green }      // Excellent
        else if time <= 45 { return .yellow } // Good
        else if time <= 55 { return .orange } // Average
        else { return .red }                   // Slow
    }
} 