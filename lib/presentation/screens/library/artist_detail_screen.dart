import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/artist.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/song_list_tile.dart';

/// Artist Detail Screen showcasing avatar, monthly listeners, bio, top songs, and discography
class ArtistDetailScreen extends ConsumerStatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  ConsumerState<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends ConsumerState<ArtistDetailScreen> {
  late bool _isFollowed;

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.artist.isFollowed;
  }

  @override
  Widget build(BuildContext context) {
    final musicRepo = ref.watch(musicRepositoryProvider);
    final controller = ref.read(playbackControllerProvider);
    final currentSong = ref.watch(currentSongStreamProvider).value ??
        ref.watch(audioPlayerServiceProvider).currentSong;
    final isPlaying = ref.watch(playerStateStreamProvider).value?.playing ??
        ref.watch(audioPlayerServiceProvider).isPlaying;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder(
        future: musicRepo.getSongsByArtist(widget.artist.id),
        builder: (context, snapshot) {
          final songs = snapshot.data ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Artist Header AppBar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.backgroundSecondary,
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
                  titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  title: Text(
                    widget.artist.name,
                    style: AppTypography.titleLarge.copyWith(color: Colors.white),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.artist.avatarUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.imageOverlay,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Artist Meta & Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Formatters.formatNumber(widget.artist.monthlyListeners)} monthly listeners',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.artist.bio,
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          // Follow / Unfollow Button
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isFollowed = !_isFollowed;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isFollowed
                                        ? 'Followed ${widget.artist.name}'
                                        : 'Unfollowed ${widget.artist.name}',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _isFollowed ? AppColors.textMuted : AppColors.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: Text(
                              _isFollowed ? 'Following' : 'Follow',
                              style: AppTypography.labelLarge.copyWith(
                                color: _isFollowed ? AppColors.textMuted : AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Play All Button
                          if (songs.isNotEmpty)
                            FloatingActionButton.small(
                              onPressed: () {
                                controller.playSong(songs.first, queueContext: songs);
                              },
                              backgroundColor: AppColors.primary,
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Popular Tracks Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Popular Tracks', style: AppTypography.titleLarge),
                ),
              ),

              // Tracks List
              if (songs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
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
