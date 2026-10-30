import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The KoinsMFB chevron-and-dot mark, filled from the bottom in brand green
/// on a 1.6 s loop with a soft pulse of the dot. With [reduceMotion] it draws
/// the static, fully filled mark and runs no ticker.
class BrandLoader extends StatefulWidget {
  const BrandLoader({super.key, this.size = 96, this.reduceMotion = false});

  /// Width of the mark; the height follows the mark's 73:58 proportions.
  final double size;
  final bool reduceMotion;

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(BrandLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.reduceMotion) {
      _controller?.dispose();
      _controller = null;
    } else {
      _controller ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height =
        widget.size * _MarkPainter.markHeight / _MarkPainter.markWidth;
    final controller = _controller;
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: height,
        child: controller == null
            ? CustomPaint(painter: _MarkPainter(progress: 1, pulse: 0))
            : AnimatedBuilder(
                animation: controller,
                builder: (_, __) => CustomPaint(
                  painter: _MarkPainter(
                    progress: Curves.easeInOut.transform(controller.value),
                    pulse: math.sin(controller.value * 2 * math.pi),
                  ),
                ),
              ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.progress, required this.pulse});

  static const markWidth = 73.0;
  static const markHeight = 58.0;
  static const _dotCenter = Offset(54.8, 29);

  /// 0 to 1: how far the fill has risen from the bottom.
  final double progress;

  /// -1 to 1: drives the soft scale of the dot.
  final double pulse;

  // Geometry copied from assets/icons/login_logo.svg (viewBox 73 x 58).
  static Path _chevron() => Path()
    ..moveTo(21.5194, 0.279068)
    ..cubicTo(19.5432, 2.23106, 0, 28.4425, 0, 29.0001)
    ..cubicTo(0, 29.5578, 19.3236, 55.4904, 21.5194, 58)
    ..lineTo(42.819, 58)
    ..cubicTo(42.3801, 56.3268, 21.7388, 30.1154, 21.7388, 29.0001)
    ..lineTo(37.5488, 7.52891)
    ..cubicTo(39.0859, 5.29834, 41.9407, 2.23082, 43.0386, 0)
    ..lineTo(21.5192, 0.279068)
    ..close();

  static Path _dot() => Path()
    ..moveTo(72.8308, 26.4906)
    ..cubicTo(71.3814, 17.2887, 63.1688, 9.48101, 52.3794, 10.8751)
    ..cubicTo(43.0394, 11.9906, 34.9877, 20.6348, 36.598, 31.5099)
    ..cubicTo(37.8864, 40.4329, 46.2599, 48.5194, 57.0493, 47.1251)
    ..cubicTo(66.2282, 45.7307, 74.2801, 37.3656, 72.8308, 26.4906)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / markWidth, size.height / markHeight);

    final dot = _dot();
    final scale = 1 + 0.06 * pulse;
    final pulsedDot = dot.transform(
      (Matrix4.identity()
            ..translate(_dotCenter.dx, _dotCenter.dy)
            ..scale(scale, scale)
            ..translate(-_dotCenter.dx, -_dotCenter.dy))
          .storage,
    );
    final mark = Path.combine(PathOperation.union, _chevron(), pulsedDot);

    if (progress >= 1) {
      canvas.drawPath(mark, Paint()..color = AppColors.brand);
    } else {
      // Faint outline of the whole mark, then the fill rising from the base.
      canvas.drawPath(
        mark,
        Paint()..color = AppColors.brand.withValues(alpha: 0.22),
      );
      canvas.save();
      final top = markHeight * (1 - progress);
      canvas.clipRect(Rect.fromLTRB(0, top, markWidth, markHeight));
      canvas.drawPath(mark, Paint()..color = AppColors.brand);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.progress != progress || old.pulse != pulse;
}
