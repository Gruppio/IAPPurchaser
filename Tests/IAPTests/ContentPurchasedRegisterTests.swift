
import XCTest
import Combine
@testable import IAP

final class ContentPurchasedRegisterTests: XCTestCase {
    let key = "ContentPurchasedRegister.contentPurchased"
    var userDefaults: UserDefaults!
    var sut: PurchasedProductsRegister!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaultsStub()
        sut = DefaultPurchasedProductsRegister(userDefaults: userDefaults)
    }
    
    func testInitFromUserDefaults() {
        userDefaults = UserDefaultsStub()
        userDefaults.set("1,2", forKey: key)
        sut = DefaultPurchasedProductsRegister(userDefaults: userDefaults)
        let contentsPurchased = sut.purchasedProducts.value
        
        XCTAssertEqual(contentsPurchased.count, 2)
        XCTAssert(contentsPurchased.contains("1"))
        XCTAssert(contentsPurchased.contains("2"))
    }
    
    func testRegisterContentPurchasedUpdateVariable() {
        let content = "content"
        sut.registerPurchasedProduct(identifier: content)
        let contentsPurchased = sut.purchasedProducts.value
        
        XCTAssertEqual(contentsPurchased.count, 1)
        XCTAssert(contentsPurchased.contains(content))
    }
    
    func testRegisterMultipleContentPurchasedUpdateVariable() {
        let content1 = "content1"
        let content2 = "content2"
        sut.registerPurchasedProduct(identifier: content1)
        sut.registerPurchasedProduct(identifier: content2)
        let contentsPurchased = sut.purchasedProducts.value
        
        XCTAssertEqual(contentsPurchased.count, 2)
        XCTAssert(contentsPurchased.contains(content1))
        XCTAssert(contentsPurchased.contains(content2))
    }
    
    func testRegisterContentPurchasedStoresToUserDefaults() {
        let content = "content"
        sut.registerPurchasedProduct(identifier: content)
        XCTAssertEqual(userDefaults.string(forKey: key), content)
    }
    
    func testRegisterMultipleContentPurchasedStoresToUserDefaults() {
        let content1 = "content1"
        let content2 = "content2"
        sut.registerPurchasedProduct(identifier: content1)
        sut.registerPurchasedProduct(identifier: content2)
        XCTAssertTrue([
            "\(content1),\(content2)",
            "\(content2),\(content1)"]
            .contains(userDefaults.string(forKey: key)!))
    }
    
    func testRegisterMultipleTimesSameContentToUserDefaults() {
        let content1 = "content1"
        sut.registerPurchasedProduct(identifier: content1)
        sut.registerPurchasedProduct(identifier: content1)
        XCTAssertEqual(userDefaults.string(forKey: key), "\(content1)")
    }
    
}

extension ContentPurchasedRegisterTests {
    static var allTests = [
        ("testRegisterMultipleTimesSameContentToUserDefaults", testRegisterMultipleTimesSameContentToUserDefaults),
        ("testRegisterContentPurchasedUpdateVariable", testRegisterContentPurchasedUpdateVariable),
        ("testRegisterMultipleContentPurchasedUpdateVariable", testRegisterMultipleContentPurchasedUpdateVariable),
        ("testRegisterContentPurchasedStoresToUserDefaults", testRegisterContentPurchasedStoresToUserDefaults),
        ("testRegisterMultipleContentPurchasedStoresToUserDefaults", testRegisterMultipleContentPurchasedStoresToUserDefaults),
        ("testRegisterMultipleTimesSameContentToUserDefaults", testRegisterMultipleTimesSameContentToUserDefaults),
    ]
}
