enum CryptoError: Error {
    case encryptionFailed
    case decryptionFailed
    case invalidKeySize
    case invalidData
}

extension CryptoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .invalidKeySize:
            return "Invalid key size"
        case .invalidData:
            return "Invalid data format"
        }
    }
}

// DeviceSecurityChecker.swift
import LocalAuthentication

class DeviceSecurityChecker {
    static func isDeviceSecure() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if device has passcode set
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return false
        }
        
        // Check if device has biometric capabilities
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        // Get security level
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                // Only passcode available
                return true
            case .touchID, .faceID:
                // Biometric security available
                return true
            @unknown default:
                return true
            }
        }
        
        return true
    }
    
    static func getSecurityLevel() -> SecurityLevel {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return .none
        }
        
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                return .passcode
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                return .passcode
            }
        }
        
        return .passcode
    }
}

enum SecurityLevel {
    case none
    case passcode
    case touchID
    case faceID
}