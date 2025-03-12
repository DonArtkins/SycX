import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaddedRoundSliderValueIndicatorShape extends SliderComponentShape {
  final EdgeInsets padding;
  final double verticalOffset;

  const PaddedRoundSliderValueIndicatorShape({
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.verticalOffset = -48.0, // Adjust this value to move the shape up
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(padding.horizontal + 32, padding.vertical + 32);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final ColorTween enableColor = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.valueIndicatorColor,
    );
    final Paint paint = Paint()
      ..color = enableColor.evaluate(enableAnimation)!
      ..style = PaintingStyle.fill;

    // Apply vertical offset to move the shape up
    final Offset adjustedCenter = center.translate(0, verticalOffset);

    final TextSpan span = TextSpan(
      style: sliderTheme.valueIndicatorTextStyle,
      text: labelPainter.text!.toPlainText(),
    );
    final TextPainter textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: textDirection,
      textScaleFactor:
          textScaleFactor, // Keep using textScaleFactor for compatibility
    );
    textPainter.layout();

    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;
    final double bubbleWidth = math.max(textWidth + padding.horizontal, 32.0);
    final double bubbleHeight = math.max(textHeight + padding.vertical, 32.0);
    final Rect bubbleRect = Rect.fromCenter(
      center: adjustedCenter,
      width: bubbleWidth,
      height: bubbleHeight,
    );
    final double cornerRadius = bubbleHeight / 2;
    final Radius radius = Radius.circular(cornerRadius);
    final RRect bubbleRRect = RRect.fromRectAndRadius(bubbleRect, radius);

    // Draw shadow
    canvas.drawShadow(
      Path()..addRRect(bubbleRRect),
      Colors.black.withOpacity(0.25),
      4.0,
      true,
    );

    // Draw bubble
    canvas.drawRRect(bubbleRRect, paint);

    // Draw text
    textPainter.paint(
      canvas,
      bubbleRect.topLeft +
          Offset(bubbleRect.width / 2 - textWidth / 2,
              bubbleRect.height / 2 - textHeight / 2),
    );

    // Draw arrow pointing down
    const double arrowWidth = 10.0;
    const double arrowHeight = 6.0;
    final Path arrowPath = Path()
      ..moveTo(adjustedCenter.dx - arrowWidth / 2, bubbleRect.bottom)
      ..lineTo(adjustedCenter.dx, bubbleRect.bottom + arrowHeight)
      ..lineTo(adjustedCenter.dx + arrowWidth / 2, bubbleRect.bottom)
      ..close();
    canvas.drawPath(arrowPath, paint);
  }
}
