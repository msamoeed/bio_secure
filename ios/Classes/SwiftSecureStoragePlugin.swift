import Flutter
import LocalAuthentication
import Security

@objc(SwiftSecureStoragePlugin)
public class SwiftSecureStoragePlugin: NSObject, FlutterPlugin {
    private let secureEnclaveAccess: SecureEnclaveAccess
    private let integrityChecker: IntegrityChecker
    private let keychainManager: KeychainManager
    
    init(secureEnclaveAccess: SecureEnclaveAccess = SecureEnclaveAccess(),
         integrityChecker: IntegrityChecker = IntegrityChecker(),
         keychainManager: KeychainManager = KeychainManager()) {
        self.secureEnclaveAccess = secureEnclaveAccess
        self.integrityChecker = integrityChecker
        self.keychainManager = keychainManager
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "secure_storage_channel",
                                         binaryMessenger: registrar.messenger())
        let instance = SwiftSecureStoragePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "version_error",
                              message: "This plugin requires iOS 11.0 or later",
                              details: nil))
            return
        }
        
        guard integrityChecker.verifyIntegrity() else {
            result(FlutterError(code: "integrity_check_failed",
                              message: "Security validation failed",
                              details: nil))
            return
        }
        
        switch call.method {
        case "initialize":
            handleInitialize(result: result)
        case "secureStore":
            handleSecureStore(call, result: result)
        case "secureRetrieve":
            handleSecureRetrieve(call, result: result)
        case "secureDelete":
            handleSecureDelete(call, result: result)
        case "clearAll":
            handleClearAll(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleInitialize(result: @escaping FlutterResult) {
        secureEnclaveAccess.checkBiometricAvailability { available, type, error in
            if let error = error {
                result(FlutterError(code: "biometric_error",
                                  message: error.localizedDescription,
                                  details: nil))
                return
            }
            
            result([
                "available": available,
                "biometricType": type,
                "secureEnclaveAvailable": self.secureEnclaveAccess.isSecureEnclaveAvailable()
            ])
        }
    }
    
    private func handleSecureStore(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String,
              let value = args["value"] as? String else {
            result(FlutterError(code: "invalid_arguments",
                              message: "Missing required arguments",
                              details: nil))
            return
        }
        
        keychainManager.store(key: key, value: value) { error in
            if let error = error {
                result(FlutterError(code: "store_error",
                                  message: error.localizedDescription,
                                  details: nil))
                return
            }
            result(nil)
        }
    }
    
    private func handleSecureRetrieve(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String else {
            result(FlutterError(code: "invalid_arguments",
                              message: "Missing required arguments",
                              details: nil))
            return
        }
        
        keychainManager.retrieve(key: key) { value, error in
            if let error = error {
                result(FlutterError(code: "retrieve_error",
                                  message: error.localizedDescription,
                                  details: nil))
                return
            }
            result(value)
        }
    }
    
    private func handleSecureDelete(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String else {
            result(FlutterError(code: "invalid_arguments",
                              message: "Missing required arguments",
                              details: nil))
            return
        }
        
        keychainManager.delete(key: key) { error in
            if let error = error {
                result(FlutterError(code: "delete_error",
                                  message: error.localizedDescription,
                                  details: nil))
                return
            }
            result(nil)
        }
    }
    
    private func handleClearAll(result: @escaping FlutterResult) {
        keychainManager.clearAll { error in
            if let error = error {
                result(FlutterError(code: "clear_error",
                                  message: error.localizedDescription,
                                  details: nil))
                return
            }
            result(nil)
        }
    }
}
