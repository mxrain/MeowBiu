import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cat_sound.dart';
import '../providers/sound_provider.dart';

class ChatBubble extends ConsumerWidget {
  final CatSound sound;
  final int avatarIndex;
  final VoidCallback? onLongPress;
  
  const ChatBubble({
    Key? key,
    required this.sound,
    required this.avatarIndex,
    this.onLongPress,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final playbackNotifier = ref.read(playbackProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    
    final bool isThisPlaying = playbackState.playingId == sound.id && playbackState.isPlaying;
    final double progress = isThisPlaying && playbackState.duration.inMilliseconds > 0
        ? playbackState.position.inMilliseconds / playbackState.duration.inMilliseconds
        : 0.0;
        
    // 检测播放是否结束，结束后自动重置状态
    if (playbackState.playingId == sound.id && 
        !playbackState.isPlaying && 
        playbackState.position.inSeconds > 0 &&
        playbackState.position >= playbackState.duration) {
      // 播放结束，重置状态
      WidgetsBinding.instance.addPostFrameCallback((_) {
        playbackNotifier.resetState(sound.id);
      });
    }
    
    // 使用左侧灰色或绿色气泡
    final bubbleAsset = sound.isNetworkSource
        ? 'assets/images/chat_bubble_grey_left.svg'
        : 'assets/images/chat_bubble_green_left.svg';
    
    // 格式化时间 - 显示倒计时
    String formatDuration(Duration total, Duration position) {
      if (isThisPlaying) {
        // 播放中，显示倒计时
        final remaining = total - position;
        final seconds = remaining.inSeconds;
        return '$seconds\'\'';
      } else {
        // 未播放，显示总时长
        final seconds = total.inSeconds;
        return '$seconds\'\'';
      }
    }
    
    // 获取音频时长
    final duration = isThisPlaying 
        ? playbackState.duration 
        : sound.duration;
    
    // 获取当前位置
    final position = isThisPlaying 
        ? playbackState.position 
        : Duration.zero;
    
    // 播放音频 - 修改播放逻辑
    void playAudio() async {
      // 检查是否是当前声音暂停后的继续播放
      if (playbackState.playingId == sound.id && !playbackState.isPlaying) {
        // 继续播放当前已暂停的声音
        await playbackNotifier.resumeSound();
        return;
      }
      
      // 否则，停止当前播放并开始新的播放
      if (playbackState.playingId != null) {
        await playbackNotifier.stopSound();
      }
      await playbackNotifier.playSound(sound);
    }
    
    // 暂停音频 - 只有暂停按钮才能暂停
    void pauseAudio() async {
      if (isThisPlaying) {
        await playbackNotifier.pauseSound();
      }
    }
    
    // 统一使用浅蓝色作为头像背景
    final Color avatarColor = const Color.fromARGB(255, 170, 201, 226)!;
    
    // 修改为使用本地函数而非类方法
    Widget buildPlayButton(bool isThisPlaying, ColorScheme colorScheme) {
      return GestureDetector(
        onTap: isThisPlaying ? pauseAudio : playAudio,
        child: Container(
          width: 31, // 从36减小5
          height: 31, // 从36减小5
          decoration: BoxDecoration(
            color: isThisPlaying 
                ? colorScheme.primary 
                : colorScheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: isThisPlaying ? Colors.white : colorScheme.primary,
            size: 18, // 从22减小到18
          ),
        ),
      );
    }

    Widget buildDownloadButton(BuildContext context, CatSound sound) {
      final colorScheme = Theme.of(context).colorScheme;
      return GestureDetector(
        onTap: playAudio,
        child: Container(
          width: 31, // 从36减小5
          height: 31, // 从36减小5
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.download_rounded,
                color: colorScheme.primary,
                size: 18, // 从22减小到18
              ),
              // 修正对playbackState的引用
              if (isThisPlaying)
                SizedBox(
                  width: 31, // 从36减小5
                  height: 31, // 从36减小5
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像 - 添加黑色边框
          GestureDetector(
            onTap: playAudio,
            onLongPress: onLongPress,
            child: Container(
              height: 48,
              width: 48,
              margin: const EdgeInsets.only(top: 6), // 添加顶部margin
              decoration: BoxDecoration(
                color: avatarColor, // 统一使用浅蓝色
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black, width: 1.0), // 添加黑色边框
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SvgPicture.asset(
                  'assets/images/cat_avatar_${(avatarIndex % 9) + 1}.svg',
                  height: 44,
                  width: 44,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: -17), // 从-12改为-17，泡泡再往左挪5px
          
          // 聊天气泡
          Expanded(
            child: GestureDetector(
              onTap: playAudio,
              onLongPress: onLongPress,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 60,
                    child: Stack(
                      children: [
                        // SVG背景
                        Positioned.fill(
                          child: SvgPicture.asset(
                            bubbleAsset,
                            fit: BoxFit.fill,
                          ),
                        ),
                        
                        // 进度条覆盖层 - 使用SVG形状
                        if (isThisPlaying)
                          Positioned.fill(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: progress),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              builder: (context, animatedProgress, _) {
                                return ClipRect(
                                  clipper: ProgressClipper(animatedProgress * constraints.maxWidth),
                                  child: SvgPicture.asset(
                                    bubbleAsset,
                                    fit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(
                                      colorScheme.primary.withOpacity(0.3),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        // 音频内容
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 音频名称 - 靠左显示
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 35.0), // 从25px增加到35px
                                    child: Text(
                                      sound.name,
                                      style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                
                                // 播放按钮区域
                                Padding(
                                  padding: const EdgeInsets.only(right: 40.0), // 从45减少到40，右边减少5px
                                  child: sound.isNetworkSource && !sound.isCached
                                      ? buildDownloadButton(context, sound)
                                      : buildPlayButton(isThisPlaying, colorScheme),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 修改时间区域 - 靠近泡泡
          Container(
            height: 60,
            width: 40, // 减小宽度，靠近泡泡
            margin: const EdgeInsets.only(left: -15), // 向左移动，靠近泡泡
            alignment: Alignment.centerLeft, // 靠左对齐
            child: Text(
              formatDuration(duration, position),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 自定义裁剪器，用于创建与播放进度相匹配的裁剪区域
class ProgressClipper extends CustomClipper<Rect> {
  final double width;
  
  ProgressClipper(this.width);
  
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, width, size.height);
  }
  
  @override
  bool shouldReclip(ProgressClipper oldClipper) {
    return width != oldClipper.width;
  }
}