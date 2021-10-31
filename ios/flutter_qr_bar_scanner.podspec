Pod::Spec.new do |s|
  s.name             = 'flutter_qr_bar_scanner'
  s.version          = '3.0.1'
  s.summary          = "A Plugin for reading/scanning QR & Bar codes using Firebase's Mobile Vision API."
  s.description      = <<-DESC
  A Plugin for reading/scanning QR & Bar codes using Firebase's Mobile Vision API.
                       DESC
  s.homepage         = 'https://github.com/contactlutforrahman/flutter_qr_bar_scanner'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Lutfor Rahman' => 'contact.lutforrahman@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  # Mobile vision doesn't support 32 bit ios
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphoneos*]' => 'arm64' }
  s.swift_version = '5.0'

  s.dependency 'GoogleMLKit/BarcodeScanning'
  
  s.static_framework = true
end
