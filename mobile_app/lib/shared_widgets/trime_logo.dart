import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/color_tokens.dart';

enum TrimeLogoSize { small, large }

class TrimeLogo extends StatelessWidget {
  final TrimeLogoSize size;

  const TrimeLogo({
    super.key,
    this.size = TrimeLogoSize.small,
  });

  double get _iconSize {
    switch (size) {
      case TrimeLogoSize.small:
        return 40;
      case TrimeLogoSize.large:
        return 56;
    }
  }

  double get _fontSize {
    switch (size) {
      case TrimeLogoSize.small:
        return 24;
      case TrimeLogoSize.large:
        return 32;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _iconSize,
          height: _iconSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: _iconSize,
                color: TrimeColors.primaryNavy,
              ),
              Positioned(
                top: _iconSize * 0.18,
                child: Container(
                  width: _iconSize * 0.4,
                  height: _iconSize * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: TrimeColors.primaryNavy,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.schedule,
                    size: _iconSize * 0.26,
                    color: TrimeColors.primaryNavy,
                  ),
                ),
              ),
              Positioned(
                bottom: _iconSize * 0.28,
                child: Container(
                  width: _iconSize * 0.18,
                  height: _iconSize * 0.18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        TrimeColors.barberRed,
                        TrimeColors.barberWhite,
                        TrimeColors.barberBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'TRIME',
          style: GoogleFonts.poppins(
            color: TrimeColors.primaryNavy,
            fontSize: _fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
