import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 关于页面
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '喵喵语录',
    packageName: 'com.example.miaowang',
    version: '1.0.0',
    buildNumber: '1',
  );

  bool _autoUpdateEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _copyToClipboard(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开链接')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部应用栏
          SliverAppBar.large(
            title: const Text('关于'),
            centerTitle: true,
            pinned: true,
            floating: false,
            expandedHeight: 150,
            scrolledUnderElevation: 4.0,
            // 支持滚动收缩效果
            automaticallyImplyLeading: true,
          ),
          
          // 内容列表
          SliverList(
            delegate: SliverChildListDelegate([
              // README 项
              _buildListItem(
                context,
                icon: Icons.description_outlined,
                title: 'README',
                description: '查看GitHub项目地址与应用说明',
                onTap: () => _launchUrl('https://github.com/mxrain/miaowang'),
              ),
              
              // 版本发布项
              _buildListItem(
                context,
                icon: Icons.new_releases_outlined,
                title: '版本发布',
                description: '查看最新版本与更新日记',
                onTap: () => _launchUrl('https://github.com/mxraincheckForUpdates/miaowang/releases'),
              ),
              
              // 自动更新项
              _buildListItem(
                context,
                icon: _autoUpdateEnabled
                    ? Icons.update_outlined
                    : Icons.update_disabled_outlined,
                title: '自动更新',
                description: '检查更新',
                trailing: Switch(
                  value: _autoUpdateEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoUpdateEnabled = value;
                    });
                    // TODO: 在实际实现中保存设置
                  },
                ),
                onTap: () {
                  // TODO: 导航到更新详情页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('导航到更新详情页面')),
                  );
                },
              ),
              
              // 版本信息项
              _buildListItem(
                context,
                icon: Icons.info_outlined,
                title: '当前版本',
                description: _packageInfo.version,
                onTap: () {
                  final detailInfo = '应用名称: ${_packageInfo.appName}\n'
                      '包名: ${_packageInfo.packageName}\n'
                      '版本: ${_packageInfo.version}\n'
                      '构建号: ${_packageInfo.buildNumber}';
                  
                  _copyToClipboard(detailInfo, '版本信息已复制到剪贴板');
                },
              ),
              
              // 包名信息项
              _buildListItem(
                context,
                icon: null,
                title: 'Package name',
                description: _packageInfo.packageName,
                onTap: () {
                  _copyToClipboard(_packageInfo.packageName, '包名已复制到剪贴板');
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    IconData? icon,
    required String title,
    required String description,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      leading: icon != null
          ? Icon(
              icon,
              color: colorScheme.primary,
              size: 28,
            )
          : const SizedBox(width: 28),
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
      trailing: trailing,
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
    );
  }
} 