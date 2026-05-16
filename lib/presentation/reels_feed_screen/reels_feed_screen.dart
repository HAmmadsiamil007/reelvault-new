import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../core/providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';

class ReelsFeedScreen extends ConsumerStatefulWidget {
  const ReelsFeedScreen({super.key});

  @override
  ConsumerState<ReelsFeedScreen> createState() => _ReelsFeedScreenState();
}

class _ReelsFeedScreenState extends ConsumerState<ReelsFeedScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _likeAnimController;
  late Animation<double> _likeScale;
  late Animation<double> _likeOpacity;

  int _currentIndex = 0;
  bool _showLikeAnimation = false;
  bool _showDeleteConfirm = false;
  bool _isHolding2x = false;
  bool _isPaused = false;

  // Video player pool: keep max 3 controllers
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _likeScale =
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: 1.3),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.3, end: 1.0),
            weight: 20,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.0),
            weight: 20,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            weight: 20,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _likeAnimController,
            curve: Curves.easeOutCubic,
          ),
        );
    _likeOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_likeAnimController);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initControllerAt(0);
    });
  }

  @override
  void dispose() {
    _disposeAllControllers();
    _pageController.dispose();
    _likeAnimController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _disposeAllControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  Future<void> _initControllerAt(int index) async {
    if (kIsWeb) return;
    final videos = ref.read(videosProvider).videos;
    if (index < 0 || index >= videos.length) return;
    if (_controllers.containsKey(index)) return;

    final video = videos[index];
    final file = File(video.path);
    if (!await file.exists()) return;

    final controller = VideoPlayerController.file(file);
    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(1.0);
      if (!mounted) {
        controller.dispose();
        return;
      }
      _controllers[index] = controller;
      if (index == _currentIndex && !_isPaused) {
        controller.play();
      }
      if (mounted) setState(() {});
    } catch (_) {
      controller.dispose();
    }
  }

  void _disposeControllersExcept(int current) {
    final toDispose = _controllers.keys
        .where((k) => (k - current).abs() > 1)
        .toList();
    for (final k in toDispose) {
      _controllers[k]?.dispose();
      _controllers.remove(k);
    }
  }

  void _onPageChanged(int index) {
    // Pause old
    _controllers[_currentIndex]?.pause();

    setState(() {
      _currentIndex = index;
      _isPaused = false;
      _isHolding2x = false;
    });

    // Play new
    final c = _controllers[index];
    if (c != null && c.value.isInitialized) {
      c.setPlaybackSpeed(1.0);
      c.play();
    } else {
      _initControllerAt(index);
    }

    // Preload next
    _initControllerAt(index + 1);
    _initControllerAt(index - 1);

    // Dispose far controllers
    _disposeControllersExcept(index);
  }

  void _onDoubleTap() {
    final videos = ref.read(videosProvider).videos;
    if (_currentIndex >= videos.length) return;
    final video = videos[_currentIndex];
    ref.read(likesProvider.notifier).toggleLike(video.id);
    // Always show heart on double tap
    setState(() => _showLikeAnimation = true);
    _likeAnimController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showLikeAnimation = false);
    });
  }

  void _onHoldStart(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final x = details.globalPosition.dx;
    final zone = x / screenWidth;
    if (zone < 0.3 || zone > 0.7) {
      setState(() => _isHolding2x = true);
      _controllers[_currentIndex]?.setPlaybackSpeed(2.0);
    } else {
      setState(() => _isPaused = true);
      _controllers[_currentIndex]?.pause();
    }
  }

  void _onHoldEnd(TapUpDetails _) => _releaseHold();
  void _onHoldCancel() => _releaseHold();

  void _releaseHold() {
    if (_isHolding2x) {
      _controllers[_currentIndex]?.setPlaybackSpeed(1.0);
    } else if (_isPaused) {
      _controllers[_currentIndex]?.play();
    }
    setState(() {
      _isHolding2x = false;
      _isPaused = false;
    });
  }

  void _togglePlayPause() {
    final c = _controllers[_currentIndex];
    if (c == null) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _isPaused = true;
      } else {
        c.play();
        _isPaused = false;
      }
    });
  }

  void _toggleLike() {
    final videos = ref.read(videosProvider).videos;
    if (_currentIndex >= videos.length) return;
    ref.read(likesProvider.notifier).toggleLike(videos[_currentIndex].id);
  }

  Future<void> _confirmDelete() async {
    final videos = ref.read(videosProvider).videos;
    if (_currentIndex >= videos.length) return;
    final video = videos[_currentIndex];

    setState(() => _showDeleteConfirm = false);

    final success = await ref
        .read(videosProvider.notifier)
        .deleteVideoFromDevice(video.id);

    if (mounted && success) {
      final newVideos = ref.read(videosProvider).videos;
      if (newVideos.isEmpty) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.folderSelectionScreen,
          (route) => false,
        );
        return;
      }
      final newIndex = _currentIndex.clamp(0, newVideos.length - 1) as int;
      setState(() => _currentIndex = newIndex);
      _initControllerAt(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final videosState = ref.watch(videosProvider);
    final videos = videosState.videos;
    final likes = ref.watch(likesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Stack(
        children: [
          // Main feed
          videos.isEmpty ? _buildEmptyState() : _buildFeed(videos, likes),

          // Like animation
          if (_showLikeAnimation)
            Center(
              child: AnimatedBuilder(
                animation: _likeAnimController,
                builder: (_, __) => Opacity(
                  opacity: _likeOpacity.value,
                  child: Transform.scale(
                    scale: _likeScale.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppTheme.primary,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Delete confirm
          if (_showDeleteConfirm) _buildDeleteConfirm(),

          // 2x speed badge
          if (_isHolding2x)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '2× Speed',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ReelVault',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        if (videos.isNotEmpty)
                          Text(
                            '${_currentIndex + 1}/${videos.length}',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.settingsScreen,
                          ),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(child: AppNavigation(currentIndex: 0)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed(List videos, Set<String> likes) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: _onPageChanged,
      physics: const PageScrollPhysics(),
      itemBuilder: (context, index) {
        final video = videos[index];
        final isLiked = likes.contains(video.id);
        final controller = _controllers[index];
        return _buildReelItem(video, controller, isLiked, index);
      },
    );
  }

  Widget _buildReelItem(
    dynamic video,
    VideoPlayerController? controller,
    bool isLiked,
    int index,
  ) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onTapDown: _onHoldStart,
      onTapUp: _onHoldEnd,
      onTapCancel: _onHoldCancel,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or placeholder
          _buildVideoLayer(controller),

          // Pause overlay
          if (_isPaused && index == _currentIndex)
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Right side controls
          Positioned(
            right: 12,
            bottom: 120,
            child: _buildRightControls(video, isLiked),
          ),

          // Bottom info
          Positioned(
            left: 16,
            right: 80,
            bottom: 80,
            child: _buildBottomInfo(video, controller),
          ),

          // Progress bar
          if (controller != null && controller.value.isInitialized)
            Positioned(
              left: 0,
              right: 0,
              bottom: 72,
              child: _buildProgressBar(controller),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer(VideoPlayerController? controller) {
    if (kIsWeb) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_android_rounded,
                color: Colors.white38,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Install APK on Android\nto play your local videos',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppTheme.primary.withValues(alpha: 0.6),
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildRightControls(dynamic video, bool isLiked) {
    return Column(
      children: [
        _controlButton(
          icon: isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isLiked ? AppTheme.primary : Colors.white,
          onTap: _toggleLike,
        ),
        const SizedBox(height: 20),
        _controlButton(
          icon: Icons.delete_outline_rounded,
          color: AppTheme.errorColor,
          onTap: () => setState(() => _showDeleteConfirm = true),
        ),
        const SizedBox(height: 20),
        _controlButton(
          icon: Icons.folder_open_rounded,
          color: Colors.white70,
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.folderSelectionScreen),
        ),
        const SizedBox(height: 20),
        _controlButton(
          icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          color: Colors.white70,
          onTap: _togglePlayPause,
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildBottomInfo(dynamic video, VideoPlayerController? controller) {
    final duration = controller?.value.duration ?? Duration.zero;
    final durationStr = _formatDuration(duration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          video.fileName,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.folder_rounded, color: Colors.white54, size: 13),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                video.folderName,
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              durationStr,
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(VideoPlayerController controller) {
    return VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: AppTheme.primary,
        bufferedColor: Colors.white24,
        backgroundColor: Colors.white12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            color: Colors.white24,
            size: 72,
          ),
          const SizedBox(height: 20),
          Text(
            'No videos found',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add folders with your videos\nto start watching',
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 14,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.folderSelectionScreen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryMagenta],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Add Folders',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteConfirm() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.errorColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorColor.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: AppTheme.errorColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Reel?',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will permanently delete the file from your device storage.',
                style: GoogleFonts.outfit(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showDeleteConfirm = false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _confirmDelete,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Delete',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}