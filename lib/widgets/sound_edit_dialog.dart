import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cat_sound.dart';
import '../providers/sound_provider.dart';

class SoundEditDialog extends ConsumerStatefulWidget {
  final CatSound? sound;
  final String? categoryId;
  
  const SoundEditDialog({
    Key? key, 
    this.sound,
    this.categoryId,
  }) : super(key: key);

  @override
  ConsumerState<SoundEditDialog> createState() => _SoundEditDialogState();
}

class _SoundEditDialogState extends ConsumerState<SoundEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  
  bool _isLocalFile = true;
  String? _localFilePath;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // 如果是编辑模式，填充已有数据
    if (widget.sound != null) {
      _nameController.text = widget.sound!.name;
      _isLocalFile = widget.sound!.sourceType == AudioSourceType.local;
      
      if (_isLocalFile) {
        _localFilePath = widget.sound!.audioPath;
      } else {
        _urlController.text = widget.sound!.audioPath;
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }
  
  Future<void> _pickAudioFile() async {
    try {
      final XTypeGroup audioGroup = XTypeGroup(
        label: '音频文件',
        extensions: ['mp3', 'wav', 'ogg', 'aac', 'm4a'],
      );
      
      final XFile? file = await openFile(
        acceptedTypeGroups: [audioGroup],
      );
      
      if (file != null) {
        setState(() {
          _localFilePath = file.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件失败: $e')),
      );
    }
  }
  
  Future<void> _saveSound() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final name = _nameController.text.trim();
    final audioPath = _isLocalFile 
        ? _localFilePath! 
        : _urlController.text.trim();
    final sourceType = _isLocalFile 
        ? AudioSourceType.local 
        : AudioSourceType.network;
    
    setState(() => _isLoading = true);
    
    try {
      final soundManager = ref.read(soundManagerProvider.notifier);
      
      if (widget.sound == null) {
        // 创建新猫声
        await soundManager.addSound(
          name: name,
          audioPath: audioPath,
          sourceType: sourceType,
          categoryId: widget.categoryId,
        );
      } else {
        // 更新现有猫声
        final updatedSound = CatSound(
          id: widget.sound!.id,
          name: name,
          audioPath: audioPath,
          sourceType: sourceType,
          cachedPath: sourceType == widget.sound!.sourceType ? widget.sound!.cachedPath : null,
          playCount: widget.sound!.playCount,
          lastPlayed: widget.sound!.lastPlayed,
        );
        
        await soundManager.updateSound(updatedSound);
      }
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _clearCache() async {
    if (widget.sound == null || !widget.sound!.isCached) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final result = await ref.read(soundManagerProvider.notifier).clearSoundCache(widget.sound!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ? '缓存已清除' : '清除缓存失败')),
        );
        // 关闭对话框并触发刷新
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除缓存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sound != null;
    
    return AlertDialog(
      title: Text(isEditing ? '编辑猫声' : '添加猫声'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  hintText: '输入猫声名称',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 音频源选择
              const Text('音频来源:', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<bool>(
                title: const Text('本地文件'),
                value: true,
                groupValue: _isLocalFile,
                onChanged: (value) {
                  setState(() {
                    _isLocalFile = value!;
                  });
                },
              ),
              RadioListTile<bool>(
                title: const Text('网络链接'),
                value: false,
                groupValue: _isLocalFile,
                onChanged: (value) {
                  setState(() {
                    _isLocalFile = value!;
                  });
                },
              ),
              
              // 根据选择显示不同的输入控件
              if (_isLocalFile) ...[
                OutlinedButton.icon(
                  onPressed: _pickAudioFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('选择音频文件'),
                ),
                if (_localFilePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '已选择: ${File(_localFilePath!).uri.pathSegments.last}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
              ] else ...[
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: '输入音频文件URL',
                  ),
                  validator: (value) {
                    if (_isLocalFile) return null;
                    if (value == null || value.trim().isEmpty) {
                      return '请输入URL';
                    }
                    if (!Uri.tryParse(value)!.isAbsolute) {
                      return '请输入有效的URL';
                    }
                    return null;
                  },
                ),
              ],
              
              // 显示缓存状态 - 仅针对网络音频且在编辑模式
              if (isEditing && widget.sound!.isNetworkSource) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      widget.sound!.isCached ? '已缓存' : '未缓存',
                      style: TextStyle(
                        color: widget.sound!.isCached 
                            ? Colors.green 
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                if (widget.sound!.isCached)
                  TextButton.icon(
                    onPressed: _clearCache,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('清除缓存'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
              
              // 缓存管理说明
              if (!_isLocalFile && !isEditing) ...[
                const SizedBox(height: 16),
                const Text(
                  '注意: 网络音频将在首次播放时自动缓存，您可以在编辑或长按猫声按钮时管理缓存。',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSound,
          child: _isLoading 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                ) 
              : Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }
} 