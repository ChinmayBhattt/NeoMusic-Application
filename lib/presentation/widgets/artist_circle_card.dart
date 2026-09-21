import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/artist.dart';

/// Circular Artist Card with follower count
class ArtistCircleCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;
  final double radius;

  const ArtistCircleCard({
    super.key,
    required this.artist,
    required this.onTap,
    this.radius = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Avatar with subtle glowing border
            Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.6),
                    AppColors.secondary.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: AppColors.surfaceElevated,
                backgroundImage: CachedNetworkImageProvider(artist.avatarUrl),
              ),
            ),
            const SizedBox(height: 8),
            // Artist Name
            SizedBox(
              width: radius * 2.2,
              child: Text(
                artist.name,
                style: AppTypography.titleSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            // Monthly Listeners
            Text(
              '${Formatters.formatNumber(artist.monthlyListeners)} listeners',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
