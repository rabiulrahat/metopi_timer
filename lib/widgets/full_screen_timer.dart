import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'flip_clock.dart';

class FullScreenTimer extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final String taskName;
  final Color accentColor;
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onClose;

  const FullScreenTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.taskName,
    required this.accentColor,
    required this.isRunning,
    required this.isPaused,
    required this.onPlay,
    required this.onPause,
    required this.onReset,
    required this.onClose,
  });

  @override
  State<FullScreenTimer> createState() => _FullScreenTimerState();
}

class _FullScreenTimerState extends State<FullScreenTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Hide status bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Auto-hide controls after 3 seconds
    _startAutoHideTimer();
  }

  void _startAutoHideTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.isRunning) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _breathController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startAutoHideTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    final hours = widget.remainingSeconds ~/ 3600;
    final minutes = (widget.remainingSeconds % 3600) ~/ 60;
    final seconds = widget.remainingSeconds % 60;

    final progress = widget.totalSeconds > 0
        ? widget.remainingSeconds / widget.totalSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: GestureDetector(
        onTap: _toggleControls,
        child: AnimatedBuilder(
          animation: _breathController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2 + (_breathController.value * 0.1),
                  colors: [
                    widget.accentColor
                        .withOpacity(0.15 + (_breathController.value * 0.05)),
                    const Color(0xFF0D0D1A),
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Main timer display
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Task name
                          AnimatedOpacity(
                            opacity: _showControls ? 1.0 : 0.5,
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              widget.taskName.toUpperCase(),
                              style: TextStyle(
                                color: widget.accentColor,
                                fontSize: isLandscape
                                    ? size.height * 0.06
                                    : size.width * 0.05,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isLandscape
                                  ? size.height * 0.02
                                  : size.height * 0.02),

                          // Status
                          AnimatedOpacity(
                            opacity: _showControls ? 1.0 : 0.3,
                            duration: const Duration(milliseconds: 100),
                            child: Text(
                              widget.isRunning
                                  ? 'FOCUS MODE'
                                  : (widget.isPaused ? 'PAUSED' : 'READY'),
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: isLandscape
                                    ? size.height * 0.03
                                    : size.width * 0.03,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isLandscape
                                  ? size.height * 0.05
                                  : size.height * 0.04),

                          // Flip Clock
                          FlipClock(
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds,
                            accentColor: widget.accentColor,
                            isRunning: widget.isRunning,
                            isFullScreen: true,
                          ),

                          SizedBox(
                              height: isLandscape
                                  ? size.height * 0.05
                                  : size.height * 0.04),

                          // Progress bar
                          AnimatedOpacity(
                            opacity: _showControls ? 1.0 : 0.3,
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isLandscape
                                    ? size.width * 0.2
                                    : size.width * 0.1,
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: const Color(0xFF2A2A3E),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          widget.accentColor),
                                      minHeight: isLandscape ? 8 : 6,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}% remaining',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: isLandscape
                                          ? size.height * 0.025
                                          : size.width * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Close button (top right)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      top: _showControls ? 16 : -60,
                      right: 16,
                      child: IconButton(
                        onPressed: widget.onClose,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A3E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close_fullscreen_rounded,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Control buttons (bottom)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: _showControls ? (isLandscape ? 20 : 40) : -100,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: Icons.refresh_rounded,
                            onPressed: widget.onReset,
                            size: isLandscape
                                ? size.height * 0.08
                                : size.width * 0.14,
                          ),
                          SizedBox(
                              width: isLandscape
                                  ? size.width * 0.03
                                  : size.width * 0.06),
                          _buildMainButton(
                            size: isLandscape
                                ? size.height * 0.12
                                : size.width * 0.2,
                          ),
                          SizedBox(
                              width: isLandscape
                                  ? size.width * 0.03
                                  : size.width * 0.06),
                          _buildControlButton(
                            icon: Icons.stop_rounded,
                            onPressed: () {
                              widget.onReset();
                              widget.onClose();
                            },
                            size: isLandscape
                                ? size.height * 0.08
                                : size.width * 0.14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A2A3E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white70, size: size * 0.45),
      ),
    );
  }

  Widget _buildMainButton({required double size}) {
    return GestureDetector(
      onTap: widget.isRunning ? widget.onPause : widget.onPlay,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.accentColor,
              widget.accentColor.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(
          widget.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
