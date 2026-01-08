import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/update_service.dart';

/// 更新设置状态
class UpdateSettings {
  final bool autoCheck;
  final bool includePrerelease;
  final DateTime? lastCheckTime;

  UpdateSettings({
    this.autoCheck = true,
    this.includePrerelease = false,
    this.lastCheckTime,
  });

  UpdateSettings copyWith({
    bool? autoCheck,
    bool? includePrerelease,
    DateTime? lastCheckTime,
  }) {
    return UpdateSettings(
      autoCheck: autoCheck ?? this.autoCheck,
      includePrerelease: includePrerelease ?? this.includePrerelease,
      lastCheckTime: lastCheckTime ?? this.lastCheckTime,
    );
  }
}

/// 更新设置 Provider
class UpdateSettingsNotifier extends StateNotifier<UpdateSettings> {
  static const String _boxName = 'settings';
  static const String _autoCheckKey = 'auto_check_update';
  static const String _includePrereleaseKey = 'include_prerelease';
  static const String _lastCheckTimeKey = 'last_check_time';

  UpdateSettingsNotifier() : super(UpdateSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox(_boxName);
    state = UpdateSettings(
      autoCheck: box.get(_autoCheckKey, defaultValue: true),
      includePrerelease: box.get(_includePrereleaseKey, defaultValue: false),
      lastCheckTime: box.get(_lastCheckTimeKey) != null
          ? DateTime.fromMillisecondsSinceEpoch(box.get(_lastCheckTimeKey))
          : null,
    );
  }

  Future<void> setAutoCheck(bool value) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_autoCheckKey, value);
    state = state.copyWith(autoCheck: value);
  }

  Future<void> setIncludePrerelease(bool value) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_includePrereleaseKey, value);
    state = state.copyWith(includePrerelease: value);
  }

  Future<void> updateLastCheckTime() async {
    final now = DateTime.now();
    final box = await Hive.openBox(_boxName);
    await box.put(_lastCheckTimeKey, now.millisecondsSinceEpoch);
    state = state.copyWith(lastCheckTime: now);
  }
}

final updateSettingsProvider =
    StateNotifierProvider<UpdateSettingsNotifier, UpdateSettings>((ref) {
  return UpdateSettingsNotifier();
});

/// 更新检查状态
class UpdateCheckState {
  final bool isChecking;
  final UpdateInfo? updateInfo;
  final String? error;

  UpdateCheckState({
    this.isChecking = false,
    this.updateInfo,
    this.error,
  });

  UpdateCheckState copyWith({
    bool? isChecking,
    UpdateInfo? updateInfo,
    String? error,
  }) {
    return UpdateCheckState(
      isChecking: isChecking ?? this.isChecking,
      updateInfo: updateInfo,
      error: error,
    );
  }
}

/// 更新检查 Provider
class UpdateCheckNotifier extends StateNotifier<UpdateCheckState> {
  final UpdateService _updateService = UpdateService();

  UpdateCheckNotifier() : super(UpdateCheckState());

  Future<void> checkForUpdate({bool includePrerelease = false}) async {
    state = UpdateCheckState(isChecking: true);

    try {
      final updateInfo = await _updateService.checkForUpdate(
        includePrerelease: includePrerelease,
      );
      state = UpdateCheckState(updateInfo: updateInfo);
    } catch (e) {
      state = UpdateCheckState(error: e.toString());
    }
  }

  Future<void> openDownload() async {
    if (state.updateInfo != null) {
      await _updateService.openDownloadPage(state.updateInfo!);
    }
  }

  void clearUpdate() {
    state = UpdateCheckState();
  }
}

final updateCheckProvider =
    StateNotifierProvider<UpdateCheckNotifier, UpdateCheckState>((ref) {
  return UpdateCheckNotifier();
});
