import LocalAuthentication

class KeychainManager {
    private let context = LAContext()
    private let accessGroup: String?
    
    init(accessGroup: String? = nil) {
        self.accessGroup = accessGroup
    }
    
    func store(key: String, value: String, completion: @escaping (Error?) -> Void) {
        do {
            guard let data = value.data(using: .utf8) else {
                throw KeychainError.encodingFailed
            }
            
            var query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessControl as String: try createAccessControl(),
                kSecUseAuthenticationUI as String: kSecUseAuthenticationUIAllow,
                kSecAttrSynchronizable as String: kCFBooleanFalse as Any
            ]
            
            if let accessGroup = accessGroup {
                query[kSecAttrAccessGroup as String] = accessGroup
            }
            
            SecItemDelete(query as CFDictionary)
            
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
            
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func retrieve(key: String, completion: @escaping (String?, Error?) -> Void) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIAllow,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let reason = getBiometricPromptMessage()
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                             localizedReason: reason) { success, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            guard status == errSecSuccess,
                  let data = result as? Data,
                  let value = String(data: data, encoding: .utf8) else {
                completion(nil, KeychainError.unhandledError(status: status))
                return
            }
            
            completion(value, nil)
        }
    }
    
    func delete(key: String, completion: @escaping (Error?) -> Void) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            completion(KeychainError.unhandledError(status: status))
            return
        }
        
        completion(nil)
    }
    
    func clearAll(completion: @escaping (Error?) -> Void) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            completion(KeychainError.unhandledError(status: status))
            return
        }
        
        completion(nil)
    }
    
    private func createAccessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        let access: SecAccessControl?
        
        if #available(iOS 11.3, *) {
            access = SecAccessControlCreateWithFlags(nil,
                                                   kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                   [.biometryCurrentSet, .privateKeyUsage],
                                                   &error)
        } else {
            access = SecAccessControlCreateWithFlags(nil,
                                                   kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                   [.biometryAny, .privateKeyUsage],
                                                   &error)
        }
        
        if let error = error?.takeRetainedValue() {
            throw error
        }
        
        guard let accessControl = access else {
            throw KeychainError.accessControlCreationFailed
        }
        
        return accessControl
    }
    
    private func getBiometricPromptMessage() -> String {
        if #available(iOS 11.0, *) {
            return context.biometryType == .faceID ?
                "Authenticate with Face ID to access secure data" :
                "Authenticate with Touch ID to access secure data"
        }
        return "Authenticate to access secure data"
    }
}