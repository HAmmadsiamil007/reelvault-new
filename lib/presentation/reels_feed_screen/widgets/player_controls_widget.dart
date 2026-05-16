import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../reels_feed_screen.dart' show ReelModel;
import './waveform_widget.dart';

class PlayerControlsWidget extends StatelessWidget {
  final ReelModel reel;
  final double progressValue;
  final bool isPlaying;
  final ValueChanged<double> onProgressChanged;
  final VoidCallback onPlayPause;
  final String Function(Duration) formatDuration;

  const PlayerControlsWidget({
    super.key,
    required this.reel,
    required this.progressValue,
    required this.isPlaying,
    required this.onProgressChanged,
    required this.onPlayPause,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final elapsed = Duration(
      seconds: (reel.duration.inSeconds * progressValue).toInt(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // File name + folder
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reel.fileName
                                .replaceAll('.mp4', '')
                                .replaceAll('_', ' '),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reel.folderName,
                            style: GoogleFonts.outfit(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Volume row
                Row(
                  children: [
                    const Icon(
                      Icons.volume_off_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          trackHeight: 2,
                          activeTrackColor: AppTheme.primary,
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.15,
                          ),
                          thumbColor: Colors.white,
                          overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                        ),
                        child: Slider(value: 0.75, onChanged: (_) {}),
                      ),
                    ),
                    const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Controls row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlBtn(
                      icon: Icons.skip_previous_rounded,
                      size: 28,
                      onTap: () {},
                    ),
                    _ControlBtn(
                      icon: Icons.replay_10_rounded,
                      size: 28,
                      onTap: () {},
                    ),
                    // Play/Pause (large pill)
                    GestureDetector(
                      onTap: onPlayPause,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryMagenta],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    _ControlBtn(
                      icon: Icons.forward_10_rounded,
                      size: 28,
                      onTap: () {},
                    ),
                    _ControlBtn(
                      icon: Icons.skip_next_rounded,
                      size: 28,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Waveform
                WaveformWidget(
                  isPlaying: isPlaying,
                  progressValue: progressValue,
                ),
                const SizedBox(height: 8),
                // Timestamps + progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(elapsed),
                      style: GoogleFonts.outfit(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 10,
                            ),
                            trackHeight: 2,
                            activeTrackColor: AppTheme.primary,
                            inactiveTrackColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            thumbColor: Colors.white,
                            overlayColor: AppTheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Slider(
                            value: progressValue,
                            onChanged: onProgressChanged,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      formatDuration(reel.duration),
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 12,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white70, size: size),
    );
  }
}