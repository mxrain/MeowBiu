import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart' as home;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化存储服务（内部已包含Hive初始化）
  final storageService = StorageService();
  await storageService.init();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '喵王语录',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const home.HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
