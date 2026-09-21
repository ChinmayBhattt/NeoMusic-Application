import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/music_library_provider.dart';
import '../../widgets/animated_artwork.dart';
import 'lyrics_sheet.dart';
import 'queue_sheet.dart';

/// Immersive Full-Screen Music Player Screen
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(currentSongStreamProvider);
    final song = songAsync.value ?? ref.watch(audioPlayerServiceProvider).currentSong;

    if (song == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('No track loaded'),
        ),
      );
    }

    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final isPlaying = playerStateAsync.value?.playing ??
        ref.watch(audioPlayerServiceProvider).isPlaying;

    final positionAsync = ref.watch(playbackPositionStreamProvider);
    final durationAsync = ref.watch(playbackDurationStreamProvider);
    final bufferedAsync = ref.watch(playbackBufferedStreamProvider);

    final position = positionAsync.value ?? Duration.zero;
    final totalDuration = durationAsync.value ?? song.duration;
    final bufferedPosition = bufferedAsync.value ?? Duration.zero;

    final shuffleAsync = ref.watch(shuffleStreamProvider);
    final isShuffle = shuffleAsync.value ?? ref.watch(audioPlayerServiceProvider).isShuffleActive;

    final repeatAsync = ref.watch(repeatStreamProvider);
    final loopMode = repeatAsync.value ?? ref.watch(audioPlayerServiceProvider).loopMode;

    final likedSongs = ref.watch(likedSongsProvider);
    final isLiked = likedSongs.any((s) => s.id == song.id);

    final controller = ref.read(playbackControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.playerBackdrop,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artworkSize = (constraints.maxHeight * 0.38).clamp(200.0, 310.0);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top App Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 32, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PLAYING FROM ALBUM',
                              style: AppTypography.labelSmall.copyWith(
                                letterSpacing: 1.2,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.album,
                              style: AppTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz_rounded,
                              size: 26, color: AppColors.textPrimary),
                          onPressed: () {
                            _showSongOptions(context, ref, song);
                          },
                        ),
                      ],
                    ),

                    const Spacer(flex: 1),

                    // Rotating Vinyl Artwork with Neon Glow
                    Hero(
                      tag: 'player_artwork_${song.id}',
                      child: AnimatedArtwork(
                        imageUrl: song.artworkUrl,
                        isPlaying: isPlaying,
                        size: artworkSize,
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Song Info and Favorite button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                song.title,
                                style: AppTypography.displayMedium.copyWith(fontSize: 22),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isLiked ? AppColors.favorite : AppColors.textMuted,
                            size: 28,
                          ),
                          onPressed: () {
                            ref.read(likedSongsProvider.notifier).toggleLike(song);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress Bar
                    ProgressBar(
                      progress: position,
                      buffered: bufferedPosition,
                      total: totalDuration,
                      onSeek: (duration) {
                        controller.seek(duration);
                      },
                      progressBarColor: AppColors.primary,
                      baseBarColor: Colors.white.withValues(alpha: 0.12),
                      bufferedBarColor: Colors.white.withValues(alpha: 0.22),
                      thumbColor: Colors.white,
                      thumbRadius: 7.0,
                      thumbGlowRadius: 18.0,
                      timeLabelTextStyle: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Player Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Shuffle
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: isShuffle ? AppColors.primary : AppColors.textMuted,
                            size: 24,
                          ),
                          onPressed: () => controller.toggleShuffle(),
                        ),

                        // Previous
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: AppColors.textPrimary,
                            size: 38,
                          ),
                          onPressed: () => controller.skipToPrevious(),
                        ),

                        // Big Play / Pause Button with Neon Glow
                        GestureDetector(
                          onTap: () => controller.togglePlayPause(),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.primaryButton,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 38,
                            ),
                          ),
                        ),

                        // Next
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: AppColors.textPrimary,
                            size: 38,
                          ),
                          onPressed: () => controller.skipToNext(),
                        ),

                        // Repeat
                        IconButton(
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                loopMode == LoopMode.one
                                    ? Icons.repeat_one_rounded
                                    : Icons.repeat_rounded,
                                color: loopMode != LoopMode.off
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 24,
                              ),
                            ],
                          ),
                          onPressed: () => controller.toggleRepeatMode(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bottom Bar Tools: Audio Quality, Lyrics, Queue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Hi-Fi Lossless badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGlass,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.surfaceGlassBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                'HI-RES LOSSLESS',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Row(
                          children: [
                            // Lyrics Button
                            IconButton(
                              icon: const Icon(Icons.lyrics_rounded,
                                  color: AppColors.textSecondary, size: 22),
                              tooltip: 'Lyrics',
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const LyricsSheet(),
                                );
                              },
                            ),

                            // Queue Button
                            IconButton(
                              icon: const Icon(Icons.queue_music_rounded,
                                  color: AppColors.textSecondary, size: 24),
                              tooltip: 'Playback Queue',
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const QueueSheet(),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSongOptions(BuildContext context, WidgetRef ref, song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.playlist_add_rounded, color: AppColors.primary),
                  title: const Text('Add to Playlist'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to My Late Night Vibes!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.album_rounded, color: AppColors.textSecondary),
                  title: Text('View Album: ${song.album}'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.person_rounded, color: AppColors.textSecondary),
                  title: Text('View Artist: ${song.artist}'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: AppColors.textSecondary),
                  title: const Text('Share Song'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
