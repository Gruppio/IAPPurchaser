
#if canImport(StoreKit)
import Foundation
import Combine
import StoreKit

open class SuccessfulPurchaser: NSObject, Purchaser {
  public var purchaseDuration: TimeInterval = 2
  public let availableProducts = CurrentValueSubject<[SKProduct], Never>([])
  public let isPurchasing = CurrentValueSubject<Bool, Never>(false)
  public let successfulPurchase = PassthroughSubject<String, Never>()
  public let restoredPurchase = PassthroughSubject<String, Never>()
  public let failedPurchase = PassthroughSubject<(String, Error?), Never>()
  
  public override init() {
    super.init()
  }
  
  open func startObservePayments() {
  }
  
  open func loadProducts(productIdentifiers: [String]) {
  }
  
  open func purchase(productIdentifier: String) {
    isPurchasing.send(true)
    DispatchQueue.main.asyncAfter(deadline: .now() + purchaseDuration) { [weak self] in
      self?.successfulPurchase.send(productIdentifier)
      self?.isPurchasing.send(false)
    }
  }
  
  open func restorePurchases() {
  }
  
  open var canMakePayments: Bool {
    return true
  }
}

extension SuccessfulPurchaser: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
  }
}

extension SuccessfulPurchaser: SKPaymentTransactionObserver {
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
  }
  
  #if os(macOS) || targetEnvironment(macCatalyst)
  #else
  public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
    return true
  }
  #endif
}
#endif
