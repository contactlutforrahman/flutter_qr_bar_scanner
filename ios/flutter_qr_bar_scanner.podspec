Pod::Spec.new do |s|
  s.name             = 'flutter_qr_bar_scanner'
  s.version          = '2.0.0'
  s.summary          = "A Plugin for reading/scanning QR & Bar codes using Google's Mobile Vision API"
  s.description      = <<-DESC
A Plugin for reading/scanning QR & Bar codes using Google's Mobile Vision API.
                       DESC
  s.homepage         = 'https://github.com/contactlutforrahman/flutter_qr_bar_scanner'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Lutfor Rahman' => 'contact.lutforrahman@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'

  s.dependency 'GoogleMobileVision/BarcodeDetector'

  s.static_framework = true
end
