
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
    
    public override init() {
        super.init()
    }
        
    open func startObservePayments() {
        SKPaymentQueue.default().add(self)
    }
    
    open func loadProducts(productIdentifiers: [String]) {
        let productIds = Set<String>(productIdentifiers)
        let productRequest = SKProductsRequest(productIdentifiers: productIds)
        productRequest.delegate = self
        productRequest.start()
    }
    
    open func purchase(productIdentifier: String) {
        guard canMakePayments else { return }
        guard let product = availableProducts.value.filter({ $0.productIdentifier == productIdentifier }).first else { return }
        let payment = SKPayment(product: product)
        //payment.applicationUsername = userId
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
        let products = response.products.sorted(by: { $0.price.doubleValue < $1.price.doubleValue })
        availableProducts.send(products)
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
