import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/album.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/song_list_tile.dart';

/// Album Detail Screen showing album artwork, artist, release year, and track list
class AlbumDetailScreen extends ConsumerWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

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
        future: musicRepo.getSongsByAlbum(album.id),
        builder: (context, snapshot) {
          final songs = snapshot.data ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 290,
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
                        imageUrl: album.coverUrl,
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

              // Album Meta
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(album.title, style: AppTypography.displayMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Album by ${album.artist} • ${album.releaseYear}',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Genre: ${album.genre} • ${songs.length} tracks',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: songs.isEmpty
                            ? null
                            : () {
                                controller.playSong(songs.first, queueContext: songs);
                              },
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                        label: Text(
                          'Play Album',
                          style: AppTypography.labelLarge.copyWith(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Track listing
              if (songs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No songs found for this album.',
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
                        showArtwork: false,
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
