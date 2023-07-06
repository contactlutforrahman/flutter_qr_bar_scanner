import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/scanner_frame_painter.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:flutter_qr_bar_scanner/flutter_qr_bar_scanner.dart';

final WidgetBuilder _defaultNotStartedBuilder =
    (context) => Text("Camera Loading ...");
final WidgetBuilder _defaultOffscreenBuilder =
    (context) => Text("Camera Paused.");
final ErrorCallback _defaultOnError = (BuildContext context, Object? error) {
  print("Error reading from camera: $error");
  return Text("Error reading from camera...");
};

typedef Widget ErrorCallback(BuildContext context, Object? error);

class QRBarScannerCamera extends StatefulWidget {
  QRBarScannerCamera({
    Key? key,
    required this.qrCodeCallback,
    this.child,
    this.fit = BoxFit.cover,
    WidgetBuilder? notStartedBuilder,
    WidgetBuilder? offscreenBuilder,
    ErrorCallback? onError,
    this.formats,this.frameSize,this.cornerLength,this.cornerWeight,this.frameColor
  })  : notStartedBuilder = notStartedBuilder ?? _defaultNotStartedBuilder,
        offscreenBuilder =
            offscreenBuilder ?? notStartedBuilder ?? _defaultOffscreenBuilder,
        onError = onError ?? _defaultOnError,
        super(key: key);

  final BoxFit fit;
  final ValueChanged<String?> qrCodeCallback;
  final Widget? child;
  final WidgetBuilder notStartedBuilder;
  final WidgetBuilder offscreenBuilder;
  final ErrorCallback onError;
  final List<BarcodeFormats>? formats;
  final double? frameSize;
  final double? cornerLength;
  final double? cornerWeight;
  final Color? frameColor;

  @override
  QRBarScannerCameraState createState() => QRBarScannerCameraState();
}

class QRBarScannerCameraState extends State<QRBarScannerCamera>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => onScreen = true);
    } else {
      if (_asyncInitOnce != null && onScreen) {
        FlutterQrReader.stop();
      }
      setState(() {
        onScreen = false;
        _asyncInitOnce = null;
      });
    }
  }

  bool onScreen = true;
  Future<PreviewDetails>? _asyncInitOnce;

  Future<PreviewDetails> _asyncInit(num width, num height) async {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return await FlutterQrReader.start(
      width: (devicePixelRatio * width.toInt()).ceil(),
      height: (devicePixelRatio * height.toInt()).ceil(),
      qrCodeHandler: widget.qrCodeCallback,
      formats: widget.formats,
    );
  }

  /// This method can be used to restart scanning
  ///  the event that it was paused.
  void restart() {
    (() async {
      await FlutterQrReader.stop();
      setState(() {
        _asyncInitOnce = null;
      });
    })();
  }

  /// This method can be used to manually stop the
  /// camera.
  void stop() {
    (() async {
      await FlutterQrReader.stop();
    })();
  }

  @override
  deactivate() {
    super.deactivate();
    FlutterQrReader.stop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (_asyncInitOnce == null && onScreen) {
        _asyncInitOnce =
            _asyncInit(constraints.maxWidth, constraints.maxHeight);
      } else if (!onScreen) {
        return widget.offscreenBuilder(context);
      }

      return FutureBuilder(
        future: _asyncInitOnce,
        builder: (BuildContext context, AsyncSnapshot<PreviewDetails> details) {
          switch (details.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return widget.notStartedBuilder(context);
            case ConnectionState.done:
              if (details.hasError) {
                debugPrint(details.error.toString());
                return widget.onError(context, details.error);
              }
              Widget preview = SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Preview(
                  previewDetails: details.data!,
                  targetWidth: constraints.maxWidth,
                  targetHeight: constraints.maxHeight,
                  fit: widget.fit,
                  frameSize: widget.frameSize,
                  frameColor: widget.frameColor,
                  cornerLength: widget.cornerLength,
                  cornerWeight: widget.cornerWeight,
                ),
              );

              if (widget.child != null) {
                return Stack(
                  children: [
                    preview,
                    widget.child!,
                  ],
                );
              }
              return preview;

            default:
              throw AssertionError("${details.connectionState} not supported.");
          }
        },
      );
    });
  }
}

class Preview extends StatelessWidget {
  final double width, height;
  final double targetWidth, targetHeight;
  final int? textureId;
  final int? sensorOrientation;
  final BoxFit fit;
  final double? frameSize;
  final double? cornerLength;
  final double? cornerWeight;
  final Color? frameColor;

  Preview(
      {required PreviewDetails previewDetails,
      required this.targetWidth,
      required this.targetHeight,
      required this.fit,
      this.frameSize,
      this.cornerLength,
      this.cornerWeight,
      this.frameColor})
      : textureId = previewDetails.textureId,
        width = previewDetails.width!.toDouble(),
        height = previewDetails.height!.toDouble(),
        sensorOrientation = previewDetails.sensorOrientation as int?;

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      builder: (context) {
        var nativeOrientation =
            NativeDeviceOrientationReader.orientation(context);

        int nativeRotation = 0;
        switch (nativeOrientation) {
          case NativeDeviceOrientation.portraitUp:
            nativeRotation = 0;
            break;
          case NativeDeviceOrientation.landscapeRight:
            nativeRotation = 90;
            break;
          case NativeDeviceOrientation.portraitDown:
            nativeRotation = 180;
            break;
          case NativeDeviceOrientation.landscapeLeft:
            nativeRotation = 270;
            break;
          case NativeDeviceOrientation.unknown:
          default:
            break;
        }

        int rotationCompensation =
            ((nativeRotation - sensorOrientation! + 450) % 360) ~/ 90;

        double frameHeight = width;
        double frameWidth = height;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: fit,
                child: RotatedBox(
                  quarterTurns: rotationCompensation,
                  child: SizedBox(
                    width: frameWidth,
                    height: frameHeight,
                    child: Texture(textureId: textureId!),
                  ),
                ),
              ),
              CustomPaint(
                painter: ScannerFramePainter(
                    size: frameSize ?? 240,
                    cornerLength: cornerLength ?? 20,
                    cornerWeight: cornerWeight ?? 4,
                    frameColor: frameColor ?? Colors.blue),
                child: Container(),
              )
            ],
          ),
        );
      },
    );
  }
}
