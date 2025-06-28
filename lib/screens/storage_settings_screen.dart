import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sound_provider.dart';

class StorageSettingsScreen extends ConsumerWidget {
  const StorageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('存储与缓存'),
      ),
      body: ListView(
        children: [
          // 缓存管理部分
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              '缓存管理',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 清理所有缓存
          ListTile(
            leading: Icon(
              Icons.cleaning_services_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('清理所有缓存'),
            subtitle: const Text('删除所有已下载的网络音频缓存'),
            onTap: () => _showClearCacheDialog(context, ref),
          ),
          
          const Divider(),
          
          // 存储信息部分
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              '存储信息',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // TODO: 显示存储统计信息
          const ListTile(
            leading: Icon(Icons.folder_outlined),
            title: Text('应用存储'),
            subtitle: Text('查看应用占用的存储空间'),
          ),
        ],
      ),
    );
  }

  // 显示清理缓存确认对话框
  Future<void> _showClearCacheDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理所有缓存'),
        content: const Text('确定要清理所有音频缓存吗？这将删除所有已下载的网络音频缓存文件，可能会影响离线播放。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清理'),
          ),
        ],
      ),
    );

    // 如果用户确认，执行清理操作
    if (confirmed == true) {
      final result = await ref.read(soundManagerProvider.notifier).clearAllCache();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ? '缓存清理成功' : '缓存清理失败')),
        );
      }
    }
  }
}