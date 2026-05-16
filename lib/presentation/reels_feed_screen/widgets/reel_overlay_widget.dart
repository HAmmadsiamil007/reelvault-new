import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../reels_feed_screen.dart' show ReelModel;

class ReelOverlayWidget extends StatelessWidget {
  final ReelModel reel;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const ReelOverlayWidget({
    super.key,
    required this.reel,
    required this.onLike,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 160,
      child: Column(
        children: [
          _OverlayButton(
            icon: reel.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: reel.isLiked ? AppTheme.primary : Colors.white,
            label: reel.isLiked ? 'Liked' : 'Like',
            onTap: onLike,
            isActive: reel.isLiked,
          ),
          const SizedBox(height: 16),
          _OverlayButton(
            icon: Icons.delete_rounded,
            color: AppTheme.errorColor,
            label: 'Delete',
            onTap: onDelete,
            isActive: false,
          ),
          const SizedBox(height: 16),
          _OverlayButton(
            icon: Icons.folder_rounded,
            color: Colors.white70,
            label: 'Folder',
            onTap: () {},
            isActive: false,
          ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _OverlayButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? color.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.35),
                  border: Border.all(
                    color: isActive
                        ? color.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}