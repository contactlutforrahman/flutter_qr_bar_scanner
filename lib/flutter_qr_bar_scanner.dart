import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PreviewDetails {
  PreviewDetails(
    this.width,
    this.height,
    this.sensorOrientation,
    this.textureId,
  );

  num? width;
  num? height;
  num? sensorOrientation;
  int? textureId;
}

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

const _defaultBarcodeFormats = [
  BarcodeFormats.ALL_FORMATS,
];

class FlutterQrReader {
  static const MethodChannel _channel =
      MethodChannel('com.github.contactlutforrahman/flutter_qr_bar_scanner');
  static QrChannelReader channelReader = QrChannelReader(_channel);

  //Set target size before starting
  static Future<PreviewDetails> start({
    required int width,
    required int height,
    required QRCodeHandler qrCodeHandler,
    List<BarcodeFormats>? formats = _defaultBarcodeFormats,
  }) async {
    final formats0 = formats ?? _defaultBarcodeFormats;
    assert(formats0.isNotEmpty, 'At least one format must be provided');

    final formatStrings = formats0
        .map((format) => format.toString().split('.')[1])
        .toList(growable: false);

    channelReader.qrCodeHandler = qrCodeHandler;
    final details = await _channel.invokeMethod('start', {
      'targetWidth': width,
      'targetHeight': height,
      'heartbeatTimeout': 0,
      'formats': formatStrings,
    });

    if (details! is Map<String, dynamic>) {
      throw Exception(
        'details is not a Map<String, dynamic>. '
        'Got: $details with type ${details.runtimeType}',
      );
    }

    details as Map<dynamic, dynamic>;
    final textureId = details['textureId'] as int?;
    final orientation = details['surfaceOrientation'] as num?;
    final surfaceHeight = details['surfaceHeight'] as num?;
    final surfaceWidth = details['surfaceWidth'] as num?;

    return PreviewDetails(surfaceWidth, surfaceHeight, orientation, textureId);
  }

  static Future<void> stop() async {
    channelReader.qrCodeHandler = null;
    try {
      return _channel.invokeMethod('stop');
    } catch (e) {
      debugPrint('Error stopping QR reader: $e');
    }
  }
}

enum FrameRotation { none, ninetyCC, oneeighty, twoseventyCC }

typedef QRCodeHandler = void Function(String? qr);

class QrChannelReader {
  QrChannelReader(this.channel) {
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'qrRead':
          if (qrCodeHandler != null) {
            final arguments = call.arguments;
            if (arguments is String?) {
              qrCodeHandler!(arguments);
            }
          }
        default:
          debugPrint(
            'QrChannelHandler: unknown method call received at '
            '${call.method}',
          );
      }
    });
  }

  MethodChannel channel;
  QRCodeHandler? qrCodeHandler;
}
