import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/preference_service.dart';
import 'services/update_service.dart';
import 'widgets/update_dialog.dart';
import 'models/release.dart';
import 'providers/locale_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 初始化偏好设置服务
    final prefService = PreferenceService();
    await prefService.init();
    
    // 检查是否需要自动更新
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      // 获取设置
      final prefService = PreferenceService();
      await prefService.init();
      
      // 只有在启用自动更新的情况下才检查更新
      if (!prefService.isAutoUpdateEnabled()) {
        return;
      }
      
      // 检查是否支持自动更新
      final isSupported = await prefService.isAutoUpdateSupported();
      if (!isSupported) {
        return;
      }
      
      // 检查网络
      final isNetworkAvailable = await prefService.isNetworkAvailableForDownload();
      if (!isNetworkAvailable) {
        return;
      }
      
      // 检查更新
      final release = await UpdateService.checkForUpdate();
      if (release != null) {
        // 延迟一会儿再显示更新对话框，让应用先完成初始化
        Future.delayed(const Duration(seconds: 2), () {
          _showUpdateDialog(release);
        });
      }
    } catch (e) {
      debugPrint('自动检查更新失败: $e');
    }
  }

  void _showUpdateDialog(Release release) {
    // 确保已经有了一个有效的BuildContext
    if (!mounted) return;
    
    // 显示更新对话框
    showDialog(
      context: context,
      builder: (context) => UpdateDialog(release: release),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 监听语言设置的变化
    final currentLocale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: '喵喵语录',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      // 国际化支持
      locale: Locale(currentLocale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
