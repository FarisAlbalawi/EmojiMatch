import RevenueCat
import SwiftUI

class RevenueCatManager: NSObject, ObservableObject {
    static let shared = RevenueCatManager()
    
    @Published var isSubscribed = false
    @Published var offerings: Offerings?
    @Published var isLoading = false
    
    private let apiKey = "your kay here"
    
    private override init() {
        super.init()
        setupRevenueCat()
    }
    
    private func setupRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        
        // Set up delegate to listen for subscription changes
        Purchases.shared.delegate = self
        
        // Check current subscription status
        checkSubscriptionStatus()
        
        // Load offerings
        loadOfferings()
    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let customerInfo = customerInfo {
                    // Check if user has any active subscription
                    self?.isSubscribed = customerInfo.entitlements.active.count > 0
                    print("🔍 Subscription status: \(self?.isSubscribed ?? false)")
                    
                    // You can also check for specific entitlements
                    // self?.isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
                } else if let error = error {
                    print("❌ Error checking subscription status: \(error.localizedDescription)")
                    self?.isSubscribed = false
                }
            }
        }
    }
    
    func loadOfferings() {
        isLoading = true
        Purchases.shared.getOfferings { [weak self] offerings, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let offerings = offerings {
                    self?.offerings = offerings
                    print("✅ Offerings loaded: \(offerings.all.keys)")
                } else if let error = error {
                    print("❌ Error loading offerings: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func purchasePackage(_ package: Package, completion: @escaping (Bool, Error?) -> Void) {
        isLoading = true
        Purchases.shared.purchase(package: package) { [weak self] transaction, customerInfo, error, userCancelled in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                
                if let customerInfo = customerInfo {
                    // Update subscription status
                    self.isSubscribed = customerInfo.entitlements.active.count > 0
                    completion(true, nil)
                    print("✅ Purchase successful")
                } else if userCancelled {
                    completion(false, nil)
                    print("⚠️ Purchase cancelled by user")
                } else if let error = error {
                    completion(false, error)
                    print("❌ Purchase failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func restorePurchases(completion: @escaping (Bool, Error?) -> Void) {
        isLoading = true
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let customerInfo = customerInfo {
                    self?.isSubscribed = customerInfo.entitlements.active.count > 0
                    completion(self?.isSubscribed ?? false, nil)
                    print("✅ Restore successful. Subscribed: \(self?.isSubscribed ?? false)")
                } else if let error = error {
                    completion(false, error)
                    print("❌ Restore failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - PurchasesDelegate
extension RevenueCatManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        DispatchQueue.main.async {
            self.isSubscribed = customerInfo.entitlements.active.count > 0
            print("🔄 Customer info updated. Subscribed: \(self.isSubscribed)")
        }
    }
}
