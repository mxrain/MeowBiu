import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cat_sound.dart';
import '../providers/sound_provider.dart';
import 'chat_bubble.dart';

class ChatSoundsList extends ConsumerWidget {
  final String categoryId;
  final VoidCallback onAddSound;
  final Function(CatSound) onEditSound;
  final Function(CatSound) onDeleteSound;
  final Function(CatSound) onClearCache;
  final Function(CatSound) onCopySound;
  
  const ChatSoundsList({
    Key? key,
    required this.categoryId,
    required this.onAddSound,
    required this.onEditSound,
    required this.onDeleteSound,
    required this.onClearCache,
    required this.onCopySound,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundsAsync = ref.watch(categorySoundsProvider(categoryId));
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: soundsAsync.when(
        data: (sounds) {
          if (sounds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('暂无音频，添加一些猫声吧~'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onAddSound,
                    icon: const Icon(Icons.add),
                    label: const Text('添加音频'),
                  ),
                ],
              ),
            );
          }
          
          // 使用ListView显示聊天式音频列表
          return ListView.builder(
            itemCount: sounds.length,
            padding: const EdgeInsets.only(bottom: 80), // 为FAB留出空间
            itemBuilder: (context, index) {
              final sound = sounds[index];
              
              return ChatBubble(
                sound: sound,
                avatarIndex: index,
                onLongPress: () => _showSoundOptions(context, sound),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('加载失败: $error'),
        ),
      ),
    );
  }

  // 显示音频操作选项
  void _showSoundOptions(BuildContext context, CatSound sound) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.of(context).pop();
                onEditSound(sound);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制'),
              onTap: () {
                Navigator.of(context).pop();
                onCopySound(sound);
              },
            ),
            if (sound.isNetworkSource && sound.isCached)
              ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: const Text('清理缓存'),
                onTap: () {
                  Navigator.of(context).pop();
                  onClearCache(sound);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                onDeleteSound(sound);
              },
            ),
          ],
        ),
      ),
    );
  }
} 