import 'dart:math';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class VisitsRing extends StatelessWidget {
  final int visitsUsed;
  final int maxVisits;
  final double size;

  const VisitsRing({
    super.key,
    required this.visitsUsed,
    this.maxVisits = 30,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = maxVisits - visitsUsed;
    final progress = visitsUsed / maxVisits;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$remaining',
                style: TextStyle(
                  color: AppColors.neonPrimary,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'visits left',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: size * 0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.bgElevated
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * (1 - progress),
      false,
      Paint()
        ..color = AppColors.neonPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
