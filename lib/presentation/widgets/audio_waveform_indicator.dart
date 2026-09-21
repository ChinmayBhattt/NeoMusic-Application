import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Animated music visualizer waveform bars
class AudioWaveformIndicator extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double height;
  final int barCount;

  const AudioWaveformIndicator({
    super.key,
    required this.isPlaying,
    this.color = AppColors.primary,
    this.height = 18.0,
    this.barCount = 4,
  });

  @override
  State<AudioWaveformIndicator> createState() => _AudioWaveformIndicatorState();
}

class _AudioWaveformIndicatorState extends State<AudioWaveformIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AudioWaveformIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.barCount, (index) {
            // Unique staggered wave height calculation
            double progress = (_controller.value + (index * 0.25)) % 1.0;
            if (!widget.isPlaying) {
              progress = 0.25;
            }
            final currentHeight = 4.0 + (progress * (widget.height - 4.0));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3.0,
              height: currentHeight,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2.0),
              ),
            );
          }),
        );
      },
    );
  }
}
