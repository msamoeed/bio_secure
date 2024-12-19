Pod::Spec.new do |s|
  s.name             = 'bio_secure'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for secure biometric storage using iOS Secure Enclave'
  s.description      = <<-DESC
A Flutter plugin that provides secure data storage using iOS Secure Enclave and biometric authentication, with anti-tampering and jailbreak detection.
                       DESC
  s.homepage         = 'https://github.com/msamoeed/bio_secure'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'msamoeed@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  
  s.ios.deployment_target = '11.0'
  
  # Dependencies
  s.dependency 'Flutter'
  
  # Swift version
  s.swift_version = '5.0'
  
  # Project settings
  s.platform = :ios, '11.0'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    'ENABLE_BITCODE' => 'NO',
    'SWIFT_OPTIMIZATION_LEVEL' => '-O',
    'OTHER_LDFLAGS' => '$(inherited) -framework Security -framework LocalAuthentication'
  }
  
  # Compiler flags
  s.compiler_flags = '-fmodules -fcxx-modules'
  
  # Required frameworks
  s.frameworks = 'Security', 'LocalAuthentication'
  
  # Ensure the plugin is built as a framework
  s.static_framework = true
end