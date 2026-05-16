import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class WaveformWidget extends StatefulWidget {
  final bool isPlaying;
  final double progressValue;

  const WaveformWidget({
    super.key,
    required this.isPlaying,
    required this.progressValue,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random(42);
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(40, (_) => _random.nextDouble() * 0.7 + 0.2);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_barHeights.length, (i) {
              final isPlayed = i / _barHeights.length <= widget.progressValue;
              final animMod = widget.isPlaying
                  ? math.sin(_controller.value * math.pi + i * 0.4) * 0.3 + 0.7
                  : 1.0;
              final barH = (_barHeights[i] * animMod * 32).clamp(4.0, 32.0);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 3,
                height: barH,
                decoration: BoxDecoration(
                  color: isPlayed
                      ? AppTheme.primary.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
