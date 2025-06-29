import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cat_sound.dart';
import 'cat_sound_button.dart';

class ChatBubble extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 使用左侧灰色或绿色气泡
    final bubbleAsset = sound.isNetworkSource
        ? 'assets/images/chat_bubble_grey_left.svg'
        : 'assets/images/chat_bubble_green_left.svg';
    
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
              
            const SizedBox(width: 12),
            
            Flexible(
              child: Stack(
                children: [
                  // 气泡背景
                  SvgPicture.asset(
                    bubbleAsset,
                    height: 110,
                    width: 280,
                  ),
                  
                  // 音频内容
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(38, 16, 38, 16),
                      child: CatSoundButton(
                        sound: sound,
                        onLongPress: onLongPress,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建头像组件
  Widget _buildAvatar() {
    // 计算头像文件名（从1到9循环）
    final index = (avatarIndex % 9) + 1;
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: SvgPicture.asset(
        'assets/images/cat_avatar_$index.svg',
        height: 48,
        width: 48,
      ),
    );
  }
} 