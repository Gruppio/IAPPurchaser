
#if canImport(StoreKit)
import Foundation
import Combine

open class InMemoryPurchasedProductsRegister: PurchasedProductsRegister {
    public var purchasedProducts: CurrentValueSubject<Set<PurchasedProductIdentifier>, Never>
    private let queue = DispatchQueue(label: "InMemoryPurchasedProductsRegister.queue")
    
    public init() {
        purchasedProducts = CurrentValueSubject<Set<PurchasedProductIdentifier>, Never>(Set())
    }
    
    public func registerPurchasedProduct(identifier: PurchasedProductIdentifier) {
        queue.sync { [weak self] in
            guard let self = self else { return }
            var contentPurchasedTemp = self.purchasedProducts.value
            contentPurchasedTemp.insert(identifier)
            self.purchasedProducts.send(contentPurchasedTemp)
        }
    }
}
#endif
