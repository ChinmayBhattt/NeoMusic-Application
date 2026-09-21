import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/audio_player_provider.dart';

/// Modal bottom sheet displaying synchronized, interactive lyrics
class LyricsSheet extends ConsumerWidget {
  const LyricsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(currentSongStreamProvider);
    final song = songAsync.value ?? ref.watch(audioPlayerServiceProvider).currentSong;

    if (song == null || song.lyrics.isEmpty) {
      return Container(
        height: 380,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('Lyrics', style: AppTypography.titleLarge),
            const Spacer(),
            const Icon(Icons.music_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No synchronized lyrics available for this track',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      );
    }

    final positionAsync = ref.watch(playbackPositionStreamProvider);
    final currentPosition = positionAsync.value ?? Duration.zero;

    // Find active lyric line index
    int activeIndex = -1;
    for (int i = 0; i < song.lyrics.length; i++) {
      if (currentPosition >= song.lyrics[i].time) {
        activeIndex = i;
      } else {
        break;
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Synchronized Lyrics', style: AppTypography.titleLarge),
                  Text(song.title, style: AppTypography.bodySmall),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lyrics List
          Expanded(
            child: ListView.builder(
              itemCount: song.lyrics.length,
              itemBuilder: (context, index) {
                final line = song.lyrics[index];
                final isActive = index == activeIndex;

                return GestureDetector(
                  onTap: () {
                    ref.read(playbackControllerProvider).seek(line.time);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isActive
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Text(
                      line.text,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: isActive ? 20 : 16,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
