import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../widgets/song_list_tile.dart';
import '../../widgets/artist_circle_card.dart';
import '../../widgets/album_card.dart';
import 'artist_detail_screen.dart';
import 'album_detail_screen.dart';
import 'playlist_detail_screen.dart';

/// Library Screen displaying Liked Songs, Custom Playlists, Followed Artists, and Albums
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final likedSongs = ref.watch(likedSongsProvider);
    final userPlaylists = ref.watch(userPlaylistsProvider);
    final popularArtistsAsync = ref.watch(popularArtistsProvider);
    final albumsAsync = ref.watch(featuredAlbumsProvider);

    final currentSong = ref.watch(currentSongStreamProvider).value ??
        ref.watch(audioPlayerServiceProvider).currentSong;
    final isPlaying = ref.watch(playerStateStreamProvider).value?.playing ??
        ref.watch(audioPlayerServiceProvider).isPlaying;
    final controller = ref.read(playbackControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Top Bar with Create Playlist action
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Library', style: AppTypography.displayMedium),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
                        ),
                        tooltip: 'Create Playlist',
                        onPressed: () => _showCreatePlaylistDialog(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Liked Songs Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: AppGradients.accentViolet,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _tabController.animateTo(1); // Jump to Liked Songs tab
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Liked Songs',
                                    style: AppTypography.titleLarge.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${likedSongs.length} tracks in favorites',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (likedSongs.isNotEmpty)
                              IconButton.filled(
                                icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                                style: IconButton.styleFrom(backgroundColor: Colors.white),
                                onPressed: () {
                                  controller.playSong(likedSongs.first, queueContext: likedSongs);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // TabBar pinned header
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: AppTypography.titleSmall,
                    tabs: const [
                      Tab(text: 'Playlists'),
                      Tab(text: 'Liked Tracks'),
                      Tab(text: 'Artists'),
                      Tab(text: 'Albums'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // 1. Playlists Tab
              userPlaylists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.queue_music, size: 54, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No custom playlists yet', style: AppTypography.bodyMedium),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showCreatePlaylistDialog(context),
                            child: const Text('Create Playlist'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                      itemCount: userPlaylists.length,
                      itemBuilder: (context, index) {
                        final pl = userPlaylists[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: AppGradients.primaryButton,
                              ),
                              child: const Icon(Icons.music_note, color: Colors.black),
                            ),
                            title: Text(pl.name, style: AppTypography.titleMedium),
                            subtitle: Text(
                              '${pl.songIds.length} songs • Custom Playlist',
                              style: AppTypography.bodySmall,
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                              onSelected: (val) {
                                if (val == 'delete') {
                                  ref
                                      .read(userPlaylistsProvider.notifier)
                                      .deletePlaylist(pl.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Playlist'),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaylistDetailScreen(playlist: pl),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

              // 2. Liked Tracks Tab
              likedSongs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_border, size: 54, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No liked songs yet',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the heart on any song to save it here',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 120),
                      itemCount: likedSongs.length,
                      itemBuilder: (context, index) {
                        final song = likedSongs[index];
                        final isCurrent = currentSong?.id == song.id;
                        return SongListTile(
                          index: index + 1,
                          song: song,
                          isCurrent: isCurrent,
                          isPlaying: isPlaying,
                          onTap: () => controller.playSong(song, queueContext: likedSongs),
                          onLikeTap: () =>
                              ref.read(likedSongsProvider.notifier).toggleLike(song),
                        );
                      },
                    ),

              // 3. Artists Tab
              popularArtistsAsync.when(
                data: (artists) {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ArtistCircleCard(
                              artist: artist,
                              radius: 32,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArtistDetailScreen(artist: artist),
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(artist.name, style: AppTypography.titleMedium),
                                  const SizedBox(height: 2),
                                  Text(artist.bio,
                                      style: AppTypography.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, st) => const SizedBox.shrink(),
              ),

              // 4. Albums Tab
              albumsAsync.when(
                data: (albums) {
                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      return AlbumCard(
                        album: album,
                        size: double.infinity,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlbumDetailScreen(album: album),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, st) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Create New Playlist', style: AppTypography.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Playlist name (e.g. Neon Vibes)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  hintText: 'Description (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  ref
                      .read(userPlaylistsProvider.notifier)
                      .createPlaylist(name, descController.text.trim());
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Create', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
