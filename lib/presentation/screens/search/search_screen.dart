import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/search_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/music_library_provider.dart';
import '../../widgets/song_list_tile.dart';
import '../../widgets/artist_circle_card.dart';
import '../../widgets/album_card.dart';
import '../../widgets/playlist_card.dart';
import '../library/artist_detail_screen.dart';
import '../library/album_detail_screen.dart';
import '../library/playlist_detail_screen.dart';

/// Search Screen with real-time query, genre browse cards, and tab filtering
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Color> _categoryColors = const [
    Color(0xFFE11D48),
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF0D9488),
    Color(0xFFD97706),
    Color(0xFF059669),
    Color(0xFFDB2777),
    Color(0xFF4F46E5),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final selectedTab = ref.watch(selectedSearchTabProvider);
    final selectedGenre = ref.watch(selectedGenreFilterProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);

    final currentSong = ref.watch(currentSongStreamProvider).value ??
        ref.watch(audioPlayerServiceProvider).currentSong;
    final isPlaying = ref.watch(playerStateStreamProvider).value?.playing ??
        ref.watch(audioPlayerServiceProvider).isPlaying;
    final controller = ref.read(playbackControllerProvider);

    final isSearching = query.isNotEmpty || selectedGenre != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text('Search & Explore', style: AppTypography.displayMedium),
            ),

            // Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: selectedGenre != null
                      ? 'Search in $selectedGenre...'
                      : 'Songs, artists, albums, or genres...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: (query.isNotEmpty || selectedGenre != null)
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).clear();
                            ref.read(selectedGenreFilterProvider.notifier).setGenre(null);
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).setQuery(val);
                },
              ),
            ),

            const SizedBox(height: 12),

            // Filter Tabs (All, Songs, Artists, Albums, Playlists)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTabChip('All', 0, selectedTab),
                  _buildTabChip('Songs', 1, selectedTab),
                  _buildTabChip('Artists', 2, selectedTab),
                  _buildTabChip('Albums', 3, selectedTab),
                  _buildTabChip('Playlists', 4, selectedTab),
                ],
              ),
            ),

            if (selectedGenre != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text('Filter:', style: AppTypography.bodySmall),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(selectedGenre),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        ref.read(selectedGenreFilterProvider.notifier).setGenre(null);
                      },
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                      deleteIconColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Content Area: Either Categories Grid or Search Results
            Expanded(
              child: !isSearching
                  ? _buildCategoryBrowseGrid()
                  : searchResultsAsync.when(
                      data: (results) {
                        if (results.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off_rounded,
                                    size: 56, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'No results found for "$query"',
                                  style: AppTypography.bodyMedium
                                      .copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 120),
                          children: [
                            // Songs results
                            if ((selectedTab == 0 || selectedTab == 1) &&
                                results.songs.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                                child: Text('Songs (${results.songs.length})',
                                    style: AppTypography.titleMedium),
                              ),
                              ...results.songs.map((song) {
                                final isCurrent = currentSong?.id == song.id;
                                return SongListTile(
                                  song: song,
                                  isCurrent: isCurrent,
                                  isPlaying: isPlaying,
                                  onTap: () => controller.playSong(song,
                                      queueContext: results.songs),
                                  onLikeTap: () => ref
                                      .read(likedSongsProvider.notifier)
                                      .toggleLike(song),
                                );
                              }),
                            ],

                            // Artists results
                            if ((selectedTab == 0 || selectedTab == 2) &&
                                results.artists.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                child: Text('Artists', style: AppTypography.titleMedium),
                              ),
                              SizedBox(
                                height: 155,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: results.artists.length,
                                  itemBuilder: (context, index) {
                                    final artist = results.artists[index];
                                    return ArtistCircleCard(
                                      artist: artist,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ArtistDetailScreen(artist: artist),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],

                            // Albums results
                            if ((selectedTab == 0 || selectedTab == 3) &&
                                results.albums.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                child: Text('Albums', style: AppTypography.titleMedium),
                              ),
                              SizedBox(
                                height: 215,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: results.albums.length,
                                  itemBuilder: (context, index) {
                                    final album = results.albums[index];
                                    return AlbumCard(
                                      album: album,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AlbumDetailScreen(album: album),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],

                            // Playlists results
                            if ((selectedTab == 0 || selectedTab == 4) &&
                                results.playlists.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                child: Text('Playlists', style: AppTypography.titleMedium),
                              ),
                              SizedBox(
                                height: 235,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: results.playlists.length,
                                  itemBuilder: (context, index) {
                                    final playlist = results.playlists[index];
                                    return PlaylistCard(
                                      playlist: playlist,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PlaylistDetailScreen(
                                                playlist: playlist),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      error: (err, _) => Center(
                        child: Text(
                          'Error loading search: $err',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int index, int selectedTab) {
    final isSelected = selectedTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            ref.read(selectedSearchTabProvider.notifier).setTab(index);
          }
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? Colors.black : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.surfaceGlassBorder,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildCategoryBrowseGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('Explore Genres & Vibes', style: AppTypography.titleLarge),
        ),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.6,
            ),
            itemCount: AppConstants.browseGenres.length,
            itemBuilder: (context, index) {
              final genre = AppConstants.browseGenres[index];
              final baseColor = _categoryColors[index % _categoryColors.length];

              return InkWell(
                onTap: () {
                  ref.read(selectedGenreFilterProvider.notifier).setGenre(genre);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        baseColor.withValues(alpha: 0.9),
                        baseColor.withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Stack(
                    children: [
                      Text(
                        genre,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Icon(
                          Icons.album_rounded,
                          color: Colors.white.withValues(alpha: 0.22),
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
