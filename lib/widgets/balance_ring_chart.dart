import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/balance_segment.dart';
import '../theme/app_theme.dart';

class BalanceRingChart extends StatelessWidget {
  const BalanceRingChart({
    super.key,
    required this.segments,
    required this.centerLabel,
    required this.centerValue,
    this.size = 180,
  });

  final List<BalanceSegment> segments;
  final String centerLabel;
  final String centerValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              segments: segments,
              backgroundColor: isDark
                  ? AppColors.darkProgressBg
                  : AppColors.lightProgressBg,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerValue,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mint,
                    ),
                  ),
                  Text(
                    centerLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: segments
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LegendItem(segment: s, isDark: isDark),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.segment, required this.isDark});

  final BalanceSegment segment;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                segment.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                segment.detail,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${segment.percent.toStringAsFixed(0)}%',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: segment.color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.segments,
    required this.backgroundColor,
  });

  final List<BalanceSegment> segments;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const stroke = 18.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final total = segments.fold<double>(0, (sum, s) => sum + s.percent);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    const gap = 0.04;

    for (final segment in segments) {
      final sweep = (segment.percent / total) * 2 * math.pi - gap;
      if (sweep <= 0) continue;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
