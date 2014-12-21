// A service used to store and retrieve the login information

import Foundation

let userAccount = "NUIGExams"

class KeychainService {

    class func save(service: String, _ value: String) {
        var data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

        var request = NSMutableDictionary()
        request.setValue(kSecClassGenericPassword, forKey: kSecClass)
        request.setValue(service, forKey: kSecAttrService)
        request.setValue(userAccount, forKey: kSecAttrAccount)
        request.setValue(data, forKey: kSecValueData)

        SecItemDelete(request as CFDictionaryRef)
        let _ = SecItemAdd(request as CFDictionaryRef, nil)
    }

    class func load(service: String) -> String? {
        var request = NSMutableDictionary()
        request.setValue(kSecClassGenericPassword, forKey: kSecClass)
        request.setValue(service, forKey: kSecAttrService)
        request.setValue(userAccount, forKey: kSecAttrAccount)
        request.setValue(kCFBooleanTrue, forKey: kSecReturnData)
        request.setValue(kSecMatchLimitOne, forKey: kSecMatchLimit)

        var result: Unmanaged<AnyObject>? = nil
        let status = SecItemCopyMatching(request, &result)

        if status == errSecSuccess {
            if let op = result?.toOpaque() {
                let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
                return NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
            }
        }
        return nil
    }
}