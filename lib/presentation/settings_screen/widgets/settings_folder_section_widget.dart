import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsFolderSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> folders;
  final bool includeSubfolders;
  final bool autoRescan;
  final bool shuffleReels;
  final bool deleteConfirmation;
  final ValueChanged<bool> onIncludeSubfoldersChanged;
  final ValueChanged<bool> onAutoRescanChanged;
  final ValueChanged<bool> onShuffleReelsChanged;
  final ValueChanged<bool> onDeleteConfirmationChanged;
  final VoidCallback onAddFolder;
  final ValueChanged<String> onRemoveFolder;
  final ValueChanged<String> onRescanFolder;

  const SettingsFolderSectionWidget({
    super.key,
    required this.folders,
    required this.includeSubfolders,
    required this.autoRescan,
    required this.shuffleReels,
    required this.deleteConfirmation,
    required this.onIncludeSubfoldersChanged,
    required this.onAutoRescanChanged,
    required this.onShuffleReelsChanged,
    required this.onDeleteConfirmationChanged,
    required this.onAddFolder,
    required this.onRemoveFolder,
    required this.onRescanFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'STORAGE'),
        const SizedBox(height: 12),
        _GlassCard(
          child: Column(
            children: [
              // Selected folders header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'folder_open',
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Selected Folders',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${folders.length} folders',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Folder list
              ...folders.map(
                (folder) => _FolderRow(
                  folder: folder,
                  onRemove: () => onRemoveFolder(folder['id'] as String),
                  onRescan: () => onRescanFolder(folder['id'] as String),
                ),
              ),
              // Add folder button
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: onAddFolder,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.primary.withValues(alpha: 0.06),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'add',
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Folder',
                          style: GoogleFonts.outfit(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _GlassCard(
          child: Column(
            children: [
              _ToggleRow(
                iconName: 'folder',
                iconColor: const Color(0xFF4FC3F7),
                label: 'Include Subfolders',
                subtitle: 'Scan nested folders recursively',
                value: includeSubfolders,
                onChanged: onIncludeSubfoldersChanged,
              ),
              _Divider(),
              _ToggleRow(
                iconName: 'refresh',
                iconColor: AppTheme.success,
                label: 'Auto Rescan',
                subtitle: 'Refresh library on app open',
                value: autoRescan,
                onChanged: onAutoRescanChanged,
              ),
              _Divider(),
              _ToggleRow(
                iconName: 'shuffle',
                iconColor: AppTheme.primaryMagenta,
                label: 'Shuffle Reels',
                subtitle: 'Random order every session',
                value: shuffleReels,
                onChanged: onShuffleReelsChanged,
              ),
              _Divider(),
              _ToggleRow(
                iconName: 'delete',
                iconColor: AppTheme.errorColor,
                label: 'Delete Confirmation',
                subtitle: 'Show dialog before deleting',
                value: deleteConfirmation,
                onChanged: onDeleteConfirmationChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FolderRow extends StatelessWidget {
  final Map<String, dynamic> folder;
  final VoidCallback onRemove;
  final VoidCallback onRescan;

  const _FolderRow({
    required this.folder,
    required this.onRemove,
    required this.onRescan,
  });

  String _formatSize(int mb) {
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '$mb MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('📁', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder['name'] as String,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${folder['reelCount']} videos · ${_formatSize(folder['sizeMB'] as int)}',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            folder['path'] as String,
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Last scanned: ${folder['lastScanned']}',
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRescan,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Rescan',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Remove',
                    style: GoogleFonts.outfit(
                      color: AppTheme.errorColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String iconName;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
          child: child,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}
