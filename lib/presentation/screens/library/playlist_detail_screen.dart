import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/playlist.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/song_list_tile.dart';

/// Playlist Detail Screen showing cover, description, track count, play & shuffle, and songs
class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicRepo = ref.watch(musicRepositoryProvider);
    final controller = ref.read(playbackControllerProvider);
    final currentSong = ref.watch(currentSongStreamProvider).value ??
        ref.watch(audioPlayerServiceProvider).currentSong;
    final isPlaying = ref.watch(playerStateStreamProvider).value?.playing ??
        ref.watch(audioPlayerServiceProvider).isPlaying;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder(
        future: musicRepo.getSongsByIds(playlist.songIds),
        builder: (context, snapshot) {
          final songs = snapshot.data ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: playlist.coverUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xCC090B10),
                              AppColors.background,
                            ],
                            stops: [0.3, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Playlist Info & Action Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(playlist.name, style: AppTypography.displayMedium),
                      const SizedBox(height: 6),
                      Text(
                        playlist.description,
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${songs.length} songs',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: songs.isEmpty
                                  ? null
                                  : () {
                                      controller.playSong(songs.first, queueContext: songs);
                                    },
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                              label: Text(
                                'Play All',
                                style: AppTypography.labelLarge.copyWith(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.shuffle_rounded, color: AppColors.primary),
                            onPressed: songs.isEmpty
                                ? null
                                : () {
                                    controller.toggleShuffle();
                                    controller.playSong(songs.first, queueContext: songs);
                                  },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceElevated,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Songs List
              if (songs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No tracks in this playlist yet.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      final isCurrent = currentSong?.id == song.id;
                      return SongListTile(
                        index: index + 1,
                        song: song,
                        isCurrent: isCurrent,
                        isPlaying: isPlaying,
                        onTap: () => controller.playSong(song, queueContext: songs),
                        onLikeTap: () => ref.read(likedSongsProvider.notifier).toggleLike(song),
                      );
                    },
                    childCount: songs.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}
