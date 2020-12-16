
#if canImport(StoreKit)
import Foundation
import Combine
import StoreKit

open class FailingPurchaser: NSObject, Purchaser {
  public var purchaseDuration: TimeInterval = 2
  public let availableProducts = CurrentValueSubject<[SKProduct], Never>([])
  public let isPurchasing = CurrentValueSubject<Bool, Never>(false)
  public let successfulPurchase = PassthroughSubject<String, Never>()
  public let restoredPurchase = PassthroughSubject<String, Never>()
  public let failedPurchase = PassthroughSubject<(String, Swift.Error?), Never>()
  
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
      self?.failedPurchase.send((productIdentifier, Error.failedPurchase))
      self?.isPurchasing.send(false)
    }
  }
  
  open func restorePurchases() {
  }
  
  open var canMakePayments: Bool {
    return true
  }
}

extension FailingPurchaser {
  public enum Error: Swift.Error {
    case failedPurchase
  }
}


extension FailingPurchaser: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
  }
}

extension FailingPurchaser: SKPaymentTransactionObserver {
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
