import SwiftUI
import GoogleMobileAds
import UserMessagingPlatform
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let versionNumber = string(for: MobileAds.shared.versionNumber)
    print("Google Mobile Ads SDK version: \(versionNumber)")
    
    // Initialize RevenueCat
    print("🚀 Initializing RevenueCat...")
    
    return true
  }
}

@main
struct MatchCardsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(revenueCatManager)
        }
    }
}
