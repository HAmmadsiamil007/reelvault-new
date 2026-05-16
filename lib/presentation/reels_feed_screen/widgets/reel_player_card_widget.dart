import 'package:flutter/material.dart';
import '../../../widgets/custom_image_widget.dart';
import '../reels_feed_screen.dart';

class ReelModel {
  final String thumbnailUrl;
  final String thumbnailSemanticLabel;

  const ReelModel({
    required this.thumbnailUrl,
    required this.thumbnailSemanticLabel,
  });
}

class ReelPlayerCardWidget extends StatelessWidget {
  final ReelModel reel;
  final bool isPlaying;
  final bool isTablet;

  const ReelPlayerCardWidget({
    super.key,
    required this.reel,
    required this.isPlaying,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // TODO: Replace with BetterPlayerController for production video playback
    // BetterPlayerController(BetterPlayerConfiguration(autoPlay: true, looping: true, fit: BoxFit.cover),
    //   betterPlayerDataSource: BetterPlayerDataSource.file(reel.path))

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video thumbnail (production: replace with BetterPlayer widget)
        CustomImageWidget(
          imageUrl: reel.thumbnailUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          semanticLabel: reel.thumbnailSemanticLabel,
        ),
        // Dark vignette overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
              stops: const [0.0, 0.3, 0.5, 1.0],
            ),
          ),
        ),
        // Play indicator (subtle)
        if (!isPlaying) Container(color: Colors.black.withValues(alpha: 0.35)),
        // Gesture zone indicators (visible only during hold)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: size.width * 0.3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}