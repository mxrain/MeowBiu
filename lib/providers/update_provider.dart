import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/release.dart';
import '../services/preference_service.dart';
import '../services/update_service.dart';

/// 更新状态数据类
class UpdateState {
  final bool isCheckingUpdate;
  final bool isUpdating;
  final bool autoUpdateEnabled;
  final UpdateChannel updateChannel;
  final DateTime? lastCheckTime;
  final Release? latestRelease;
  final String? error;

  const UpdateState({
    this.isCheckingUpdate = false,
    this.isUpdating = false,
    this.autoUpdateEnabled = true,
    this.updateChannel = UpdateChannel.stable,
    this.lastCheckTime,
    this.latestRelease,
    this.error,
  });

  /// 创建新状态
  UpdateState copyWith({
    bool? isCheckingUpdate,
    bool? isUpdating,
    bool? autoUpdateEnabled,
    UpdateChannel? updateChannel,
    DateTime? lastCheckTime,
    Release? latestRelease,
    String? error,
  }) {
    return UpdateState(
      isCheckingUpdate: isCheckingUpdate ?? this.isCheckingUpdate,
      isUpdating: isUpdating ?? this.isUpdating,
      autoUpdateEnabled: autoUpdateEnabled ?? this.autoUpdateEnabled,
      updateChannel: updateChannel ?? this.updateChannel,
      lastCheckTime: lastCheckTime ?? this.lastCheckTime,
      latestRelease: latestRelease ?? this.latestRelease,
      error: error,
    );
  }
}

/// 更新服务提供者
class UpdateNotifier extends StateNotifier<UpdateState> {
  final PreferenceService _prefService;

  UpdateNotifier(this._prefService) : super(const UpdateState()) {
    _loadPreferences();
  }

  /// 加载偏好设置
  Future<void> _loadPreferences() async {
    await _prefService.init();
    state = state.copyWith(
      autoUpdateEnabled: _prefService.isAutoUpdateEnabled(),
      updateChannel: _prefService.getUpdateChannel(),
      lastCheckTime: _prefService.getLastCheckUpdateTime(),
    );
  }

  /// 设置自动更新状态
  Future<void> setAutoUpdateEnabled(bool enabled) async {
    await _prefService.setAutoUpdateEnabled(enabled);
    state = state.copyWith(autoUpdateEnabled: enabled);
  }

  /// 设置更新频道
  Future<void> setUpdateChannel(UpdateChannel channel) async {
    await _prefService.setUpdateChannel(channel);
    state = state.copyWith(updateChannel: channel);
  }

  /// 检查更新
  Future<void> checkForUpdate({bool showSnackbar = true, BuildContext? context}) async {
    if (state.isCheckingUpdate) return;
    
    state = state.copyWith(
      isCheckingUpdate: true,
      error: null,
    );
    
    try {
      final release = await UpdateService.checkForUpdate();
      
      // 更新上次检查时间
      final lastCheckTime = DateTime.now();
      await _prefService.setLastCheckUpdateTime(lastCheckTime);
      
      state = state.copyWith(
        isCheckingUpdate: false,
        lastCheckTime: lastCheckTime,
        latestRelease: release,
      );
      
      if (release == null && showSnackbar && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前已是最新版本')),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isCheckingUpdate: false,
        error: e.toString(),
      );
      
      if (showSnackbar && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('检查更新失败: ${e.toString()}')),
        );
      }
    }
  }

  /// 清除最新发布信息
  void clearLatestRelease() {
    state = state.copyWith(latestRelease: null);
  }
}

/// 创建Provider
final updateStateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier(PreferenceService());
}); 