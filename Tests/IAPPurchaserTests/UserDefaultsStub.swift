
import Foundation

open class UserDefaultsStub : UserDefaults {
    
    var storedData = [String : Any]()
        
    open override func object(forKey defaultName: String) -> Any? {
        return storedData[defaultName]
    }
        
    open override func removeObject(forKey defaultName: String) {
        storedData.removeValue(forKey: defaultName)
    }
    
    open override func string(forKey defaultName: String) -> String? {
        return storedData[defaultName] as? String
    }
    
    open override func array(forKey defaultName: String) -> [Any]? {
        return storedData[defaultName] as? [Any]
    }

    open override func dictionary(forKey defaultName: String) -> [String : Any]? {
        return storedData[defaultName] as? [String : Any]
    }

    open override func data(forKey defaultName: String) -> Data? {
        return storedData[defaultName] as? Data
    }

    open override func stringArray(forKey defaultName: String) -> [String]? {
        return storedData[defaultName] as? [String]
    }

    open override func integer(forKey defaultName: String) -> Int {
        return storedData[defaultName] as? Int ?? 0
    }
    
    open override func float(forKey defaultName: String) -> Float {
        return storedData[defaultName] as? Float ?? 0.0
    }
    
    open override func double(forKey defaultName: String) -> Double {
        return storedData[defaultName] as? Double ?? 0.0
    }
    
    open override func bool(forKey defaultName: String) -> Bool {
        return storedData[defaultName] as? Bool ?? false
    }
    
    @available(OSX 10.6, *)
    open override func url(forKey defaultName: String) -> URL? {
        return storedData[defaultName] as? URL
    }
    
    open override func set(_ value: Any?, forKey defaultName: String) {
        storedData[defaultName] = value
    }
    
    open override func set(_ value: Int, forKey defaultName: String) {
        storedData[defaultName] = value
    }
    
    open override func set(_ value: Float, forKey defaultName: String) {
        storedData[defaultName] = value
    }
    
    open override func set(_ value: Double, forKey defaultName: String) {
        storedData[defaultName] = value
    }
    
    open override func set(_ value: Bool, forKey defaultName: String) {
        storedData[defaultName] = value
    }
    
    @available(OSX 10.6, *)
    open override func set(_ url: URL?, forKey defaultName: String) {
        storedData[defaultName] = url
    }
    
    open override func dictionaryRepresentation() -> [String : Any] {
        return storedData
    }
    
    open override func synchronize() -> Bool {
        return true
    }
}
