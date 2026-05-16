import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsPlaybackSectionWidget extends StatelessWidget {
  final bool autoPlay;
  final bool loopVideos;
  final bool holdFor2x;
  final bool hapticFeedback;
  final ValueChanged<bool> onAutoPlayChanged;
  final ValueChanged<bool> onLoopVideosChanged;
  final ValueChanged<bool> onHoldFor2xChanged;
  final ValueChanged<bool> onHapticFeedbackChanged;

  const SettingsPlaybackSectionWidget({
    super.key,
    required this.autoPlay,
    required this.loopVideos,
    required this.holdFor2x,
    required this.hapticFeedback,
    required this.onAutoPlayChanged,
    required this.onLoopVideosChanged,
    required this.onHoldFor2xChanged,
    required this.onHapticFeedbackChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'PLAYBACK'),
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
                  _PlaybackToggleRow(
                    iconName: 'play_circle',
                    iconColor: AppTheme.primary,
                    label: 'Auto Play',
                    subtitle: 'Start playing when reel loads',
                    value: autoPlay,
                    onChanged: onAutoPlayChanged,
                  ),
                  _PlaybackDivider(),
                  _PlaybackToggleRow(
                    iconName: 'loop',
                    iconColor: const Color(0xFF4FC3F7),
                    label: 'Loop Videos',
                    subtitle: 'Replay reel when it ends',
                    value: loopVideos,
                    onChanged: onLoopVideosChanged,
                  ),
                  _PlaybackDivider(),
                  _PlaybackToggleRow(
                    iconName: 'speed',
                    iconColor: AppTheme.warning,
                    label: '2× Hold Speed',
                    subtitle: 'Hold left/right for fast playback',
                    value: holdFor2x,
                    onChanged: onHoldFor2xChanged,
                  ),
                  _PlaybackDivider(),
                  _PlaybackToggleRow(
                    iconName: 'vibration',
                    iconColor: AppTheme.success,
                    label: 'Gesture Haptics',
                    subtitle: 'Vibration feedback on gestures',
                    value: hapticFeedback,
                    onChanged: onHapticFeedbackChanged,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaybackToggleRow extends StatelessWidget {
  final String iconName;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PlaybackToggleRow({
    required this.iconName,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: iconColor,
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
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.primary,
            inactiveThumbColor: const Color(0xFF666688),
            inactiveTrackColor: const Color(0xFF2A2A4A),
          ),
        ],
      ),
    );
  }
}

class _PlaybackDivider extends StatelessWidget {
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
