import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cat_sound.dart';
import '../providers/sound_provider.dart';

class CatSoundButton extends ConsumerWidget {
  final CatSound sound;
  final Color progressColor;
  final VoidCallback? onLongPress;
  
  const CatSoundButton({
    Key? key,
    required this.sound,
    this.progressColor = Colors.orange,
    this.onLongPress,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final playbackNotifier = ref.read(playbackProvider.notifier);
    
    final bool isThisPlaying = playbackState.playingId == sound.id;
    final double progress = isThisPlaying && playbackState.duration.inMilliseconds > 0
        ? playbackState.position.inMilliseconds / playbackState.duration.inMilliseconds
        : 0.0;
        
    final theme = Theme.of(context);
    
    // 播放时长格式化 (只显示秒数)
    String formatDurationInSeconds(Duration d) {
      final totalSeconds = d.inSeconds;
      return '$totalSeconds\'\'';
    }
    
    String currentTimeText = isThisPlaying 
        ? formatDurationInSeconds(playbackState.position)
        : '0\'\'';
    
    String totalTimeText = isThisPlaying && playbackState.duration.inMilliseconds > 0
        ? formatDurationInSeconds(playbackState.duration)
        : '-\'\'';
    
    return Semantics(
      label: '播放${sound.name}猫叫声',
      button: true,
      enabled: true,
      child: GestureDetector(
        onLongPress: onLongPress,
        // 去除Card，使用无装饰的容器
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧头像区域 - 小圆角正方形
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8), // 小圆角
                  ),
                  child: Center(
                    child: Icon(
                      Icons.pets,
                      size: 28,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 中间音频泡泡
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isThisPlaying) {
                        // 如果正在播放，停止并重新播放
                        playbackNotifier.stopSound().then((_) {
                          playbackNotifier.playSound(sound);
                        });
                      } else {
                        // 否则，直接播放
                        playbackNotifier.playSound(sound);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashFactory: NoSplash.splashFactory, // 禁用水波纹效果
                    child: Container(
                      padding: EdgeInsets.zero, // 去除内边距
                      child: Stack(
                        children: [
                          // 播放进度背景 - 撑满整个泡泡
                          if (isThisPlaying && progress > 0)
                            Positioned.fill(
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          
                          // 内容区域
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 播放时长 - 淡色显示
                                Text(
                                  isThisPlaying ? currentTimeText : totalTimeText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                
                                // 猫声名称 - 右对齐，淡色
                                Text(
                                  sound.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: isThisPlaying ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 2),
                
                // 右侧控制按钮 - 仅图标，无背景
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.0, end: isThisPlaying ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: IconButton(
                        icon: Icon(
                          isThisPlaying ? Icons.pause : Icons.play_arrow,
                          color: theme.colorScheme.primary,
                        ),
                        iconSize: 28,
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                        onPressed: () {
                          if (isThisPlaying) {
                            // 如果正在播放，停止并重新播放
                            playbackNotifier.stopSound().then((_) {
                              playbackNotifier.playSound(sound);
                            });
                          } else {
                            // 否则，直接播放
                            playbackNotifier.playSound(sound);
                          }
                        },
                      ),
                    );
                  },
                ),
                
                // 网络资源未缓存时显示云下载图标
                if (sound.isNetworkSource && !sound.isCached)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: 1.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: IconButton(
                          icon: Icon(
                            Icons.cloud_download,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          padding: EdgeInsets.zero,
                          splashRadius: 16,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          onPressed: () {
                            // 点击下载/缓存
                            playbackNotifier.playSound(sound);
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 