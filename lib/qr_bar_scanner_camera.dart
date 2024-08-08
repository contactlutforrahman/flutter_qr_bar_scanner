import 'dart:async';

import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'flutter_qr_bar_scanner.dart';

Widget _defaultNotStartedBuilder(BuildContext context) {
  return const Text('Camera Loading ...');
}

Widget _defaultOffscreenBuilder(BuildContext context) {
  return const Text('Camera Paused.');
}

Widget _defaultOnError(BuildContext context, Object? error) {
  debugPrint('Error reading from camera: $error');
  return const Text('Error reading from camera...');
}

typedef ErrorCallback = Widget Function(BuildContext context, Object? error);

class QRBarScannerCamera extends StatefulWidget {
  const QRBarScannerCamera({
    required this.qrCodeCallback,
    this.child,
    this.fit = BoxFit.cover,
    this.formats,
    super.key,
    WidgetBuilder? notStartedBuilder,
    WidgetBuilder? offscreenBuilder,
    ErrorCallback? onError,
  })  : notStartedBuilder = notStartedBuilder ?? _defaultNotStartedBuilder,
        offscreenBuilder =
            offscreenBuilder ?? notStartedBuilder ?? _defaultOffscreenBuilder,
        onError = onError ?? _defaultOnError;

  final BoxFit fit;
  final ValueChanged<String?> qrCodeCallback;
  final Widget? child;
  final WidgetBuilder notStartedBuilder;
  final WidgetBuilder offscreenBuilder;
  final ErrorCallback onError;
  final List<BarcodeFormats>? formats;

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
  void dispose() {
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
    return FlutterQrReader.start(
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
  void deactivate() {
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
          builder:
              (BuildContext context, AsyncSnapshot<PreviewDetails> details) {
            switch (details.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return widget.notStartedBuilder(context);
              case ConnectionState.done:
                if (details.hasError) {
                  debugPrint(details.error.toString());
                  return widget.onError(context, details.error);
                }
                final preview = SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Preview(
                    previewDetails: details.data!,
                    targetWidth: constraints.maxWidth,
                    targetHeight: constraints.maxHeight,
                    fit: widget.fit,
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

              case ConnectionState.active:
                throw AssertionError(
                  '${details.connectionState} not supported.',
                );
            }
          },
        );
      },
    );
  }
}

class Preview extends StatelessWidget {
  Preview({
    required PreviewDetails previewDetails,
    required this.targetWidth,
    required this.targetHeight,
    required this.fit,
    super.key,
  })  : textureId = previewDetails.textureId,
        width = previewDetails.width!.toDouble(),
        height = previewDetails.height!.toDouble(),
        sensorOrientation = previewDetails.sensorOrientation as int?;

  final double width;
  final double height;
  final double targetWidth;
  final double targetHeight;
  final int? textureId;
  final int? sensorOrientation;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      builder: (context) {
        final nativeOrientation =
            NativeDeviceOrientationReader.orientation(context);

        var nativeRotation = 0;
        switch (nativeOrientation) {
          case NativeDeviceOrientation.portraitUp:
            nativeRotation = 0;
          case NativeDeviceOrientation.landscapeRight:
            nativeRotation = 90;
          case NativeDeviceOrientation.portraitDown:
            nativeRotation = 180;
          case NativeDeviceOrientation.landscapeLeft:
            nativeRotation = 270;
          case NativeDeviceOrientation.unknown:
        }

        final rotationCompensation =
            ((nativeRotation - sensorOrientation! + 450) % 360) ~/ 90;

        final frameHeight = width;
        final frameWidth = height;

        return ClipRect(
          child: FittedBox(
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
        );
      },
    );
  }
}
