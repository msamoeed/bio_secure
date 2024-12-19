enum KeychainError: Error {
    case encodingFailed
    case decodingFailed
    case accessControlCreationFailed
    case unhandledError(status: OSStatus)
}

extension KeychainError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        case .accessControlCreationFailed:
            return "Failed to create access control"
        case .unhandledError(let status):
            return "Keychain error: \(status)"
        }
    }
}
