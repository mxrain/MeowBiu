import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cat_sound.dart';
import '../models/sound_category.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

// 当前选中的分类提供者
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 分类列表提供者
final categoriesProvider = FutureProvider<List<SoundCategory>>((ref) async {
  // 监听soundManagerProvider的状态变化，以便在操作完成后刷新数据
  ref.watch(soundManagerProvider);
  
  final storageService = StorageService();
  await storageService.init();
  return storageService.getAllCategories();
});

// 特定分类下的猫声列表提供者
final categorySoundsProvider = FutureProvider.family<List<CatSound>, String?>((ref, categoryId) async {
  if (categoryId == null) return [];
  
  // 监听soundManagerProvider的状态变化，以便在操作完成后刷新数据
  ref.watch(soundManagerProvider);
  
  final storageService = StorageService();
  await storageService.init();
  return storageService.getSoundsByCategory(categoryId);
});

// 当前播放状态提供者
class PlaybackState {
  final String? playingId;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  
  PlaybackState({
    this.playingId,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
  });
  
  PlaybackState copyWith({
    String? playingId,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
  }) {
    return PlaybackState(
      playingId: playingId ?? this.playingId,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

// 播放状态提供者
class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(PlaybackState());
  
  final AudioService _audioService = AudioService();
  
  // 播放音频
  Future<void> playSound(CatSound sound) async {
    state = PlaybackState(playingId: sound.id, isPlaying: true);
    await _audioService.safePlay(sound);
    
    // 监听播放进度
    _audioService.getPositionStream(sound.id).listen((position) {
      state = state.copyWith(position: position);
    });
    
    // 监听总时长
    _audioService.getDurationStream(sound.id).listen((duration) {
      state = state.copyWith(duration: duration);
    });
  }
  
  // 停止播放
  Future<void> stopSound() async {
    await _audioService.stopCurrentSound();
    state = PlaybackState();
  }
  
  // 清理资源
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  return PlaybackNotifier();
});

// 音频管理操作提供者
class SoundManagerNotifier extends StateNotifier<AsyncValue<void>> {
  SoundManagerNotifier() : super(const AsyncValue.data(null));
  
  final StorageService _storageService = StorageService();
  final AudioService _audioService = AudioService();
  
  // 添加猫声
  Future<CatSound?> addSound({
    required String name,
    required String audioPath,
    required AudioSourceType sourceType,
    String? categoryId,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _storageService.init();
      final sound = await _storageService.addSound(
        name: name,
        audioPath: audioPath,
        sourceType: sourceType,
        categoryId: categoryId,
      );
      
      state = const AsyncValue.data(null);
      return sound;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
  
  // 更新猫声
  Future<void> updateSound(CatSound sound) async {
    state = const AsyncValue.loading();
    
    try {
      await _storageService.init();
      await _storageService.updateSound(sound);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // 删除猫声
  Future<void> deleteSound(String soundId) async {
    state = const AsyncValue.loading();
    
    try {
      await _storageService.init();
      final sound = _storageService.getSound(soundId);
      
      if (sound != null) {
        // 清理音频缓存
        await _audioService.clearCache(sound);
        // 从存储中删除
        await _storageService.deleteSound(soundId);
      }
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // 添加分类
  Future<SoundCategory?> addCategory(String name) async {
    state = const AsyncValue.loading();
    
    try {
      await _storageService.init();
      final category = await _storageService.addCategory(name);
      state = const AsyncValue.data(null);
      return category;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
  
  // 更新分类
  Future<void> updateCategory(SoundCategory category) async {
    state = const AsyncValue.loading();
    
    try {
      await _storageService.init();
      await _storageService.updateCategory(category);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // 删除分类
  Future<void> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    
    try {
      await _storageService.init();
      await _storageService.deleteCategory(categoryId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // 重新排序分类
  Future<void> reorderCategories(List<SoundCategory> newOrder) async {
    state = const AsyncValue.loading();
    
    try {
      await _storageService.init();
      await _storageService.reorderCategories(newOrder);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // 清理所有缓存
  Future<bool> clearAllCache() async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _audioService.clearAllCache();
      state = const AsyncValue.data(null);
      return result;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
  
  // 清理单个猫声缓存
  Future<bool> clearSoundCache(CatSound sound) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _audioService.clearCache(sound);
      state = const AsyncValue.data(null);
      return result;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final soundManagerProvider = StateNotifierProvider<SoundManagerNotifier, AsyncValue<void>>((ref) {
  return SoundManagerNotifier();
}); 