import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/release.dart';
import '../services/preference_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import '../widgets/update_unavailable_dialog.dart';

/// 更新设置页面
class UpdatePage extends ConsumerStatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends ConsumerState<UpdatePage> {
  bool _isLoading = false;
  bool _autoUpdateEnabled = true;
  UpdateChannel _selectedChannel = UpdateChannel.stable;
  DateTime? _lastCheckTime;
  bool _updateSupported = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefService = PreferenceService();
    await prefService.init();

    setState(() {
      _autoUpdateEnabled = prefService.isAutoUpdateEnabled();
      _selectedChannel = prefService.getUpdateChannel();
      _lastCheckTime = prefService.getLastCheckUpdateTime();
    });

    // 检查是否支持自动更新
    final isSupported = await prefService.isAutoUpdateSupported();
    setState(() {
      _updateSupported = isSupported;
    });
  }

  Future<void> _saveAutoUpdateEnabled(bool value) async {
    final prefService = PreferenceService();
    await prefService.init();
    await prefService.setAutoUpdateEnabled(value);

    setState(() {
      _autoUpdateEnabled = value;
    });
  }

  Future<void> _saveUpdateChannel(UpdateChannel channel) async {
    final prefService = PreferenceService();
    await prefService.init();
    await prefService.setUpdateChannel(channel);

    setState(() {
      _selectedChannel = channel;
    });
  }

  Future<void> _checkForUpdate() async {
    if (!_updateSupported) {
      _showUpdateUnavailableDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final release = await UpdateService.checkForUpdate();

      // 更新上次检查时间
      final prefService = PreferenceService();
      await prefService.init();
      _lastCheckTime = prefService.getLastCheckUpdateTime();

      setState(() {
        _isLoading = false;
      });

      if (release != null) {
        if (mounted) {
          _showUpdateDialog(release);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('当前已是最新版本')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('检查更新失败: $e')),
        );
      }
    }
  }

  void _showUpdateDialog(Release release) {
    showDialog(
      context: context,
      builder: (context) => UpdateDialog(release: release),
    );
  }

  void _showUpdateUnavailableDialog() {
    showDialog(
      context: context,
      builder: (context) => const UpdateUnavailableDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('自动更新'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 启用自动更新开关
          SwitchListTile(
            title: const Text('启用自动更新'),
            subtitle: Text(_updateSupported 
              ? '应用启动时自动检查新版本' 
              : '当前版本不支持自动更新',
              style: TextStyle(color: _updateSupported 
                ? colorScheme.onSurfaceVariant
                : colorScheme.error),
            ),
            value: _autoUpdateEnabled && _updateSupported,
            onChanged: _updateSupported 
              ? (value) => _saveAutoUpdateEnabled(value) 
              : null,
          ),
          
          const Divider(),
          
          // 更新频道选择
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text('更新频道', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          
          // 稳定版选项
          RadioListTile<UpdateChannel>(
            title: const Text('稳定版'),
            subtitle: const Text('推荐大多数用户使用，提供更稳定的体验'),
            value: UpdateChannel.stable,
            groupValue: _selectedChannel,
            onChanged: _updateSupported && _autoUpdateEnabled
              ? (value) => _saveUpdateChannel(value!)
              : null,
          ),
          
          // 预览版选项
          RadioListTile<UpdateChannel>(
            title: const Text('预览版'),
            subtitle: const Text('提前体验新功能，但可能不稳定'),
            value: UpdateChannel.preRelease,
            groupValue: _selectedChannel,
            onChanged: _updateSupported && _autoUpdateEnabled
              ? (value) => _saveUpdateChannel(value!)
              : null,
          ),
          
          const SizedBox(height: 16),
          
          // 检查更新按钮
          Center(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkForUpdate,
              icon: _isLoading 
                ? const SizedBox(
                    width: 18, 
                    height: 18, 
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : const Icon(Icons.refresh),
              label: Text(_isLoading ? '检查中...' : '检查更新'),
            ),
          ),
          
          // 上次检查时间
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _lastCheckTime != null 
                  ? '上次检查: ${_formatDateTime(_lastCheckTime!)}' 
                  : '尚未检查更新',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 说明文本
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '更新说明',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '当自动更新启用时，应用会在启动时检查是否有新版本。'
                    '您选择的更新频道决定了您将收到的更新类型。\n\n'
                    '稳定版：经过完整测试的正式版本。\n'
                    '预览版：包含最新功能的测试版本。'
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 