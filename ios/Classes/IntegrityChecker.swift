import UIKit
import MachO

class IntegrityChecker {
    func verifyIntegrity() -> Bool {
        if isJailbroken() || isDebugged() || isReverseEngineered() {
            return false
        }
        return true
    }
    
    private func isJailbroken() -> Bool {
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/stash",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/private/var/tmp/cydia.log",
            "/Applications/FakeCarrier.app",
            "/Applications/Icy.app",
            "/Applications/IntelliScreen.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/SBSettings.app",
            "/Applications/WinterBoard.app"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        let path = "/private/jailbreak.txt"
        do {
            try "test".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            // Expected to fail on non-jailbroken devices
        }
        
        // Check for suspicious symbolic links
        if let url = URL(string: "/Applications") {
            do {
                let properties = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
                if properties.isSymbolicLink == true {
                    return true
                }
            } catch {}
        }
        
        return false
    }
    
    private func isDebugged() -> Bool {
        // Check for debugger
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let jailbroken = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0) != 0
        
        // Check for common debugging environment variables
        let suspiciousEnv = ["DYLD_INSERT_LIBRARIES", "DYLD_FORCE_FLAT_NAMESPACE", "DYLD_IMAGE_SUFFIX"]
        for env in suspiciousEnv {
            if getenv(env) != nil {
                return true
            }
        }
        
        return jailbroken
    }
    
    private func isReverseEngineered() -> Bool {
        // Check for known reverse engineering tools
        let suspiciousLibraries = [
            "FridaGadget",
            "frida",
            "cynject",
            "libcycript",
        ]
        
        for library in suspiciousLibraries {
            if dlopen(library, RTLD_LAZY) != nil {
                return true
            }
        }
        
        // Check for suspicious process names
        let processName = ProcessInfo.processInfo.processName.lowercased()
        let suspiciousProcesses = ["debugserver", "frida", "cynject", "cycript"]
        
        for process in suspiciousProcesses {
            if processName.contains(process) {
                return true
            }
        }
        
        // Check for dynamic linker manipulation
        var count: UInt32 = 0
        guard let imageNames = objc_copyImageNames(&count) else {
            return false
        }
        
        for i in 0..<Int(count) {
            guard let imageName = imageNames[i] else { continue }
            let name = String(cString: imageName)
            for suspicious in suspiciousLibraries {
                if name.contains(suspicious) {
                    return true
                }
            }
        }
        
        return false
    }
}
