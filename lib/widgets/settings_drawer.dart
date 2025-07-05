import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/generated/app_localizations.dart';
import '../screens/about_screen.dart';
import '../screens/language_settings_screen.dart';
import '../screens/storage_settings_screen.dart';

class SettingsDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const SettingsDrawer({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
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
                localizations.settings,
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
          title: localizations.themeSettings,
          description: localizations.themeSettingsDescription,
          onTap: () {
            _handleItemTap(context, '/theme-settings');
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.volume_up_outlined,
          title: localizations.audioSettings,
          description: localizations.audioSettingsDescription,
          onTap: () {
            _handleItemTap(context, '/audio-settings');
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.language_outlined,
          title: localizations.languageSettings,
          description: localizations.languageSettingsDescription,
          onTap: () {
            _handleItemTap(context, '/language-settings');
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.cloud_outlined,
          title: localizations.storageAndCache,
          description: localizations.storageAndCacheDescription,
          onTap: () {
            _handleItemTap(context, '/storage-settings');
          },
        ),

        _buildSettingItem(
          context,
          icon: Icons.notifications_outlined,
          title: localizations.notificationSettings,
          description: localizations.notificationSettingsDescription,
          onTap: () {
            _handleItemTap(context, '/notification-settings');
          },
        ),

        const Divider(),

        _buildSettingItem(
          context,
          icon: Icons.help_outline,
          title: localizations.helpAndFeedback,
          description: localizations.helpAndFeedbackDescription,
          onTap: () {
            _handleItemTap(context, '/help');
          },
        ),
        
        // 关于入口 - 放在设置列表的最后一项
        _buildSettingItem(
          context,
          icon: Icons.info_rounded,
          title: localizations.about,
          description: localizations.aboutDescription,
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
    } else if (route == '/language-settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()),
      );
    } else if (route == '/storage-settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StorageSettingsScreen()),
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