import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 更新不可用对话框，显示给应用商店版本用户
class UpdateUnavailableDialog extends StatelessWidget {
  const UpdateUnavailableDialog({Key? key}) : super(key: key);

  Future<void> _openGitHubPage() async {
    const url = 'https://github.com/mxrain/miaowang/releases';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AlertDialog(
      title: const Text('自动更新不可用'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('您使用的是应用商店版本，自动更新功能不可用。'),
          const SizedBox(height: 12),
          const Text('应用商店版本只能通过各自的应用商店渠道更新。'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '获取GitHub版本',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '如果您想使用自动更新功能，可以下载并安装GitHub版本。'
                  'GitHub版本支持自动更新，并且可以获取最新发布的版本。',
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _openGitHubPage,
                    icon: const Icon(Icons.download),
                    label: const Text('获取GitHub版本'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
} 