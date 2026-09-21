import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

/// Animated rotating vinyl disc artwork with glowing neon aura for full player
class AnimatedArtwork extends StatefulWidget {
  final String imageUrl;
  final bool isPlaying;
  final double size;

  const AnimatedArtwork({
    super.key,
    required this.imageUrl,
    required this.isPlaying,
    this.size = 280.0,
  });

  @override
  State<AnimatedArtwork> createState() => _AnimatedArtworkState();
}

class _AnimatedArtworkState extends State<AnimatedArtwork>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Neon Glow Aura
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: widget.size * 0.95,
            height: widget.size * 0.95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.isPlaying
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.secondary.withValues(alpha: 0.15),
                  blurRadius: widget.isPlaying ? 45 : 20,
                  spreadRadius: widget.isPlaying ? 12 : 2,
                ),
              ],
            ),
          ),

          // Vinyl Outer Grooves (Subtle concentric circles)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F121A),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),

          // Rotating Vinyl Disc & Album Artwork Center
          RotationTransition(
            turns: _rotationController,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric record grooves
                Container(
                  width: widget.size * 0.92,
                  height: widget.size * 0.92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1.0,
                    ),
                  ),
                ),
                Container(
                  width: widget.size * 0.84,
                  height: widget.size * 0.84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1.0,
                    ),
                  ),
                ),

                // Center Circular Artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.size * 0.75 / 2),
                  child: SizedBox(
                    width: widget.size * 0.75,
                    height: widget.size * 0.75,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Icon(
                          Icons.album_rounded,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),

                // Center Spindle Hole
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
