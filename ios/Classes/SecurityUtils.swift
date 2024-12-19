
// SecurityUtils.swift
import Foundation
import CommonCrypto

class SecurityUtils {
    static func randomKey(length: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        guard result == errSecSuccess else {
            fatalError("Failed to generate random key")
        }
        return Data(bytes)
    }
    
    static func encrypt(data: Data, key: Data) throws -> Data {
        let bufferSize = size_t(data.count + kCCBlockSizeAES128)
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        let ivSize = kCCBlockSizeAES128
        let iv = randomKey(length: ivSize)
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = key.withUnsafeBytes { keyBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    CCCrypt(CCOperation(kCCEncrypt),
                           CCAlgorithm(kCCAlgorithmAES),
                           CCOptions(kCCOptionPKCS7Padding),
                           keyBytes.baseAddress, key.count,
                           ivBytes.baseAddress,
                           dataBytes.baseAddress, data.count,
                           &buffer, bufferSize,
                           &numBytesEncrypted)
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            throw CryptoError.encryptionFailed
        }
        
        let encrypted = Data(bytes: buffer, count: numBytesEncrypted)
        return iv + encrypted
    }
    
    static func decrypt(data: Data, key: Data) throws -> Data {
        let ivSize = kCCBlockSizeAES128
        let iv = data.prefix(ivSize)
        let encryptedData = data.suffix(from: ivSize)
        
        let bufferSize = size_t(encryptedData.count + kCCBlockSizeAES128)
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = key.withUnsafeBytes { keyBytes in
            encryptedData.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    CCCrypt(CCOperation(kCCDecrypt),
                           CCAlgorithm(kCCAlgorithmAES),
                           CCOptions(kCCOptionPKCS7Padding),
                           keyBytes.baseAddress, key.count,
                           ivBytes.baseAddress,
                           dataBytes.baseAddress, encryptedData.count,
                           &buffer, bufferSize,
                           &numBytesDecrypted)
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            throw CryptoError.decryptionFailed
        }
        
        return Data(bytes: buffer, count: numBytesDecrypted)
    }
}
