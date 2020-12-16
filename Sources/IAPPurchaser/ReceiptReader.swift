
#if canImport(StoreKit)
import Foundation
import StoreKit
import Combine
import TPInAppReceipt

public protocol ReceiptReader {
  var bundleIdentifier: String? { get }
  var appVersion: String? { get }
  var allPurchases: CurrentValueSubject<[String], Never> { get }
  var validSubscriptions: CurrentValueSubject<[String], Never> { get }
  func readReceipt()
  func refreshReceipt()
}

class ReceiptRefreshDelegate: NSObject, SKRequestDelegate {
  var refreshReceiptHandler: (() -> Void)?
  
  override init() {
    super.init()
  }
  
  func requestDidFinish(_ request: SKRequest) {
    refreshReceiptHandler?()
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    refreshReceiptHandler?()
  }
}

public class DefaultReceiptReader: ReceiptReader {
  enum Error: Swift.Error {
    case nilReceiptUrl
    case nilReceipt
  }
  
  public static let shared = DefaultReceiptReader()
  private let receiptRefreshDelegate = ReceiptRefreshDelegate()
  private var receipt: InAppReceipt? {
    didSet {
      readReceiptContent()
    }
  }
  public var allPurchases = CurrentValueSubject<[String], Never>([])
  public var validSubscriptions = CurrentValueSubject<[String], Never>([])
  
  private init() {
    receiptRefreshDelegate.refreshReceiptHandler = { [weak self] in
      ((try? self?.readReceiptIfPossible()) as ()??)
    }
    readReceipt()
  }
  
  public var bundleIdentifier: String? {
    return receipt?.bundleIdentifier
  }
  
  public var appVersion: String? {
    return receipt?.appVersion
  }
  
  public func readReceipt() {
    do {
      try readReceiptIfPossible()
    } catch {
      refreshReceipt()
    }
  }
  
  public func refreshReceipt() {
    let request = SKReceiptRefreshRequest()
    request.delegate = receiptRefreshDelegate
    request.start()
  }
  
  private func readReceiptContent() {
    guard let receipt = receipt else { return }
    
    let validSubscriptionsValue = receipt
      .activeAutoRenewableSubscriptionPurchases
      .filter ({ $0.subscriptionExpirationDate?.timeIntervalSinceNow ?? 0 > 0 })
      .compactMap { $0.productIdentifier }
    
    
    let allPurchasesValue = receipt
      .purchases
      .compactMap { $0.productIdentifier }
    
    validSubscriptions.send(validSubscriptionsValue)
    allPurchases.send(allPurchasesValue)
  }
  
  private func readReceiptIfPossible() throws {
    do {
      receipt = try InAppReceipt.localReceipt()
    } catch {
      print(error)
    }
  }
}
#endif
