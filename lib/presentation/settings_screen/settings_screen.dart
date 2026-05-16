import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoRescan = true;
  bool _includeSubfolders = true;
  bool _shuffleReels = true;
  bool _deleteConfirmation = true;
  bool _autoPlay = true;
  bool _loopVideos = true;
  bool _holdFor2x = true;
  bool _gestureHaptics = true;

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(folderPathsProvider);
    final videosState = ref.watch(videosProvider);
    final likes = ref.watch(likesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppTheme.backgroundDark,
                pinned: true,
                title: Text(
                  'Settings',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('STORAGE'),
                      _buildFolderSection(folders, videosState),
                      const SizedBox(height: 24),
                      _buildSectionHeader('PLAYBACK'),
                      _buildPlaybackSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('LIBRARY'),
                      _buildLibraryStats(videosState, likes),
                      const SizedBox(height: 24),
                      _buildSectionHeader('ABOUT'),
                      _buildAboutSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(child: AppNavigation(currentIndex: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildFolderSection(List<String> folders, VideosState videosState) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Folder list
          ...folders.asMap().entries.map((entry) {
            final path = entry.value;
            final name = path.split('/').last;
            final count = videosState.videos
                .where((v) => v.folderPath == path || v.path.startsWith(path))
                .length;
            return _buildFolderTile(
              path,
              name,
              count,
              entry.key == folders.length - 1,
            );
          }),
          // Add folder button
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.folderSelectionScreen),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Add Folder',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildToggleTile(
            'Auto Rescan on Open',
            _autoRescan,
            (v) => setState(() => _autoRescan = v),
          ),
          _buildToggleTile(
            'Include Subfolders',
            _includeSubfolders,
            (v) => setState(() => _includeSubfolders = v),
          ),
          _buildToggleTile(
            'Shuffle Reels',
            _shuffleReels,
            (v) => setState(() => _shuffleReels = v),
          ),
          _buildToggleTile(
            'Delete Confirmation',
            _deleteConfirmation,
            (v) => setState(() => _deleteConfirmation = v),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTile(String path, String name, int count, bool isLast) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.folder_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count videos',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await ref.read(folderPathsProvider.notifier).removeFolder(path);
              final allFolders = ref.read(folderPathsProvider);
              await ref.read(videosProvider.notifier).scanFolders(allFolders);
            },
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white38,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildToggleTile(
            'Auto Play',
            _autoPlay,
            (v) => setState(() => _autoPlay = v),
          ),
          _buildToggleTile(
            'Loop Videos',
            _loopVideos,
            (v) => setState(() => _loopVideos = v),
          ),
          _buildToggleTile(
            'Hold for 2× Speed',
            _holdFor2x,
            (v) => setState(() => _holdFor2x = v),
          ),
          _buildToggleTile(
            'Gesture Haptics',
            _gestureHaptics,
            (v) => setState(() => _gestureHaptics = v),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryStats(VideosState videosState, Set<String> likes) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildStatTile(
            'Total Reels',
            '${videosState.videos.length}',
            Icons.video_library_rounded,
          ),
          _buildStatTile(
            'Liked Reels',
            '${likes.length}',
            Icons.favorite_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoTile('Version', '1.0.0', isLast: false),
          _buildInfoTile('Platform', 'Android', isLast: true),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
