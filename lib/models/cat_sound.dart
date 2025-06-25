import 'package:hive/hive.dart';

part 'cat_sound.g.dart';

enum AudioSourceType {
  local,
  network,
}

@HiveType(typeId: 0)
class CatSound extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String audioPath;

  @HiveField(3)
  AudioSourceType sourceType;

  @HiveField(4)
  String? cachedPath;

  @HiveField(5)
  int playCount;

  @HiveField(6)
  DateTime lastPlayed;

  CatSound({
    required this.id,
    required this.name,
    required this.audioPath,
    required this.sourceType,
    this.cachedPath,
    this.playCount = 0,
    DateTime? lastPlayed,
  }) : lastPlayed = lastPlayed ?? DateTime.now();

  bool get isNetworkSource => sourceType == AudioSourceType.network;
  bool get isCached => cachedPath != null;
  
  void incrementPlayCount() {
    playCount++;
    lastPlayed = DateTime.now();
    save();
  }
  
  void updateCache(String path) {
    cachedPath = path;
    save();
  }
  
  void clearCache() {
    cachedPath = null;
    save();
  }
}

// 音频源类型适配器
class AudioSourceTypeAdapter extends TypeAdapter<AudioSourceType> {
  @override
  final int typeId = 2;
  
  @override
  AudioSourceType read(BinaryReader reader) {
    return AudioSourceType.values[reader.readInt()];
  }
  
  @override
  void write(BinaryWriter writer, AudioSourceType obj) {
    writer.writeInt(obj.index);
  }
} 