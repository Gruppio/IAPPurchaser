
#if canImport(StoreKit)
import Foundation
import Combine
import StoreKit

public protocol Purchaser: SKPaymentTransactionObserver {
  var availableProducts: CurrentValueSubject<[SKProduct], Never> { get }
  var isPurchasing: CurrentValueSubject<Bool, Never> { get }
  var successfulPurchase: PassthroughSubject<String, Never> { get }
  var restoredPurchase: PassthroughSubject<String, Never> { get }
  var failedPurchase: PassthroughSubject<(String, Error?), Never> { get }
  var canMakePayments: Bool { get }
  func loadProducts(productIdentifiers: [String])
  func purchase(productIdentifier: String)
  func restorePurchases()
  func startObservePayments()
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
}

public extension Purchaser {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
  }
}

open class IAPPurchaser: NSObject, Purchaser {
  public static var shared: Purchaser = IAPPurchaser()
  public let availableProducts = CurrentValueSubject<[SKProduct], Never>([])
  public let isPurchasing = CurrentValueSubject<Bool, Never>(false)
  public let successfulPurchase = PassthroughSubject<String, Never>()
  public let restoredPurchase = PassthroughSubject<String, Never>()
  public let failedPurchase = PassthroughSubject<(String, Error?), Never>()
  private var loadedProductIdentifiers: [String] = []
  private var productRequest: SKProductsRequest?
  
  public override init() {
    super.init()
  }
  
  open func startObservePayments() {
    SKPaymentQueue.default().add(self)
  }
  
  open func loadProducts(productIdentifiers: [String]) {
    loadedProductIdentifiers = productIdentifiers
    productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
    productRequest?.delegate = self
    productRequest?.start()
  }
  
  private func reloadProducts() {
    guard !loadedProductIdentifiers.isEmpty else { return }
    loadProducts(productIdentifiers: loadedProductIdentifiers)
  }
  
  open func purchase(productIdentifier: String) {
    guard canMakePayments,
          let product = availableProducts.value
            .filter({ $0.productIdentifier == productIdentifier })
            .first else { return }
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
    isPurchasing.send(true)
  }
  
  open func restorePurchases() {
    guard canMakePayments else { return }
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  open var canMakePayments: Bool {
    return SKPaymentQueue.canMakePayments()
  }
}

extension IAPPurchaser: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    DispatchQueue.main.async { [weak self] in
      let products = response.products.sorted(by: { $0.price.doubleValue < $1.price.doubleValue })
      self?.availableProducts.send(products)
      
      if products.isEmpty {
        print("IAPPurchaser: Error: No products returned, reloading...")
        self?.reloadProducts()
      }
    }
  }
  
  public func request(_ request: SKRequest, didFailWithError error: Error) {
    print("IAPPurchaser: request did fail with error: \(error)")
    DispatchQueue.main.async { [weak self] in
      self?.reloadProducts()
    }
  }
}

extension IAPPurchaser: SKPaymentTransactionObserver {
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    transactions.forEach { transaction in
      let productIdentifier = transaction.payment.productIdentifier
      switch transaction.transactionState {
      case .purchased:
        successfulPurchase.send(productIdentifier)
        isPurchasing.send(false)
        SKPaymentQueue.default().finishTransaction(transaction)
      case .purchasing:
        isPurchasing.send(true)
      case .failed:
        if let transactionError = transaction.error {
          if (transactionError as NSError).code != SKError.paymentCancelled.rawValue {
            failedPurchase.send((productIdentifier, transaction.error))
          }
        }
        isPurchasing.send(false)
        SKPaymentQueue.default().finishTransaction(transaction)
      case .restored:
        restoredPurchase.send(productIdentifier)
        isPurchasing.send(false)
        SKPaymentQueue.default().finishTransaction(transaction)
      case .deferred: // It can take weeks for approvals
        isPurchasing.send(false)
      @unknown default:
        isPurchasing.send(false)
      }
    }
  }
  
  #if os(macOS) || targetEnvironment(macCatalyst)
  #else
  public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
    return true
  }
  #endif
}
#endif
