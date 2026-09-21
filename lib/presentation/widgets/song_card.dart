import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/song.dart';

/// Vertical card representing a Song (for carousels and grids)
class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onLikeTap;
  final bool isCurrent;
  final bool isPlaying;
  final double width;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    this.onPlayTap,
    this.onLikeTap,
    this.isCurrent = false,
    this.isPlaying = false,
    this.width = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Artwork Container
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CachedNetworkImage(
                      imageUrl: song.artworkUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Center(
                          child: Icon(
                            Icons.music_note,
                            color: AppColors.textMuted,
                            size: 32,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                // Play overlay button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onPlayTap ?? onTap,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent && isPlaying
                            ? AppColors.primary
                            : AppColors.backgroundSecondary.withValues(alpha: 0.85),
                        boxShadow: [
                          BoxShadow(
                            color: (isCurrent && isPlaying
                                    ? AppColors.primary
                                    : Colors.black)
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        isCurrent && isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isCurrent && isPlaying ? Colors.black : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Song Title
            Text(
              song.title,
              style: AppTypography.titleSmall.copyWith(
                color: isCurrent ? AppColors.primary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Artist Name
            Text(
              song.artist,
              style: AppTypography.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
