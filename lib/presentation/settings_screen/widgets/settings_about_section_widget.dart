import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsAboutSectionWidget extends StatelessWidget {
  final int totalReels;
  final int totalStorageMB;

  const SettingsAboutSectionWidget({
    super.key,
    required this.totalReels,
    required this.totalStorageMB,
  });

  String _formatStorage(int mb) {
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '$mb MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'ABOUT'),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.09),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // App branding row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.primaryMagenta,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.video_library_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ReelVault',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Version 1.0.0',
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.primaryMagenta,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AboutDivider(),
                  // Stats row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            iconName: 'video_library',
                            iconColor: AppTheme.primary,
                            label: 'Total Reels',
                            value: '$totalReels',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Expanded(
                          child: _StatTile(
                            iconName: 'storage',
                            iconColor: const Color(0xFF4FC3F7),
                            label: 'Storage Used',
                            value: _formatStorage(totalStorageMB),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Expanded(
                          child: _StatTile(
                            iconName: 'favorite',
                            iconColor: AppTheme.primaryMagenta,
                            label: 'Liked',
                            value: '4',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AboutDivider(),
                  // Info rows
                  _AboutInfoRow(
                    iconName: 'info',
                    iconColor: Colors.white54,
                    label: 'Build',
                    value: '2026.05.16',
                  ),
                  _AboutDivider(),
                  _AboutInfoRow(
                    iconName: 'lock',
                    iconColor: Colors.white54,
                    label: 'Privacy Policy',
                    value: '',
                    isLink: true,
                  ),
                  _AboutDivider(),
                  _AboutInfoRow(
                    iconName: 'star',
                    iconColor: AppTheme.warning,
                    label: 'Rate ReelVault',
                    value: '',
                    isLink: true,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Danger zone
        _SectionLabel(label: 'DANGER ZONE'),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _DangerRow(
                    label: 'Clear Watch History',
                    subtitle: 'Remove all playback records',
                    onTap: () {},
                  ),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                  ),
                  _DangerRow(
                    label: 'Reset All Settings',
                    subtitle: 'Restore defaults, keep folders',
                    onTap: () {},
                  ),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                  ),
                  _DangerRow(
                    label: 'Remove All Folders',
                    subtitle: 'Clear vault — files stay on device',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'ReelVault v1.0.0 · Offline Reels Vault',
            style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String iconName;
  final Color iconColor;
  final String label;
  final String value;

  const _StatTile({
    required this.iconName,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomIconWidget(iconName: iconName, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}

class _AboutInfoRow extends StatelessWidget {
  final String iconName;
  final Color iconColor;
  final String label;
  final String value;
  final bool isLink;

  const _AboutInfoRow({
    required this.iconName,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          CustomIconWidget(iconName: iconName, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
            ),
          if (isLink)
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
              size: 18,
            ),
        ],
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DangerRow({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                child: Icon(
                  Icons.delete_rounded,
                  color: AppTheme.errorColor,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: AppTheme.errorColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white24,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        color: Colors.white38,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}
