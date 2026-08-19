import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/color_tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? prefixIcon;
  final double borderRadius;
  final EdgeInsets padding;
  final bool mini;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.prefixIcon,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.mini = false,
  });

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = mini
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : padding;
    final effectiveFontSize = mini ? 12.0 : 14.0;
    final effectiveIconSize = mini ? 16.0 : 18.0;
    final effectiveBorderRadius = mini ? 6.0 : borderRadius;

    return SizedBox(
      width: mini ? null : double.infinity,
      child: ElevatedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (_isDisabled) return TrimeColors.textMuted.withValues(alpha: 0.3);
            return TrimeColors.primaryNavy;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (_isDisabled) return TrimeColors.textMuted;
            return Colors.white;
          }),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (_isDisabled) return 0;
            if (states.contains(WidgetState.pressed)) return 4;
            return 1;
          }),
          padding: WidgetStateProperty.all(effectivePadding),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
        child: isLoading
            ? SizedBox(
                height: effectiveFontSize + 4,
                width: effectiveFontSize + 4,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(
                      prefixIcon,
                      size: effectiveIconSize,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: effectiveFontSize,
                      fontWeight: FontWeight.w600,
                      color: _isDisabled
                          ? TrimeColors.textMuted
                          : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
