import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final int value;
  final double width;
  final double height;
  final Color accentColor;
  final double fontSize;

  const FlipCard({
    super.key,
    required this.value,
    this.width = 85,
    this.height = 100,
    this.accentColor = const Color(0xFF6C63FF),
    this.fontSize = 52,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _oldValue = 0;
  int _lastWidgetValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _lastWidgetValue = widget.value;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detect value change and trigger animation
    if (widget.value != _lastWidgetValue) {
      setState(() {
        _oldValue = _lastWidgetValue;
        _lastWidgetValue = widget.value;
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(int val) => val.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final radius = widget.width * 0.1;
    final halfHeight = widget.height / 2;
    final currentText = _format(_lastWidgetValue);
    final oldText = _format(_oldValue);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final animProgress = _controller.value;

          // Determine which values to show based on animation progress
          // Show old value until animation passes halfway point
          final topDisplayText = animProgress <= 0.5 ? oldText : currentText;
          final bottomDisplayText = animProgress <= 0.5 ? oldText : currentText;

          return Stack(
            children: [
              // Static top panel - shows old until flip completes first half
              _buildPanel(topDisplayText, true, radius, halfHeight),
              // Static bottom panel - shows old until flip completes second half
              _buildPanel(bottomDisplayText, false, radius, halfHeight),

              // FRONT TOP: Old value flipping down (first half of animation)
              if (animProgress > 0 && animProgress <= 0.5)
                _buildFlippingPanel(
                  oldText,
                  true,
                  radius,
                  halfHeight,
                  animProgress * 2 * (math.pi / 2),
                ),

              // FRONT BOTTOM: New value flipping up (second half of animation)
              if (animProgress > 0.5)
                _buildFlippingPanel(
                  currentText,
                  false,
                  radius,
                  halfHeight,
                  (1 - animProgress) * 2 * (math.pi / 2),
                ),

              // Center line
              Positioned(
                top: halfHeight - 1,
                left: 0,
                right: 0,
                child: Container(height: 2, color: const Color(0xFF0A0A15)),
              ),
              // Left notch
              Positioned(
                left: 0,
                top: halfHeight - 3,
                child: Container(
                  width: 4,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A0A15),
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(3)),
                  ),
                ),
              ),
              // Right notch
              Positioned(
                right: 0,
                top: halfHeight - 3,
                child: Container(
                  width: 4,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A0A15),
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(3)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPanel(
      String text, bool isTop, double radius, double halfHeight) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      height: halfHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: isTop ? Radius.circular(radius) : Radius.zero,
          bottom: isTop ? Radius.zero : Radius.circular(radius),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isTop
                  ? [const Color(0xFF2A2A40), const Color(0xFF232335)]
                  : [const Color(0xFF232335), const Color(0xFF1C1C2A)],
            ),
          ),
          child: _buildText(text, isTop, halfHeight),
        ),
      ),
    );
  }

  Widget _buildFlippingPanel(
      String text, bool isTop, double radius, double halfHeight, double angle) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      height: halfHeight,
      child: Transform(
        alignment: isTop ? Alignment.bottomCenter : Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(isTop ? angle : -angle),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: isTop ? Radius.circular(radius) : Radius.zero,
            bottom: isTop ? Radius.zero : Radius.circular(radius),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isTop
                    ? [const Color(0xFF2A2A40), const Color(0xFF232335)]
                    : [const Color(0xFF232335), const Color(0xFF1C1C2A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, isTop ? 4 : -4),
                ),
              ],
            ),
            child: _buildText(text, isTop, halfHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildText(String text, bool isTop, double halfHeight) {
    return ClipRect(
      child: OverflowBox(
        maxHeight: widget.height,
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: SizedBox(
          height: widget.height,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: widget.accentColor.withOpacity(0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
