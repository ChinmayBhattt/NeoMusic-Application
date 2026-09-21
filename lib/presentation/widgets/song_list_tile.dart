import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/song.dart';
import 'audio_waveform_indicator.dart';

/// Reusable track tile for lists, search, trending, and playlists
class SongListTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onMoreTap;
  final int? index;
  final bool isCurrent;
  final bool isPlaying;
  final bool showArtwork;

  const SongListTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onLikeTap,
    this.onMoreTap,
    this.index,
    this.isCurrent = false,
    this.isPlaying = false,
    this.showArtwork = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Index / Ranking number
            if (index != null)
              Container(
                width: 28,
                alignment: Alignment.centerLeft,
                child: isCurrent && isPlaying
                    ? const AudioWaveformIndicator(isPlaying: true, height: 14)
                    : Text(
                        '$index',
                        style: AppTypography.titleSmall.copyWith(
                          color: isCurrent ? AppColors.primary : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),

            // Artwork
            if (showArtwork) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: song.artworkUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceElevated,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceElevated,
                          child: const Icon(Icons.music_note, color: AppColors.textMuted, size: 20),
                        ),
                      ),
                      if (isCurrent && isPlaying && index == null)
                        Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: const Center(
                            child: AudioWaveformIndicator(isPlaying: true, height: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],

            // Song & Artist details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        song.genre,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          song.artist,
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Duration
            Text(
              Formatters.formatDuration(song.duration),
              style: AppTypography.bodySmall.copyWith(
                color: isCurrent ? AppColors.primary : AppColors.textMuted,
              ),
            ),

            // Favorite Button
            if (onLikeTap != null)
              IconButton(
                icon: Icon(
                  song.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: song.isLiked ? AppColors.favorite : AppColors.textMuted,
                  size: 20,
                ),
                splashRadius: 20,
                onPressed: onLikeTap,
              ),

            // More Options
            if (onMoreTap != null)
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
                splashRadius: 20,
                onPressed: onMoreTap,
              ),
          ],
        ),
      ),
    );
  }
}
