import 'package:flutter/material.dart';

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;
  final double? cutOutBottomOffset;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
    this.cutOutBottomOffset = 0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderOffset = borderWidth / 2;
    final cutOutSizeActual = cutOutSize;
    final borderLengthActual = borderLength;
    final borderRadiusActual = borderRadius;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cutOutSizeActual / 2 + borderOffset,
      rect.top +
          rect.height / 2 -
          cutOutSizeActual / 2 +
          borderOffset +
          (cutOutBottomOffset ?? 0),
      cutOutSizeActual - borderOffset * 2,
      cutOutSizeActual - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadiusActual),
        ),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    final path = Path();
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLengthActual);
    path.lineTo(cutOutRect.left, cutOutRect.top + borderRadiusActual);
    path.arcToPoint(
      Offset(cutOutRect.left + borderRadiusActual, cutOutRect.top),
      radius: Radius.circular(borderRadiusActual),
    );
    path.lineTo(cutOutRect.left + borderLengthActual, cutOutRect.top);

    path.moveTo(cutOutRect.right - borderLengthActual, cutOutRect.top);
    path.lineTo(cutOutRect.right - borderRadiusActual, cutOutRect.top);
    path.arcToPoint(
      Offset(cutOutRect.right, cutOutRect.top + borderRadiusActual),
      radius: Radius.circular(borderRadiusActual),
    );
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLengthActual);

    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLengthActual);
    path.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadiusActual);
    path.arcToPoint(
      Offset(cutOutRect.right - borderRadiusActual, cutOutRect.bottom),
      radius: Radius.circular(borderRadiusActual),
    );
    path.lineTo(cutOutRect.right - borderLengthActual, cutOutRect.bottom);

    path.moveTo(cutOutRect.left + borderLengthActual, cutOutRect.bottom);
    path.lineTo(cutOutRect.left + borderRadiusActual, cutOutRect.bottom);
    path.arcToPoint(
      Offset(cutOutRect.left, cutOutRect.bottom - borderRadiusActual),
      radius: Radius.circular(borderRadiusActual),
    );
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLengthActual);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
      cutOutBottomOffset: cutOutBottomOffset,
    );
  }
}
