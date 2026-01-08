import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/update_provider.dart';
import '../widgets/update_dialog.dart';

/// 关于页面
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '喵王语录',
    packageName: 'com.example.miaowang',
    version: '1.0.0',
    buildNumber: '1',
  );

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
                description: '查看最新版本与更新日志',
                onTap: () => _launchUrl('https://github.com/mxrain/miaowang/releases'),
              ),
              
              // 检查更新项
              _buildListItem(
                context,
                icon: Icons.update_outlined,
                title: '检查更新',
                description: _getUpdateDescription(),
                trailing: ref.watch(updateCheckProvider).isChecking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () async {
                  final settings = ref.read(updateSettingsProvider);
                  await ref.read(updateCheckProvider.notifier).checkForUpdate(
                    includePrerelease: settings.includePrerelease,
                  );
                  await ref.read(updateSettingsProvider.notifier).updateLastCheckTime();
                  
                  final state = ref.read(updateCheckProvider);
                  if (mounted) {
                    if (state.updateInfo != null) {
                      UpdateDialog.show(context, state.updateInfo!);
                    } else if (state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('检查失败: ${state.error}')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已是最新版本')),
                      );
                    }
                  }
                },
              ),
              
              // 自动更新开关
              _buildListItem(
                context,
                icon: Icons.autorenew_outlined,
                title: '自动检查更新',
                description: '启动时自动检查新版本',
                trailing: Switch(
                  value: ref.watch(updateSettingsProvider).autoCheck,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).setAutoCheck(value);
                  },
                ),
                onTap: () {
                  final current = ref.read(updateSettingsProvider).autoCheck;
                  ref.read(updateSettingsProvider.notifier).setAutoCheck(!current);
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

  String _getUpdateDescription() {
    final settings = ref.watch(updateSettingsProvider);
    final checkState = ref.watch(updateCheckProvider);
    
    if (checkState.isChecking) {
      return '正在检查...';
    }
    if (checkState.updateInfo != null) {
      return '发现新版本 v${checkState.updateInfo!.version}';
    }
    if (settings.lastCheckTime != null) {
      final diff = DateTime.now().difference(settings.lastCheckTime!);
      if (diff.inMinutes < 1) {
        return '刚刚检查过';
      } else if (diff.inHours < 1) {
        return '${diff.inMinutes} 分钟前检查';
      } else if (diff.inDays < 1) {
        return '${diff.inHours} 小时前检查';
      } else {
        return '${diff.inDays} 天前检查';
      }
    }
    return '点击检查更新';
  }
} 