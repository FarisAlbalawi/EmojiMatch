import SwiftUI
import RevenueCat

struct SubscriptionView: View {
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: Package?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.purple.opacity(0.4),
                        Color.yellow.opacity(0.2),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 15) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 10)
                            
                            Text("Upgrade to Premium")
                                .font(.roundedBold(size: 20))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
               
                        }
                        .padding(.top, 20)
                        
                        // Features
                        VStack(spacing: 24) {
                            FeatureRow(
                                icon: "xmark.circle.fill",
                                title: "No Ads",
                                description: "Enjoy uninterrupted gameplay",
                                color: .green
                            )
                  
                        }
                        .padding(.horizontal, 20)
                        
                        // Subscription Options
                        if let offerings = revenueCatManager.offerings,
                           let currentOffering = offerings.current {
                            
                            VStack(spacing: 16) {
                                Text("Choose Your Plan")
                                    .font(.roundedBold(size: 24))
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                                
                                ForEach(currentOffering.availablePackages, id: \.identifier) { package in
                                    SubscriptionPackageView(
                                        package: package,
                                        isSelected: selectedPackage?.identifier == package.identifier,
                                        onTap: {
                                            selectedPackage = package
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Purchase Button
                        VStack(spacing: 16) {
                            Button(action: purchaseSelected) {
                                HStack {
                                    if revenueCatManager.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    } else {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 20, weight: .bold))
                                        Text("Start Premium")
                                            .font(.roundedBold(size: 20))
                                    }
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .disabled(selectedPackage == nil || revenueCatManager.isLoading)
                            .opacity(selectedPackage == nil ? 0.6 : 1.0)
                            .buttonStyle(PlainButtonStyle())
                            
                            // Restore button
                            Button(action: restorePurchases) {
                                Text("Restore Purchases")
                                    .font(.roundedBold(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                    .underline()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        
                        // Terms and Privacy
                        VStack(spacing: 8) {
                            Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                            
                            Text("Subscription auto-renews unless cancelled 24 hours before the end of the current period")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let currentOffering = revenueCatManager.offerings?.current,
               let firstPackage = currentOffering.availablePackages.first {
                selectedPackage = firstPackage
            }
        }
        .alert("Subscription", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func purchaseSelected() {
        guard let package = selectedPackage else { return }
        
        revenueCatManager.purchasePackage(package) { success, error in
            if success {
                alertMessage = "Welcome to Premium! Enjoy your ad-free experience."
                showingAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else if let error = error {
                alertMessage = "Purchase failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func restorePurchases() {
        revenueCatManager.restorePurchases { success, error in
            if success {
                alertMessage = "Purchases restored successfully!"
                showingAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else {
                alertMessage = error?.localizedDescription ?? "No purchases to restore"
                showingAlert = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.roundedBold(size: 16))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.roundedBold(size: 13))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

struct SubscriptionPackageView: View {
    let package: Package
    let isSelected: Bool
    let onTap: () -> Void
    
    private var packageTitle: String {
        switch package.packageType {
        case .monthly:
            return "Monthly"
        case .annual:
            return "Yearly"
        case .weekly:
            return "Weekly"
        default:
            return package.storeProduct.localizedTitle
        }
    }
    
    private var packageSubtitle: String {
        switch package.packageType {
        case .monthly:
            return "Best for trying out"
        case .annual:
            return "Best value - Save 60%"
        case .weekly:
            return "Perfect for short term"
        default:
            return package.storeProduct.localizedDescription
        }
    }
    
    private var isPopular: Bool {
        return package.packageType == .annual
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
//                if isPopular {
//                    Text("MOST POPULAR")
//                        .font(.system(size: 12, weight: .bold))
//                        .foregroundColor(.black)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 8)
//                        .background(Color.yellow)
//                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(packageTitle)
                                .font(.roundedBold(size: 20))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(package.storeProduct.localizedPriceString)
                                .font(.roundedBold(size: 24))
                                .foregroundColor(.yellow)
                        }
                        
                        Text(packageSubtitle)
                            .font(.roundedBold(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: isPopular ? 16 : 16)
                        .fill(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: isPopular ? 16 : 16)
                                .stroke(
                                    isSelected ? Color.yellow : Color.white.opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(isSelected ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
