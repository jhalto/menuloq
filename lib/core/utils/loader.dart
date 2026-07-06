import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

class Loader extends StatefulWidget {
  const Loader({
    super.key,
    this.size = 56,
    this.dotSize = 10,
    this.duration = const Duration(milliseconds: 750),
  });

  final double size;
  final double dotSize;
  final Duration duration;

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  final List<Color> _colors = const [
    AppColors.accent,
    AppColors.primary,
    Color(0xFFFFB020),
    Color.fromARGB(255, 10, 70, 180),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size * 0.32;
    final center = widget.size / 2;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi * 2;

          return Stack(
            children: List.generate(4, (index) {
              final dotAngle = angle + (index * math.pi / 2);
              final pulse =
                  0.78 + (math.sin(angle + index * math.pi / 2) + 1) * 0.18;

              final x = center + math.cos(dotAngle) * radius;
              final y = center + math.sin(dotAngle) * radius;

              return Positioned(
                left: x - widget.dotSize / 2,
                top: y - widget.dotSize / 2,
                child: Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _colors[index],
                      boxShadow: [
                        BoxShadow(
                          color: _colors[index].withAlpha(95),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}