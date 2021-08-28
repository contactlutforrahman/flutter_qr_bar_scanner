import 'dart:async';

import 'package:flutter/services.dart';

class PreviewDetails {
  num? height;
  num? width;
  num? orientation;
  int? textureId;

  PreviewDetails(this.height, this.width, this.orientation, this.textureId);
}

// all qr/barcode formats
enum BarcodeFormats {
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
  UPC_E,
}

const _defaultBarcodeFormats = const [
  BarcodeFormats.ALL_FORMATS,
];

// the class which is handling the native call.
// it's handling the native mobile vision api call
class FlutterQrReader {
  // flutter method channel for native plugin
  static const MethodChannel _channel = const MethodChannel(
      'com.github.contactlutforrahman/flutter_qr_bar_scanner');
  static QrChannelReader channelReader = new QrChannelReader(_channel);

  //Set target size before starting
  static Future<PreviewDetails> start({
    // qr/barcode scanning preview height
    required int height,
    // qr/barcode scanning preview width
    required int width,
    // qr/barcode handler to handle the scanned qr code
    required QRCodeHandler qrCodeHandler,
    // default qr/barcode formats
    List<BarcodeFormats>? formats = _defaultBarcodeFormats,
  }) async {
    final _formats = formats ?? _defaultBarcodeFormats;
    assert(_formats.length > 0);

    List<String> formatStrings = _formats
        .map((format) => format.toString().split('.')[1])
        .toList(growable: false);

    channelReader.setQrCodeHandler(qrCodeHandler);
    var details = await _channel.invokeMethod('start', {
      'targetHeight': height,
      'targetWidth': width,
      'heartbeatTimeout': 0,
      'formats': formatStrings
    });

    // invokeMethod returns Map<dynamic,...> in dart 2.0
    assert(details is Map<dynamic, dynamic>);

    int? textureId = details["textureId"];
    num? orientation = details["surfaceOrientation"];
    num? surfaceHeight = details["surfaceHeight"];
    num? surfaceWidth = details["surfaceWidth"];

    return new PreviewDetails(
        surfaceHeight, surfaceWidth, orientation, textureId);
  }

  // calls the stop method of native api to stop the camera
  static Future stop() {
    channelReader.setQrCodeHandler(null);
    return _channel.invokeMethod('stop').catchError(print);
  }

  static Future heartbeat() {
    return _channel.invokeMethod('heartbeat').catchError(print);
  }

  // calls the native api to get supported sizes
  static Future<List<List<int>>?> getSupportedSizes() {
    return _channel
        .invokeMethod('getSupportedSizes')
        .catchError(print)
        .then((value) => value as List<List<int>>?);
  }
}

enum FrameRotation { none, ninetyCC, oneeighty, twoseventyCC }

typedef void QRCodeHandler(String? qr);

// native channel reader

class QrChannelReader {
  QrChannelReader(this.channel) {
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'qrRead':
          if (qrCodeHandler != null) {
            assert(call.arguments is String);
            qrCodeHandler!(call.arguments);
          }
          break;
        default:
          print("QrChannelHandler: unknown method call received at "
              "${call.method}");
      }
    });
  }

  void setQrCodeHandler(QRCodeHandler? qrch) {
    this.qrCodeHandler = qrch;
  }

  MethodChannel channel;
  // qr code handler
  QRCodeHandler? qrCodeHandler;
}
