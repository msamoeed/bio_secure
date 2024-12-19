import LocalAuthentication

class SecureEnclaveAccess {
    private let context = LAContext()
    
    enum BiometricType: String {
        case none = "none"
        case touchID = "touch_id"
        case faceID = "face_id"
    }
    
    func isSecureEnclaveAvailable() -> Bool {
        var error: Unmanaged<CFError>?
        guard let _ = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .privateKeyUsage,
            &error
        ) else {
            return false
        }
        return error == nil
    }
    
    func checkBiometricAvailability(completion: @escaping (Bool, String, Error?) -> Void) {
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                error: &error)
        completion(available, getBiometricTypeSync(), error)
    }
    
    func getBiometricTypeSync() -> String {
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                return BiometricType.none.rawValue
            case .touchID:
                return BiometricType.touchID.rawValue
            case .faceID:
                return BiometricType.faceID.rawValue
            @unknown default:
                return BiometricType.none.rawValue
            }
        }
        return BiometricType.none.rawValue
    }
}