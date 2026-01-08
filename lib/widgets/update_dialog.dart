import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/update_provider.dart';
import '../services/update_service.dart';

/// 更新提示对话框
class UpdateDialog extends ConsumerWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({Key? key, required this.updateInfo}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('发现新版本'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 版本信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'v${updateInfo.version}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (updateInfo.isPrerelease) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: const Text('预发布'),
                      backgroundColor: Colors.orange.shade100,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 更新日志
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              Text(
                '更新内容',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Text(
                    updateInfo.releaseNotes,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('稍后再说'),
        ),
        FilledButton.icon(
          onPressed: () {
            ref.read(updateCheckProvider.notifier).openDownload();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.download),
          label: const Text('立即更新'),
        ),
      ],
    );
  }

  /// 显示更新对话框
  static Future<void> show(BuildContext context, UpdateInfo updateInfo) {
    return showDialog(
      context: context,
      builder: (context) => UpdateDialog(updateInfo: updateInfo),
    );
  }
}

/// 检查更新的 Mixin，可在 StatefulWidget 中使用
mixin UpdateCheckMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _hasCheckedUpdate = false;

  @override
  void initState() {
    super.initState();
    // 延迟检查，避免影响启动性能
    Future.delayed(const Duration(seconds: 2), _checkUpdateOnStartup);
  }

  Future<void> _checkUpdateOnStartup() async {
    if (_hasCheckedUpdate) return;
    _hasCheckedUpdate = true;

    final settings = ref.read(updateSettingsProvider);
    if (!settings.autoCheck) return;

    // 检查是否需要检查更新（每天最多一次）
    if (settings.lastCheckTime != null) {
      final diff = DateTime.now().difference(settings.lastCheckTime!);
      if (diff.inHours < 24) return;
    }

    await ref.read(updateCheckProvider.notifier).checkForUpdate(
      includePrerelease: settings.includePrerelease,
    );
    await ref.read(updateSettingsProvider.notifier).updateLastCheckTime();

    final updateState = ref.read(updateCheckProvider);
    if (updateState.updateInfo != null && mounted) {
      UpdateDialog.show(context, updateState.updateInfo!);
    }
  }
}
