import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 存储语言设置的Key
const String _localePreferenceKey = 'language_code';

/// 语言设置提供者，提供当前选择的语言代码
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

/// 语言设置状态管理器
class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('zh') {
    // 初始化时加载保存的语言设置
    _loadSavedLocale();
  }

  /// 从SharedPreferences加载保存的语言设置
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localePreferenceKey);
    if (savedLocale != null) {
      state = savedLocale;
    }
  }

  /// 更改当前语言设置
  Future<void> changeLocale(String languageCode) async {
    // 保存到SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePreferenceKey, languageCode);
    
    // 更新状态
    state = languageCode;
  }
} 