import GoogleMobileAds
import SwiftUI

class InterstitialViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    private var interstitialAd: InterstitialAd?
    
    // Completion handler for when ad is dismissed
    var onAdDismissed: (() -> Void)?
    
    // Public property to check if ad is ready
    var isAdReady: Bool {
        return interstitialAd != nil
    }
    
    func loadAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: "ca-app-pub-7843269927056167/8734146732",
                request: Request()
            )
            interstitialAd?.fullScreenContentDelegate = self
            print("✅ Interstitial ad loaded successfully")
        } catch {
            print("❌ Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    func showAd() {
        guard let interstitialAd = interstitialAd else {
            print("⚠️ Ad wasn't ready, executing action immediately")
            // If ad isn't ready, execute the completion immediately
            onAdDismissed?()
            return
        }
        
        // Find the root view controller to present from
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            interstitialAd.present(from: rootViewController)
        } else {
            print("⚠️ Could not find root view controller, executing action immediately")
            onAdDismissed?()
        }
    }
    
    // MARK: - GADFullScreenContentDelegate methods
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("❌ Ad failed to present: \(error.localizedDescription)")
        // If ad fails to present, execute the completion immediately
        onAdDismissed?()
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📺 Ad will present full screen content")
    }
    
    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📺 Ad will dismiss full screen content")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📺 Ad did dismiss full screen content")
        // Clear the interstitial ad
        interstitialAd = nil
        
        // Execute the completion handler
        onAdDismissed?()
    }
}
