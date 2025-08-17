import UIKit
import StoreKit

final class ReviewService {
    
    private init() {}
    static let shared = ReviewService()
    private var defaults = UserDefaults.standard
    private let app = UIApplication.shared
    
    private var lastRequest: Date? {
        get {
            return defaults.value(forKey: "ReviewService.lastRequest") as? Date
        }
        set {
            return defaults.set(newValue, forKey: "ReviewService.lastRequest")
        }
    }
    
    private var gamesCompletedCount: Int {
        get {
            return defaults.integer(forKey: "ReviewService.gamesCompleted")
        }
        set {
            defaults.set(newValue, forKey: "ReviewService.gamesCompleted")
        }
    }
    
    private var oneWeekAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    }
    
    private var shouldRequestReview: Bool {
        // Request review after 3 completed games initially
        guard gamesCompletedCount >= 3 else { return false }
        
        if lastRequest == nil {
            return true
        } else if let lastRequest = self.lastRequest, lastRequest < oneWeekAgo {
            return true
        }
        return false
    }
    
    func gameCompleted() {
        gamesCompletedCount += 1
        
        // Request review at strategic moments:
        // - After one game (first time)
        // - Every 10 games after that (if more than a week has passed)
        if shouldRequestReview && (gamesCompletedCount == 1 || gamesCompletedCount % 10 == 0) {
            requestReview()
        }
    }
    
    func requestReview(isWrittenReview: Bool = false) {
        if isWrittenReview {
            let appStoreURL = URL(string: "https://apps.apple.com/app/id6748413149?action=write-review")!
            if app.canOpenURL(appStoreURL) {
                app.open(appStoreURL, options: [:], completionHandler: nil)
            }
        } else {
            guard shouldRequestReview else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    if #available(iOS 18.0, *) {
                        AppStore.requestReview(in: scene)
                    } else {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                    self.lastRequest = Date()
                }
            }
        }
    }
    
    // Force request review (for manual trigger like "Rate App" button)
    @MainActor func forceRequestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
            self.lastRequest = Date()
        }
    }
}
