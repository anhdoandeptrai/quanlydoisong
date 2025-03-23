// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dream_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DreamGoalAdapter extends TypeAdapter<DreamGoal> {
  @override
  final int typeId = 1;

  @override
  DreamGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DreamGoal(
      title: fields[0] as String,
      description: fields[1] as String,
      progress: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DreamGoal obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.progress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
