// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_sound.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatSoundAdapter extends TypeAdapter<CatSound> {
  @override
  final int typeId = 0;

  @override
  CatSound read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CatSound(
      id: fields[0] as String,
      name: fields[1] as String,
      audioPath: fields[2] as String,
      sourceType: fields[3] as AudioSourceType,
      cachedPath: fields[4] as String?,
      playCount: fields[5] as int,
      lastPlayed: fields[6] as DateTime?,
      isFavorite: fields[7] == null ? false : fields[7] as bool,
      durationMs: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CatSound obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.audioPath)
      ..writeByte(3)
      ..write(obj.sourceType)
      ..writeByte(4)
      ..write(obj.cachedPath)
      ..writeByte(5)
      ..write(obj.playCount)
      ..writeByte(6)
      ..write(obj.lastPlayed)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.durationMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatSoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
