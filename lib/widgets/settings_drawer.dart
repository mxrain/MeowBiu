import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/about_screen.dart';

class SettingsDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const SettingsDrawer({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      elevation: 1.0,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        // 抽屉头部
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '设置',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (onClose != null) {
                    onClose!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),

        const Divider(),

        // 设置项
        _buildSettingItem(
          context,
          icon: Icons.color_lens_outlined,
          title: '主题设置',
          description: '自定义应用主题颜色和深色模式',
          onTap: () {
            _handleItemTap(context, '/theme-settings');
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.volume_up_outlined,
          title: '音频设置',
          description: '调整音量和播放选项',
          onTap: () {
            _handleItemTap(context, '/audio-settings');
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.cloud_outlined,
          title: '存储与缓存',
          description: '管理音频缓存和存储空间',
          onTap: () {
            _handleItemTap(context, '/storage-settings');
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.notifications_outlined,
          title: '通知设置',
          description: '管理应用通知和提醒',
          onTap: () {
            _handleItemTap(context, '/notification-settings');
          },
        ),

        const Divider(),

        _buildSettingItem(
          context,
          icon: Icons.help_outline,
          title: '帮助与反馈',
          description: '获取帮助或提交问题反馈',
          onTap: () {
            _handleItemTap(context, '/help');
          },
        ),
        
        // 关于入口 - 放在设置列表的最后一项
        _buildSettingItem(
          context,
          icon: Icons.info_rounded,
          title: '关于',
          description: '版本、意见反馈、自动更新',
          onTap: () {
            _handleItemTap(context, '/about');
          },
        ),
      ],
    );
  }

  // 创建单个设置项
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: colorScheme.primary,
          size: 28,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
      ),
    );
  }

  // 处理设置项点击
  void _handleItemTap(BuildContext context, String route) {
    // 关闭抽屉
    Navigator.pop(context);
    
    // 根据路由导航到相应页面
    if (route == '/about') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutScreen()),
      );
    } else {
      // 其他路由暂时只显示一个SnackBar提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导航到: $route'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
} 