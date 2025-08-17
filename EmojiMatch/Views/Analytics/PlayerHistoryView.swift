import SwiftUI

struct PlayerHistoryView: View {
    let gameHistory: [GameHistory]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Theme.background,
                        Color.purple.opacity(0.3),
                        Theme.background
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 5) {
                    HStack(spacing: 0) {
                        TabButton(title: "Stats", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "Progress", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        TabButton(title: "History", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.horizontal, Theme.hugeSpacing)
                    .padding(.top, Theme.hugeSpacing)
                    
                    TabView(selection: $selectedTab) {
                        StatsView(gameHistory: gameHistory)
                            .tag(0)
                        
                        ProgressChartView(gameHistory: gameHistory)
                            .tag(1)
                        
                        HistoryListView(gameHistory: gameHistory)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Player Analytics")
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
} 
