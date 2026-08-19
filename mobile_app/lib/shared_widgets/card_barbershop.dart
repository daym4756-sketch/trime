import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/color_tokens.dart';
import '../theme/spacing_tokens.dart';
import 'rating_stars.dart';
import 'primary_button.dart';
import 'smart_image.dart';

class Barbershop {
  final String name;
  final double distanceKm;
  final double rating;
  final String? imageUrl;
  final bool isNew;
  final String durationOpen;
  final double? latitude;
  final double? longitude;

  const Barbershop({
    required this.name,
    required this.distanceKm,
    required this.rating,
    this.imageUrl,
    this.isNew = false,
    this.durationOpen = '',
    this.latitude,
    this.longitude,
  });
}

class CardBarbershop extends StatelessWidget {
  final Barbershop barbershop;
  final VoidCallback? onBook;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;
  final bool isFavorite;

  const CardBarbershop({
    super.key,
    required this.barbershop,
    this.onBook,
    this.onFavorite,
    this.onTap,
    this.isFavorite = false,
  });

  bool get _isOpen => barbershop.durationOpen.toLowerCase().contains('buka');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TrimeSpacing.elevationCard,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: TrimeSpacing.radiusMd,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _buildDistanceChip(),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _buildOpenStatusChip(),
                  ),
                  if (barbershop.isNew)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: _buildNewBadge(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TrimeSpacing.sm,
                TrimeSpacing.sm,
                TrimeSpacing.sm,
                TrimeSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    barbershop.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  RatingStars(
                    rating: barbershop.rating,
                    size: 12,
                    showRatingText: true,
                  ),
                  const SizedBox(height: TrimeSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Book',
                          onPressed: onBook,
                          mini: true,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: IconButton.filled(
                          onPressed: onFavorite,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: TrimeColors.surfaceAlt,
                            foregroundColor: isFavorite
                                ? TrimeColors.dangerRed
                                : TrimeColors.textSecondary,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(12),
      ),
      child: SmartImage(
        pathOrUrl: barbershop.imageUrl,
        fit: BoxFit.cover,
        placeholder: _buildPlaceholder(),
      ),
    );
  }

  // Daftar foto default barbershop dari Unsplash
  static const List<String> _defaultShopImages = [
    'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400&h=300&fit=crop&auto=format',
    'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400&h=300&fit=crop&auto=format',
    'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400&h=300&fit=crop&auto=format',
    'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400&h=300&fit=crop&auto=format',
  ];

  Widget _buildPlaceholder() {
    // Gunakan nama barbershop sebagai seed agar konsisten per toko
    final idx = barbershop.name.hashCode.abs() % _defaultShopImages.length;
    return Image.network(
      _defaultShopImages[idx],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: TrimeColors.surfaceAlt,
        child: Center(
          child: Icon(
            Icons.store,
            size: 48,
            color: TrimeColors.primaryNavy.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: TrimeSpacing.radiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            size: 12,
            color: TrimeColors.primaryNavy,
          ),
          const SizedBox(width: 2),
          Text(
            '${barbershop.distanceKm} km',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TrimeColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenStatusChip() {
    if (barbershop.durationOpen.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _isOpen
            ? TrimeColors.successGreen.withValues(alpha: 0.95)
            : TrimeColors.textMuted.withValues(alpha: 0.95),
        borderRadius: TrimeSpacing.radiusPill,
      ),
      child: Text(
        barbershop.durationOpen,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: TrimeColors.exclusiveGradient,
        borderRadius: TrimeSpacing.radiusPill,
      ),
      child: Text(
        'BARU',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
