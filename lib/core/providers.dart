import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class VideoModel {
  final String id;
  final String path;
  final String fileName;
  final String folderName;
  final String folderPath;
  bool isLiked;
  bool isDeleted;

  VideoModel({
    required this.id,
    required this.path,
    required this.fileName,
    required this.folderName,
    required this.folderPath,
    this.isLiked = false,
    this.isDeleted = false,
  });

  VideoModel copyWith({bool? isLiked, bool? isDeleted}) {
    return VideoModel(
      id: id,
      path: path,
      fileName: fileName,
      folderName: folderName,
      folderPath: folderPath,
      isLiked: isLiked ?? this.isLiked,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class FolderInfo {
  final String path;
  final String name;
  int videoCount;

  FolderInfo({required this.path, required this.name, this.videoCount = 0});
}

// ─── SharedPreferences Provider ───────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

// ─── Folder Paths Provider ────────────────────────────────────────────────────

class FolderNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  static const _key = 'selected_folder_paths';

  FolderNotifier(this._prefs) : super([]) {
    _load();
  }

  void _load() {
    final saved = _prefs.getStringList(_key) ?? [];
    state = saved;
  }

  Future<void> addFolder(String path) async {
    if (!state.contains(path)) {
      final updated = [...state, path];
      state = updated;
      await _prefs.setStringList(_key, updated);
    }
  }

  Future<void> removeFolder(String path) async {
    final updated = state.where((p) => p != path).toList();
    state = updated;
    await _prefs.setStringList(_key, updated);
  }

  Future<void> clearAll() async {
    state = [];
    await _prefs.remove(_key);
  }
}

final folderPathsProvider = StateNotifierProvider<FolderNotifier, List<String>>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return FolderNotifier(prefs);
  },
);

// ─── Liked Videos Provider ────────────────────────────────────────────────────

class LikesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;
  static const _key = 'liked_video_ids';

  LikesNotifier(this._prefs) : super({}) {
    _load();
  }

  void _load() {
    final saved = _prefs.getStringList(_key) ?? [];
    state = saved.toSet();
  }

  Future<void> toggleLike(String id) async {
    final updated = Set<String>.from(state);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = updated;
    await _prefs.setStringList(_key, updated.toList());
  }

  bool isLiked(String id) => state.contains(id);
}

final likesProvider = StateNotifierProvider<LikesNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LikesNotifier(prefs);
});

// ─── Videos State ─────────────────────────────────────────────────────────────

class VideosState {
  final List<VideoModel> videos;
  final bool isScanning;
  final String scanStatus;
  final int scannedCount;

  const VideosState({
    this.videos = const [],
    this.isScanning = false,
    this.scanStatus = '',
    this.scannedCount = 0,
  });

  VideosState copyWith({
    List<VideoModel>? videos,
    bool? isScanning,
    String? scanStatus,
    int? scannedCount,
  }) {
    return VideosState(
      videos: videos ?? this.videos,
      isScanning: isScanning ?? this.isScanning,
      scanStatus: scanStatus ?? this.scanStatus,
      scannedCount: scannedCount ?? this.scannedCount,
    );
  }
}

class VideosNotifier extends StateNotifier<VideosState> {
  VideosNotifier() : super(const VideosState());

  Future<void> scanFolders(List<String> folderPaths) async {
    if (kIsWeb) return;
    state = state.copyWith(isScanning: true, scanStatus: 'Scanning folders...');

    final List<VideoModel> found = [];
    int count = 0;

    for (final folderPath in folderPaths) {
      final dir = Directory(folderPath);
      if (!await dir.exists()) continue;

      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            final lower = entity.path.toLowerCase();
            if (lower.endsWith('.mp4') ||
                lower.endsWith('.mov') ||
                lower.endsWith('.mkv') ||
                lower.endsWith('.webm') ||
                lower.endsWith('.3gp') ||
                lower.endsWith('.avi')) {
              count++;
              final fileName = entity.path.split('/').last;
              final parentPath = entity.parent.path;
              final folderName = parentPath.split('/').last;
              found.add(
                VideoModel(
                  id: '${entity.path}_$count',
                  path: entity.path,
                  fileName: fileName,
                  folderName: folderName,
                  folderPath: parentPath,
                ),
              );
              if (count % 10 == 0) {
                state = state.copyWith(
                  scanStatus: 'Found $count videos...',
                  scannedCount: count,
                );
              }
            }
          }
        }
      } catch (_) {}
    }

    // Shuffle for random playback
    found.shuffle(Random());

    state = state.copyWith(
      videos: found,
      isScanning: false,
      scanStatus: 'Found ${found.length} videos',
      scannedCount: found.length,
    );
  }

  void removeVideo(String id) {
    final updated = state.videos.where((v) => v.id != id).toList();
    state = state.copyWith(videos: updated);
  }

  Future<bool> deleteVideoFromDevice(String id) async {
    if (kIsWeb) return false;
    final video = state.videos.firstWhere(
      (v) => v.id == id,
      orElse: () => VideoModel(
        id: '',
        path: '',
        fileName: '',
        folderName: '',
        folderPath: '',
      ),
    );
    if (video.id.isEmpty) return false;

    try {
      final file = File(video.path);
      if (await file.exists()) {
        await file.delete();
      }
      removeVideo(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final videosProvider = StateNotifierProvider<VideosNotifier, VideosState>((
  ref,
) {
  return VideosNotifier();
});

// ─── App Initialization State ─────────────────────────────────────────────────

class AppInitState {
  final bool isInitialized;
  final bool hasPermission;
  final bool hasFolders;
  final String status;
  final double progress;

  const AppInitState({
    this.isInitialized = false,
    this.hasPermission = false,
    this.hasFolders = false,
    this.status = 'Initializing...',
    this.progress = 0.0,
  });

  AppInitState copyWith({
    bool? isInitialized,
    bool? hasPermission,
    bool? hasFolders,
    String? status,
    double? progress,
  }) {
    return AppInitState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      hasFolders: hasFolders ?? this.hasFolders,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}

final appInitProvider = StateNotifierProvider<AppInitNotifier, AppInitState>((
  ref,
) {
  return AppInitNotifier(ref);
});

class AppInitNotifier extends StateNotifier<AppInitState> {
  final Ref _ref;

  AppInitNotifier(this._ref) : super(const AppInitState());

  Future<void> initialize() async {
    state = state.copyWith(status: 'Loading preferences...', progress: 0.2);
    await Future.delayed(const Duration(milliseconds: 300));

    if (kIsWeb) {
      state = state.copyWith(
        isInitialized: true,
        hasPermission: false,
        hasFolders: false,
        status: 'Ready',
        progress: 1.0,
      );
      return;
    }

    state = state.copyWith(status: 'Checking permissions...', progress: 0.4);
    await Future.delayed(const Duration(milliseconds: 200));

    final folders = _ref.read(folderPathsProvider);
    state = state.copyWith(
      status: 'Loading saved folders...',
      progress: 0.6,
      hasFolders: folders.isNotEmpty,
    );
    await Future.delayed(const Duration(milliseconds: 200));

    if (folders.isNotEmpty) {
      state = state.copyWith(status: 'Scanning videos...', progress: 0.8);
      await _ref.read(videosProvider.notifier).scanFolders(folders);
    }

    state = state.copyWith(
      status: 'Ready!',
      progress: 1.0,
      isInitialized: true,
      hasFolders: folders.isNotEmpty,
    );
  }
}