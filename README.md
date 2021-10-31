# Flutter QR Bar Scanner

![pub package][version_badge]

 A Full Screen Scanner for Scanning QR code and Barcode using Google's Mobile Vision API

 Reading & Scanning QR/Bar codes using Firebase's MLKit.

 This plugin uses Android & iOS native APIs for reading images from the device's camera.
 It then pipes these images both to the MLKit Vision Barcode API which detects qr/bar codes etc,
 and outputs a preview image to be shown on a flutter texture.

 The plugin includes a widget which performs all needed transformations on the camera
 output to show within the defined area.

## Android Models

 With this new version of MLKit, there are two separate models you can use to do the barcode scanning. Currently, this
 apk chooses to use the build-in model.  This will increase your code size by ~2.2MB but will
 result in better scanning and won't require a separate package to be downloaded in the background for barcode scanning
 to work properly.

 You could also use the Google Play Services and tell your app to download it on install from the play store. See the
 instruction on the [ml-kit barcode-scanning documentation page](https://developers.google.com/ml-kit/vision/barcode-scanning/android)
 for android. You would also have to remove the com.google.mlkit:barcode-scanning dependency;

```
configurations.all {
    exclude group: "com.google.mlkit", module:"barcode-scanning"
}
//  ...
dependencies {
  // ...
  // Use this dependency to use the dynamically downloaded model in Google Play Services
  implementation 'com.google.android.gms:play-services-mlkit-barcode-scanning:16.1.4'
}
```

Note that if you do this, you should tell your app to automatically download the model as in the above linked docs.MLKit
```
<application ...>
    ...
    <meta-data
        android:name="com.google.mlkit.vision.DEPENDENCIES"
        android:value="barcode" />
    <!-- To use multiple models: android:value="barcode,model2,model3" -->
</application>
```

If this doesn't work for you please open an issue.

## 64 Bit Only on iOS

The plugin is only supported for only 64 Bit on iOS as Google has only released  MLKit as a 64 bit binary. 

When you upgrade, if you are targeting a version of iOS before 11, you'll see a warning during the `pod install`
and your app probably won't build (at least for release). That's because it'll be trying to build the 32-bit version and
won't find the required files.

The easy way to solve this is by updating to build for iOS 11 and later. To do this:

1) Add this line to your Podfile:
```
platform :ios, '11.0'
```

2) (optional) Make sure your podfile sets build versions to 11 - if you see this at the bottom of your podfile make sure
 the line setting the deployment target to 11 is in there.
```
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
    end
end
```

3) Setting the `iOS Deployment Target` to 11 in XCode -> Runner -> Build Settings -> Deployment -> iOS Deployment Target.

## Building for 64-bit before 11.0.

If you absolutely need to build for devices before 11.0, you might need to use an old version of the library that supports
32-bit. If you're willing to live without 32 bit but do need to target before 11.0, you can do that by ignoring the warning
CocoaPods will give you, and setting XCode -> Runner -> Build Settings -> Architectures -> Architectures to `${ARCHS_STANDARD_64_BIT}`.

## Usage

See the example for how to use this plugin; it is the best resource available as it shows
the plugin in use. However, these are the steps you need to take to
use this plugin.

First, figure out the area that you want the camera preview to be shown in. This is important
as the preview __needs__ to have a constrained size or it won't be able to build. This
is required due to the complex nature of the transforms needed to get the camera preview to
show correctly on both iOS and Android, while still working with the screen rotated etc.

It may be possible to get the camera preview to work without putting it in a SizedBox or Container,
but the recommended way is to put it in a SizedBox or Container.

You then need to include the package and instantiate the camera.


```
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR/Bar Code Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter QR/Bar Code Reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _qrInfo = 'Scan a QR/Bar code';
  bool _camState = false;

  _qrCallback(String? code) {
    setState(() {
      _camState = false;
      _qrInfo = code;
    });
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: _camState
          ? Center(
              child: SizedBox(
                height: 1000,
                width: 500,
                child: QRBarScannerCamera(
                  onError: (context, error) => Text(
                    error.toString(),
                    style: TextStyle(color: Colors.red),
                  ),
                  qrCodeCallback: (code) {
                    _qrCallback(code);
                  },
                ),
              ),
            )
          : Center(
              child: Text(_qrInfo!),
            ),
    );
  }
}


```

The QrCodeCallback can do anything you'd like, and wil keep receiving QR/Bar codes
until the camera is stopped.

There are also optional parameters to QRScannerCamera.

### `fit`

Takes as parameter the flutter `BoxFit`.
Setting this to different values should get the preview image to fit in
different ways, but only `BoxFit = cover` has been tested extensively.

### `notStartedBuilder`

A callback that must return a widget if defined.
This should build whatever you want to show up while the camera is loading (which can take
from milliseconds to seconds depending on the device).

### `child`

Widget that is shown on top of the QRScannerCamera. If you give it a specific size it may cause
weird issues so try not to.

### `key`

Standard flutter key argument. Can be used to get QRScannerCameraState with a GlobalKey.

### `offscreenBuilder`

A callback that must return a widget if defined.
This should build whatever you want to show up when the camera view is 'offscreen'.
i.e. when the app is paused. May or may not show up in preview of app.

### `onError`

Callback for if there's an error.

### 'formats'

A list of supported formats, all by default. If you use all, you shouldn't define any others.

These are the supported types:

```
  ALL_FORMATS,
  AZTEC,
  CODE_128,
  CODE_39,
  CODE_93,
  CODABAR,
  DATA_MATRIX,
  EAN_13,
  EAN_8,
  ITF,
  PDF417,
  QR_CODE,
  UPC_A,
  UPC_E
```

## Push and Pop

If you push a new widget on top of a the current page using the navigator, the camera doesn't
necessarily know about it.

## Contributions

Any kind of contribution will be appreciated.
 
[version_badge]: https://img.shields.io/pub/v/flutter_qr_bar_scanner.svg


## License
[MIT License](https://github.com/contactlutforrahman/flutter_qr_bar_scanner/blob/master/LICENSE)


## Inspire me
[Be a Patreon](https://www.patreon.com/join/_lutfor?)