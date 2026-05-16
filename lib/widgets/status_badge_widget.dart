import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum ReelStatus { playing, liked, new_, deleted, scanning }

class StatusBadgeWidget extends StatelessWidget {
  final ReelStatus status;
  final String? customLabel;

  const StatusBadgeWidget({super.key, required this.status, this.customLabel});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: config.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        customLabel ?? config.label,
        style: GoogleFonts.outfit(
          color: config.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (status) {
      case ReelStatus.playing:
        return _BadgeConfig(AppTheme.primary, 'PLAYING');
      case ReelStatus.liked:
        return _BadgeConfig(const Color(0xFFFF6B9D), 'LIKED');
      case ReelStatus.new_:
        return _BadgeConfig(AppTheme.success, 'NEW');
      case ReelStatus.deleted:
        return _BadgeConfig(AppTheme.errorColor, 'DELETED');
      case ReelStatus.scanning:
        return _BadgeConfig(AppTheme.warning, 'SCANNING');
    }
  }
}

class _BadgeConfig {
  final Color color;
  final String label;
  _BadgeConfig(this.color, this.label);
}
