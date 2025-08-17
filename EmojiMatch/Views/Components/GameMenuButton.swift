import SwiftUI

struct GameMenuButton: View {
    let onLevelSelection: () -> Void
    let onHistory: () -> Void
    let isGameCenterAuthenticated: Bool
    
    var body: some View {
        Menu {
            Section {
                Button(action: onLevelSelection) {
                    Label("Level Selection", systemImage: "gamecontroller.fill")
                }
                
                Button(action: onHistory) {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
            }
        } label: {
            MenuButtonLabel()
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
}

struct MenuButtonLabel: View {
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .fill(Theme.background)
                .frame(width: 44, height: 44)
            
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .stroke(Theme.textPrimary, lineWidth: 1)
                .frame(width: 44, height: 44)
            
            VStack(spacing: 2) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Theme.textPrimary)
                        .frame(width: 4, height: 4)
                }
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// Alternative compact menu with custom styling
struct CompactGameMenu: View {
    let onLevelSelection: () -> Void
    let onLeaderboards: () -> Void
    let onHistory: () -> Void
    let isGameCenterAuthenticated: Bool
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            // Menu button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showMenu.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                        .fill(Theme.background)
                        .frame(width: 44, height: 44)
                    
                    RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                        .stroke(Theme.textPrimary, lineWidth: 1)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                        .font(.system(size: Theme.largeIconSize, weight: .medium))
                        .foregroundColor(Theme.textPrimary)
                        .rotationEffect(.degrees(showMenu ? 0 : 0))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Custom menu overlay
            if showMenu {
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        MenuItemView(
                            icon: "gamecontroller.fill",
                            title: "Levels",
                            action: {
                                withAnimation {
                                    showMenu = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onLevelSelection()
                                }
                            }
                        )
                        
                        MenuItemView(
                            icon: "list.number",
                            title: "Leaderboards",
                            isSpecial: isGameCenterAuthenticated,
                            action: {
                                withAnimation {
                                    showMenu = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onLeaderboards()
                                }
                            }
                        )
                        
                        MenuItemView(
                            icon: "trophy.fill",
                            title: "Stats",
                            action: {
                                withAnimation {
                                    showMenu = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onHistory()
                                }
                            }
                        )
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .offset(y: -60)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture {
            if showMenu {
                withAnimation {
                    showMenu = false
                }
            }
        }
    }
}

struct MenuItemView: View {
    let icon: String
    let title: String
    var isSpecial: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSpecial ? .green : .white)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSpecial {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
