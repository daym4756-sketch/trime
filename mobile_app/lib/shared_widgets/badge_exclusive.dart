import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/color_tokens.dart';
import '../theme/spacing_tokens.dart';

enum BadgeType { exclusive, lonspector, ready, promo }

class BadgeExclusive extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? prefixIcon;

  const BadgeExclusive({
    super.key,
    required this.text,
    required this.type,
    this.prefixIcon,
  });

  Color get _solidColor {
    switch (type) {
      case BadgeType.exclusive:
        return TrimeColors.primaryNavy;
      case BadgeType.lonspector:
        return const Color(0xFF7C3AED);
      case BadgeType.ready:
        return TrimeColors.successGreen;
      case BadgeType.promo:
        return TrimeColors.warningOrange;
    }
  }

  Gradient? get _gradient {
    if (type == BadgeType.exclusive) {
      return TrimeColors.exclusiveGradient;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _gradient == null ? _solidColor : null,
        gradient: _gradient,
        borderRadius: TrimeSpacing.radiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) ...[
            Icon(
              prefixIcon,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
