import 'package:flutter/material.dart';

class ScannerFramePainter extends CustomPainter{
  final double size; //框的大小
  final double cornerLength; //边框角线条长度
  final double cornerWeight; //边框角线条的粗细
  final Color frameColor; //边框线的颜色

  ScannerFramePainter({ this.size = 240,this.cornerLength = 20,this.cornerWeight = 4.0,this.frameColor = Colors.blue });

  @override
  void paint(Canvas canvas, Size size) {
    final offsetX = (size.width - this.size) / 2; //边框起始x坐标
    final offsetY = (size.height - this.size) / 2; //边框起始y坐标

    Paint paint = Paint()
      ..color = Color(0x40cccccc)
      ..style = PaintingStyle.fill;

    //画遮罩层
    canvas.drawRect(Rect.fromLTRB(0, 0, offsetX, size.height), paint);
    canvas.drawRect(Rect.fromLTRB(offsetX + this.size, 0, size.width, size.height), paint);
    canvas.drawRect(Rect.fromLTRB(offsetX, 0, offsetX + this.size, offsetY), paint);
    canvas.drawRect(Rect.fromLTRB(offsetX, offsetY + this.size, offsetX + this.size, size.height), paint);

    paint
      ..color = frameColor
      ..strokeWidth = cornerWeight
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    //画左上角
    canvas.drawLine(Offset(offsetX, offsetY), Offset(offsetX + cornerLength, offsetY), paint);
    canvas.drawLine(Offset(offsetX, offsetY), Offset(offsetX, offsetY + cornerLength), paint);

    canvas.drawLine(Offset(offsetX, offsetY + this.size), Offset(offsetX + cornerLength, offsetY + this.size), paint);
    canvas.drawLine(Offset(offsetX, offsetY + this.size), Offset(offsetX, offsetY + this.size - cornerLength), paint);

    canvas.drawLine(Offset(offsetX + this.size, offsetY), Offset(offsetX + this.size - cornerLength, offsetY), paint);
    canvas.drawLine(Offset(offsetX + this.size, offsetY), Offset(offsetX + this.size, offsetY + cornerLength), paint);

    //画右下角
    canvas.drawLine(Offset(offsetX + this.size, offsetY + this.size), Offset(offsetX + this.size - cornerLength, offsetY + this.size), paint);
    canvas.drawLine(Offset(offsetX + this.size, offsetY + this.size), Offset(offsetX + this.size, offsetY + this.size - cornerLength), paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}