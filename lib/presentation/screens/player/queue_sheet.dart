import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/audio_waveform_indicator.dart';

/// Modal bottom sheet for viewing, reordering, and removing tracks from queue
class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueStreamProvider);
    final queue = queueAsync.value ?? ref.watch(audioPlayerServiceProvider).queue;

    final songAsync = ref.watch(currentSongStreamProvider);
    final currentSong = songAsync.value ?? ref.watch(audioPlayerServiceProvider).currentSong;

    final isPlaying = ref.watch(playerStateStreamProvider).value?.playing ??
        ref.watch(audioPlayerServiceProvider).isPlaying;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              Text('Playback Queue (${queue.length})', style: AppTypography.titleLarge),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: queue.isEmpty
                ? Center(
                    child: Text(
                      'Queue is empty',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: queue.length,
                    onReorderItem: (oldIndex, newIndex) {
                      ref.read(playbackControllerProvider).reorderQueue(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final song = queue[index];
                      final isCurrent = currentSong?.id == song.id;

                      return Container(
                        key: ValueKey('queue_${song.id}_$index'),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.surfaceElevated.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: isCurrent
                              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          leading: isCurrent
                              ? AudioWaveformIndicator(isPlaying: isPlaying, height: 16)
                              : Text(
                                  '${index + 1}',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                          title: Text(
                            song.title,
                            style: AppTypography.titleSmall.copyWith(
                              color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            song.artist,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            ref.read(playbackControllerProvider).playSong(song, queueContext: queue);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded,
                                    color: AppColors.textMuted, size: 20),
                                onPressed: () {
                                  ref
                                      .read(playbackControllerProvider)
                                      .removeSongFromQueue(index);
                                },
                              ),
                              const Icon(Icons.drag_handle_rounded,
                                  color: AppColors.textMuted, size: 22),
                            ],
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
