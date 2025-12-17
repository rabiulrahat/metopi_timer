import 'package:flutter/material.dart';
import 'flip_card.dart';

class FlipClock extends StatefulWidget {
  final int hours;
  final int minutes;
  final int seconds;
  final Color accentColor;
  final bool isRunning;
  final bool isFullScreen;
  final bool isLandscape;

  const FlipClock({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.accentColor = const Color(0xFF6C63FF),
    this.isRunning = false,
    this.isFullScreen = false,
    this.isLandscape = false,
  });

  @override
  State<FlipClock> createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final effectiveLandscape = widget.isLandscape || size.width > size.height;

    // Responsive sizing
    double cardWidth;
    double cardHeight;
    double fontSize;
    double separatorSize;
    double labelSize;

    if (widget.isFullScreen) {
      if (effectiveLandscape) {
        cardWidth = size.width * 0.14;
        cardHeight = size.height * 0.35;
        fontSize = cardHeight * 0.55; // Font size relative to card height
        separatorSize = size.width * 0.012;
        labelSize = size.height * 0.03;
      } else {
        cardWidth = size.width * 0.24;
        cardHeight = size.height * 0.15;
        fontSize = cardHeight * 0.55;
        separatorSize = size.width * 0.018;
        labelSize = size.height * 0.016;
      }
    } else {
      if (effectiveLandscape) {
        // Compact sizing for landscape normal view
        cardWidth = size.height * 0.16;
        cardHeight = size.height * 0.2;
        fontSize = cardHeight * 0.55;
        separatorSize = size.height * 0.018;
        labelSize = size.height * 0.02;
      } else {
        cardWidth = size.width * 0.22;
        cardHeight = size.height * 0.12;
        fontSize = cardHeight * 0.55;
        separatorSize = size.width * 0.015;
        labelSize = size.height * 0.012;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFlipUnit(
            widget.hours, 'HRS', cardWidth, cardHeight, fontSize, labelSize),
        _buildSeparator(separatorSize, cardHeight),
        _buildFlipUnit(
            widget.minutes, 'MIN', cardWidth, cardHeight, fontSize, labelSize),
        _buildSeparator(separatorSize, cardHeight),
        _buildFlipUnit(
            widget.seconds, 'SEC', cardWidth, cardHeight, fontSize, labelSize),
      ],
    );
  }

  Widget _buildFlipUnit(int value, String label, double width, double height,
      double fontSize, double labelSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlipCard(
          key: ValueKey(label),
          value: value,
          width: width,
          height: height,
          fontSize: fontSize,
          accentColor: widget.accentColor,
        ),
        SizedBox(height: height * 0.1),
        Text(
          label,
          style: TextStyle(
            color: Colors.white38,
            fontSize: labelSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(double size, double cardHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: widget.isRunning
                  ? widget.accentColor
                  : const Color(0xFF2A2A3E),
              shape: BoxShape.circle,
              boxShadow: widget.isRunning
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: size * 1.5),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: widget.isRunning
                  ? widget.accentColor
                  : const Color(0xFF2A2A3E),
              shape: BoxShape.circle,
              boxShadow: widget.isRunning
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: cardHeight * 0.65),
        ],
      ),
    );
  }
}
