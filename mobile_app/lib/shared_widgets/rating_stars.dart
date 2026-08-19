import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/color_tokens.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showRatingText;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.showRatingText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          final diff = rating - starValue;

          if (diff >= 0) {
            return Icon(
              Icons.star,
              color: TrimeColors.starGold,
              size: size,
            );
          } else if (diff > -1) {
            return Icon(
              Icons.star_half,
              color: TrimeColors.starGold,
              size: size,
            );
          } else {
            return Icon(
              Icons.star_border,
              color: TrimeColors.starGold,
              size: size,
            );
          }
        }),
        if (showRatingText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w600,
              color: TrimeColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
