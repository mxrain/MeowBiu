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
    
    return Semantics(
      label: '播放${sound.name}猫叫声',
      button: true,
      enabled: true,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Card(
          elevation: isThisPlaying ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isThisPlaying
                ? BorderSide(color: progressColor, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 32,
                          color: isThisPlaying ? progressColor : Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sound.name,
                          style: TextStyle(
                            fontWeight: isThisPlaying ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isThisPlaying && progress > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 3,
                    ),
                  ),
                if (sound.isNetworkSource && !sound.isCached)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.cloud_download,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 