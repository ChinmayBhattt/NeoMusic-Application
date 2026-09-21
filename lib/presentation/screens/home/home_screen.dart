import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/music_library_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/song_card.dart';
import '../../widgets/song_list_tile.dart';
import '../../widgets/artist_circle_card.dart';
import '../../widgets/playlist_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/notifications_sheet.dart';
import '../../providers/notifications_provider.dart';
import '../library/artist_detail_screen.dart';
import '../library/playlist_detail_screen.dart';
import '../settings/settings_screen.dart';

/// Home Screen featuring personalized greeting, hero featured banner,
/// trending tracks, popular artists, and curated playlists.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = user?.name.split(' ').first ?? 'Explorer';

    final featuredSongsAsync = ref.watch(featuredSongsProvider);
    final trendingSongsAsync = ref.watch(trendingSongsProvider);
    final popularArtistsAsync = ref.watch(popularArtistsProvider);
    final featuredPlaylistsAsync = ref.watch(featuredPlaylistsProvider);
    final newReleasesAsync = ref.watch(newReleasesProvider);
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    final unreadNotifCount = ref.watch(unreadNotificationsCountProvider);

    final currentSong = ref.watch(currentSongStreamProvider).value ??
        ref.watch(audioPlayerServiceProvider).currentSong;
    final isPlaying = ref.watch(playerStateStreamProvider).value?.playing ??
        ref.watch(audioPlayerServiceProvider).isPlaying;

    final controller = ref.read(playbackControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.getGreeting(),
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: AppTypography.displayMedium,
                        ),
                      ],
                    ),
                    // Notification & User Avatar
                    Row(
                      children: [
                        Tooltip(
                          message: 'Notifications',
                          child: InkWell(
                            onTap: () => NotificationsSheet.show(context),
                            borderRadius: BorderRadius.circular(21),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surfaceGlassBorder),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.textPrimary,
                                    size: 22,
                                  ),
                                  if (unreadNotifCount > 0)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.6),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message: 'Profile & Settings',
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(21),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.surfaceElevated,
                                backgroundImage: ImageHelper.getImageProvider(user?.avatarUrl),
                                child: ImageHelper.getImageProvider(user?.avatarUrl) == null
                                    ? const Icon(Icons.person, color: AppColors.textSecondary)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Quick Filter Chips Row
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['All', ...AppConstants.browseGenres].map((genre) {
                    final isSelected = _selectedFilter == genre;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = genre;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        labelStyle: AppTypography.labelSmall.copyWith(
                          color: isSelected ? Colors.black : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceGlassBorder,
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Hero Featured Banner
            featuredSongsAsync.when(
              data: (featured) {
                if (featured.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                final heroSong = featured.first;
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    height: 175,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: AppGradients.heroCard,
                      border: Border.all(color: AppColors.surfaceGlassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Right background artwork with blend
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 170,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: heroSong.artworkUrl,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF0E1320),
                                        const Color(0xFF0E1320).withValues(alpha: 0.1),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Left content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'FEATURED RELEASE',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    heroSong.title,
                                    style: AppTypography.titleLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    heroSong.artist,
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  controller.playSong(heroSong, queueContext: featured);
                                },
                                icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                                label: Text(
                                  'Play Now',
                                  style: AppTypography.labelLarge.copyWith(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Recently Played Section (if user has played tracks)
            if (recentlyPlayed.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Jump Back In',
                  subtitle: 'Recently played tracks and frequencies',
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 215,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: recentlyPlayed.length,
                    itemBuilder: (context, index) {
                      final song = recentlyPlayed[index];
                      final isCurrent = currentSong?.id == song.id;
                      return SongCard(
                        song: song,
                        isCurrent: isCurrent,
                        isPlaying: isPlaying,
                        onTap: () => controller.playSong(song, queueContext: recentlyPlayed),
                        onPlayTap: () {
                          if (isCurrent) {
                            controller.togglePlayPause();
                          } else {
                            controller.playSong(song, queueContext: recentlyPlayed);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],

            // Trending Songs Section (Top Rankings)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Trending Tracks',
                subtitle: 'Most streamed across the Neo network',
              ),
            ),
            trendingSongsAsync.when(
              data: (trending) {
                final filtered = _selectedFilter == 'All'
                    ? trending
                    : trending.where((s) => s.genre == _selectedFilter).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No songs found for $_selectedFilter',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = filtered[index];
                      final isCurrent = currentSong?.id == song.id;
                      return SongListTile(
                        index: index + 1,
                        song: song,
                        isCurrent: isCurrent,
                        isPlaying: isPlaying,
                        onTap: () => controller.playSong(song, queueContext: filtered),
                        onLikeTap: () => ref.read(likedSongsProvider.notifier).toggleLike(song),
                      );
                    },
                    childCount: filtered.length.clamp(0, 6),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Popular Artists Section
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Popular Artists',
                subtitle: 'Producers shaping the electronic wave',
              ),
            ),
            popularArtistsAsync.when(
              data: (artists) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 155,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: artists.length,
                      itemBuilder: (context, index) {
                        final artist = artists[index];
                        return ArtistCircleCard(
                          artist: artist,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ArtistDetailScreen(artist: artist),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Curated Playlists Section
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Curated Playlists',
                subtitle: 'Engineered for focus, flow, and nocturnal chill',
              ),
            ),
            featuredPlaylistsAsync.when(
              data: (playlists) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 235,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return PlaylistCard(
                          playlist: playlist,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlaylistDetailScreen(playlist: playlist),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // New Releases Carousel
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Fresh Releases',
                subtitle: 'Brand new tracks dropped this week',
              ),
            ),
            newReleasesAsync.when(
              data: (releases) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 215,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: releases.length,
                      itemBuilder: (context, index) {
                        final song = releases[index];
                        final isCurrent = currentSong?.id == song.id;
                        return SongCard(
                          song: song,
                          isCurrent: isCurrent,
                          isPlaying: isPlaying,
                          onTap: () => controller.playSong(song, queueContext: releases),
                          onPlayTap: () {
                            if (isCurrent) {
                              controller.togglePlayPause();
                            } else {
                              controller.playSong(song, queueContext: releases);
                            }
                          },
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Bottom Spacing for Mini-player
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
