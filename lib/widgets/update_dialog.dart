import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/release.dart';
import '../services/update_service.dart';

/// 更新对话框，显示新版本信息并提供下载安装功能
class UpdateDialog extends StatefulWidget {
  final Release release;

  const UpdateDialog({Key? key, required this.release}) : super(key: key);

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  bool _isInstalling = false;
  double _progress = 0.0;
  String? _error;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    // 如果正在下载，取消下载
    if (_isDownloading) {
      UpdateService.cancelDownload();
    }
    super.dispose();
  }

  Future<void> _downloadAndInstall() async {
    if (_isDownloading || _isInstalling) return;

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _error = null;
    });

    try {
      final filePath = await UpdateService.downloadApk(
        release: widget.release,
        onProgress: _updateProgress,
        onError: _handleError,
      );

      // 下载成功，开始安装
      if (filePath != null) {
        setState(() {
          _isDownloading = false;
          _isInstalling = true;
        });

        final success = await UpdateService.installApk(filePath);

        if (!success && mounted) {
          _handleError('安装失败，请手动安装更新');
        }
      } else {
        _handleError('下载失败');
      }
    } catch (e) {
      _handleError('更新过程出错: $e');
    }
  }

  void _updateProgress(double progress) {
    // 使用防抖动定时器减少状态更新频率
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _progress = progress;
        });
      }
    });
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _isDownloading = false;
        _isInstalling = false;
        _error = message;
      });
    }
  }

  void _openReleasePage() async {
    try {
      final url = 'https://github.com/mxrain/miaowang/releases/tag/${widget.release.tagName}';
      final uri = Uri.parse(url);
      
      // 添加日志输出
      debugPrint('尝试打开URL: $url');
      
      final canLaunch = await canLaunchUrl(uri);
      debugPrint('canLaunchUrl结果: $canLaunch');
      
      if (canLaunch) {
        final result = await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('launchUrl结果: $result');
        if (!result && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法打开链接，请手动访问GitHub查看详情')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法打开浏览器')),
          );
        }
      }
    } catch (e) {
      debugPrint('打开链接出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开链接出错: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final version = widget.release.tagName.replaceFirst('v', '');
    final formattedDate = _formatDate(widget.release.publishedAt);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('发现新版本'),
          const SizedBox(height: 4),
          Text(
            '${widget.release.name} ($version)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 更新时间
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 更新内容
            const Text('更新内容:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                constraints: const BoxConstraints(maxHeight: 200),
                child: Markdown(
                  data: widget.release.body,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 错误信息
            if (_error != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: colorScheme.error, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '下载遇到问题:',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '您可以使用浏览器直接下载更新',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // 下载进度条
            if (_isDownloading) ...[
              const Text('正在下载更新...'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toStringAsFixed(1)}%'),
            ],
            
            // 安装中提示
            if (_isInstalling) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('正在启动安装程序...'),
                  ],
                ),
              ),
            ],
            
            // 添加调试信息（仅在开发环境显示）
            if (kDebugMode && _error != null) ...[
              const Divider(),
              const Text('调试信息:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_error!, style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed: () {
            if (_isDownloading) {
              UpdateService.cancelDownload();
            }
            Navigator.of(context).pop();
          },
          child: Text(_isDownloading ? '取消下载' : '稍后更新'),
        ),
        
        // 错误后显示浏览器下载按钮
        if (_error != null) ...[
          TextButton.icon(
            icon: const Icon(Icons.open_in_browser),
            label: const Text('浏览器下载'),
            onPressed: () async {
              final url = 'https://github.com/mxrain/miaowang/releases/tag/${widget.release.tagName}';
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ] else ...[
          // 查看详情按钮
          TextButton(
            onPressed: _openReleasePage,
            child: const Text('查看详情'),
          ),
        ],
        
        // 更新按钮
        if (!_isDownloading && !_isInstalling) ...[
          ElevatedButton(
            onPressed: _downloadAndInstall,
            child: const Text('立即更新'),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 