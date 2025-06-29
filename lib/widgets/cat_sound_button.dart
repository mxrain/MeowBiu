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
    this.progressColor = const Color(0xFF65B741),
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
    
    // 格式化音频时长显示
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds".replaceAll(RegExp(r'^00:'), '');
    }
    
    // 从播放状态中获取当前播放的音频时长
    final duration = isThisPlaying
        ? playbackState.duration
        : Duration.zero; // 如果CatSound没有durationMs，默认使用0
    
    return InkWell(
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // 音频信息区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 音频名称
                  Text(
                    sound.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // 音频时长
                  Text(
                    isThisPlaying 
                        ? formatDuration(duration) 
                        : (sound.isNetworkSource && !sound.isCached) 
                            ? "在线音频"
                            : "点击播放",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 播放进度条
                  if (isThisPlaying)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 4,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 播放按钮
            InkWell(
              onTap: () {
                if (isThisPlaying) {
                  playbackNotifier.stopSound(); // 使用stopSound而不是pauseSound
                } else {
                  playbackNotifier.playSound(sound);
                }
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isThisPlaying ? progressColor : progressColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isThisPlaying ? Colors.white : progressColor,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 