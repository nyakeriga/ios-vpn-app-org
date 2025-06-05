import Foundation
import StoreKit

@MainActor
class StoreManager: NSObject, ObservableObject {
    static let shared = StoreManager()

    private let productID = "com.example.iosvpn.subscription" // 🔁 Replace with your real product ID
    private var product: SKProduct?

    @Published var isSubscribed: Bool = false
    @Published var productTitle: String = ""

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProduct()
        loadSubscriptionStatus()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Fetch Product Info

    private func fetchProduct() {
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }

    // MARK: - Purchase Flow

    func purchase() {
        guard let product = product else {
            print("⚠️ Product not loaded yet.")
            return
        }

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - Subscription State Management

    private func loadSubscriptionStatus() {
        let defaults = UserDefaults.standard
        isSubscribed = defaults.bool(forKey: "isSubscribed")
    }

    private func updateSubscriptionStatus(_ subscribed: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(subscribed, forKey: "isSubscribed")
        DispatchQueue.main.async {
            self.isSubscribed = subscribed
        }
    }

    func resetSubscriptionStatus() {
        updateSubscriptionStatus(false)
    }
}

// MARK: - SKProductsRequestDelegate

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let fetchedProduct = response.products.first else {
            print("❌ No product found for ID: \(productID)")
            return
        }

        product = fetchedProduct
        DispatchQueue.main.async {
            self.productTitle = fetchedProduct.localizedTitle
        }

        print("✅ Product loaded: \(fetchedProduct.localizedTitle)")
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("❌ Failed to fetch products: \(error.localizedDescription)")
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handleSuccessfulPurchase(transaction)
            case .restored:
                handleRestoredPurchase(transaction)
            case .failed:
                handleFailedTransaction(transaction)
            default:
                break
            }
        }
    }

    private func handleSuccessfulPurchase(_ transaction: SKPaymentTransaction) {
        updateSubscriptionStatus(true)
        SKPaymentQueue.default().finishTransaction(transaction)
        print("✅ Purchase completed and subscription activated.")
    }

    private func handleRestoredPurchase(_ transaction: SKPaymentTransaction) {
        updateSubscriptionStatus(true)
        SKPaymentQueue.default().finishTransaction(transaction)
        print("✅ Subscription restored.")
    }

    private func handleFailedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as NSError?, error.code != SKError.paymentCancelled.rawValue {
            print("❌ Transaction failed: \(error.localizedDescription)")
        } else {
            print("⚠️ Transaction cancelled by user.")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let restored = queue.transactions.contains { $0.transactionState == .restored }
        if restored {
            updateSubscriptionStatus(true)
            print("✅ Restored previous subscription.")
        } else {
            print("ℹ️ No purchases to restore.")
        }
    }
}

