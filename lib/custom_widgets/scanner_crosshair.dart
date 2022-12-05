import 'dart:math';

import 'package:flutter/material.dart';

//Adapted from: https://stackoverflow.com/a/73758436/8109619

class ViewfinderPainter extends CustomPainter {
  final double rectWidth;
  final double radius;
  final double strokeWidth;
  final double length;

  ViewfinderPainter({
    this.rectWidth = 300,
    this.radius = 20,
    this.strokeWidth = 2,
    this.length = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect canvasRect = Offset.zero & size;
    final Rect rect = Rect.fromCircle(
      center: canvasRect.center,
      radius: rectWidth / 2,
    );
    double extend = radius + length;
    Size arcSize = Size.square(radius * 2);

    canvas.drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRRect(
            RRect.fromRectAndRadius(
              rect,
              Radius.circular(radius),
            ).deflate(strokeWidth / 2),
          )
          ..addRect(canvasRect),
        Paint()..color = Colors.transparent);

    canvas.save();
    canvas.translate(rect.left, rect.top);
    final Path path = Path();
    for (var i = 0; i < 4; i++) {
      final bool l = i & 1 == 0;
      final bool t = i & 2 == 0;
      path
        ..moveTo(l ? 0 : rectWidth, t ? extend : rectWidth - extend)
        ..arcTo(
            Offset(l ? 0 : rectWidth - arcSize.width,
                    t ? 0 : rectWidth - arcSize.width) &
                arcSize,
            l ? pi : pi * 2,
            l == t ? pi / 2 : -pi / 2,
            false)
        ..lineTo(l ? extend : rectWidth - extend, t ? 0 : rectWidth);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ViewfinderPainter oldDelegate) => false;
}
