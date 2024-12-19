struct SecurityConstants {
    static let keySize = kCCKeySizeAES256
    static let serviceIdentifier = "com.yourdomain.securestorage"
    static let accessGroup = "your.team.identifier.securestorage"
    
    struct ErrorDomain {
        static let security = "com.yourdomain.securestorage.security"
        static let keychain = "com.yourdomain.securestorage.keychain"
        static let biometric = "com.yourdomain.securestorage.biometric"
    }
    
    struct BiometricPrompt {
        static let faceID = "Authenticate with Face ID to access secure data"
        static let touchID = "Authenticate with Touch ID to access secure data"
        static let generic = "Authenticate to access secure data"
    }
}