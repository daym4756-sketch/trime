import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/color_tokens.dart';
import '../theme/spacing_tokens.dart';
import 'rating_stars.dart';
import 'badge_exclusive.dart';
import 'smart_image.dart';

class Kapster {
  final String nama;
  final String? fotoUrl;
  final double rating;
  final List<String> spesialisasi;
  final String? badgeType;
  final bool isReady;
  final String? topRank;

  const Kapster({
    required this.nama,
    this.fotoUrl,
    required this.rating,
    this.spesialisasi = const [],
    this.badgeType,
    this.isReady = false,
    this.topRank,
  });
}

class CardKapster extends StatelessWidget {
  final Kapster kapster;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const CardKapster({
    super.key,
    required this.kapster,
    this.onTap,
    this.isFavorite = false,
    this.onFavorite,
  });

  BadgeType? get _badgeType {
    switch (kapster.badgeType) {
      case 'exclusive':
        return BadgeType.exclusive;
      case 'lonspector':
        return BadgeType.lonspector;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TrimeSpacing.elevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: TrimeSpacing.radiusMd,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: TrimeSpacing.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(TrimeSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmartAvatar(
                pathOrUrl: kapster.fotoUrl,
                radius: 36,
                fallbackIcon: Icons.person,
              ),
              const SizedBox(width: TrimeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (kapster.topRank != null && kapster.topRank!.isNotEmpty)
                          _buildTopRankChip(),
                        const Spacer(),
                        if (_badgeType != null) ...[
                          BadgeExclusive(
                            text: kapster.badgeType == 'exclusive'
                                ? 'TRIME Exclusive'
                                : 'Lonspector',
                            type: _badgeType!,
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (onFavorite != null)
                          GestureDetector(
                            onTap: onFavorite,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isFavorite ? TrimeColors.dangerRed : TrimeColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: TrimeSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            kapster.nama,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: TrimeSpacing.sm),
                        RatingStars(
                          rating: kapster.rating,
                          size: 14,
                          showRatingText: true,
                        ),
                      ],
                    ),
                    if (kapster.spesialisasi.isNotEmpty) ...[
                      const SizedBox(height: TrimeSpacing.sm),
                      Wrap(
                        spacing: TrimeSpacing.sm,
                        runSpacing: TrimeSpacing.xs,
                        children: kapster.spesialisasi
                            .map((spesialisasi) => _buildSpesialisasiChip(spesialisasi))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: TrimeSpacing.sm),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kapster.isReady
                                ? TrimeColors.successGreen
                                : TrimeColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          kapster.isReady
                              ? 'Siap Terima Booking'
                              : 'Tidak Tersedia',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kapster.isReady
                                ? TrimeColors.successGreen
                                : TrimeColors.textMuted,
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
      ),
    );
  }

  Widget _buildTopRankChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: TrimeColors.exclusiveGradient,
        borderRadius: TrimeSpacing.radiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium,
            size: 12,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            kapster.topRank!,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpesialisasiChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: TrimeColors.surfaceAlt,
        borderRadius: TrimeSpacing.radiusPill,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: TrimeColors.primaryNavy,
        ),
      ),
    );
  }
}
