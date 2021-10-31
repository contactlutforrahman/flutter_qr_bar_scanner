#import "FlutterQrBarScannerPlugin.h"
#if __has_include(<flutter_qr_bar_scanner/flutter_qr_bar_scanner-Swift.h>)
#import <flutter_qr_bar_scanner/flutter_qr_bar_scanner-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_qr_bar_scanner-Swift.h"
#endif

@implementation FlutterQrBarScannerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQrBarScannerPlugin registerWithRegistrar:registrar];
}
@end