import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/music_library_provider.dart';
import '../screens/player/player_screen.dart';

/// Persistent Floating Mini-Player positioned right above bottom navigation
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(currentSongStreamProvider);
    final song = songAsync.value ?? ref.watch(audioPlayerServiceProvider).currentSong;

    if (song == null) {
      return const SizedBox.shrink();
    }

    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final isPlaying = playerStateAsync.value?.playing ??
        ref.watch(audioPlayerServiceProvider).isPlaying;

    final positionAsync = ref.watch(playbackPositionStreamProvider);
    final durationAsync = ref.watch(playbackDurationStreamProvider);

    final position = positionAsync.value ?? Duration.zero;
    final duration = durationAsync.value ?? song.duration;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final likedSongs = ref.watch(likedSongsProvider);
    final isLiked = likedSongs.any((s) => s.id == song.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.miniPlayerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceGlassBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, anim, secondaryAnim) => const PlayerScreen(),
                      transitionsBuilder: (context, anim, secondaryAnim, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      // Rotating or static artwork thumbnail
                      Hero(
                        tag: 'player_artwork_${song.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child: CachedNetworkImage(
                              imageUrl: song.artworkUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceElevated,
                                child: const Icon(
                                  Icons.music_note,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceElevated,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Song & Artist Titles
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              song.title,
                              style: AppTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist,
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Favorite toggle button
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isLiked ? AppColors.favorite : AppColors.textMuted,
                          size: 22,
                        ),
                        splashRadius: 20,
                        onPressed: () {
                          ref.read(likedSongsProvider.notifier).toggleLike(song);
                        },
                      ),

                      // Play/Pause button
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        splashRadius: 22,
                        onPressed: () {
                          ref.read(playbackControllerProvider).togglePlayPause();
                        },
                      ),

                      // Skip next button
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                        splashRadius: 20,
                        onPressed: () {
                          ref.read(playbackControllerProvider).skipToNext();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Thin neon progress line along the bottom
              LinearProgressIndicator(
                value: progress,
                minHeight: 2.5,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
