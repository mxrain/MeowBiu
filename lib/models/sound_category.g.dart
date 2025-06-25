// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundCategoryAdapter extends TypeAdapter<SoundCategory> {
  @override
  final int typeId = 1;

  @override
  SoundCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoundCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      soundIds: (fields[2] as List?)?.cast<String>(),
      order: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SoundCategory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.soundIds)
      ..writeByte(3)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
