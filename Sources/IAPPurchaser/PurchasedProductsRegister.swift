
#if canImport(StoreKit)
import Foundation
import Combine

public typealias PurchasedProductIdentifier = String

public protocol PurchasedProductsRegister {
    var purchasedProducts: CurrentValueSubject<Set<PurchasedProductIdentifier>, Never> { get }
    func registerPurchasedProduct(identifier: PurchasedProductIdentifier)
}

open class DefaultPurchasedProductsRegister: PurchasedProductsRegister {
    public var purchasedProducts: CurrentValueSubject<Set<PurchasedProductIdentifier>, Never>
            
    public static var shared: PurchasedProductsRegister = DefaultPurchasedProductsRegister(userDefaults: UserDefaults.standard)
    let key = "ContentPurchasedRegister.contentPurchased"
    let separator = ","
    private let queue = DispatchQueue(label: "DefaultContentPurchasedRegister.queue")
    public var userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        let contents = Set<String>(userDefaults.string(forKey: key)?.split(separator: Character(separator)).map { String($0) } ?? [])
        purchasedProducts = CurrentValueSubject<Set<PurchasedProductIdentifier>, Never>(contents)
    }
    
    public func registerPurchasedProduct(identifier: PurchasedProductIdentifier) {
        queue.sync { [weak self] in
            guard let self = self else { return }
            var contentPurchasedTemp = self.purchasedProducts.value
            contentPurchasedTemp.insert(identifier)
            self.userDefaults.set(contentPurchasedTemp.joined(separator: separator), forKey: key)
            self.purchasedProducts.send(contentPurchasedTemp)
        }
    }
}
#endif
