// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_access.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModuleAccessAdapter extends TypeAdapter<ModuleAccess> {
  @override
  final int typeId = 1;

  @override
  ModuleAccess read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModuleAccess(
      moduleAccessId: fields[0] as String,
      leadAccess: fields[1] as bool,
      leadViewAll: fields[2] as bool,
      leadCreate: fields[3] as bool,
      leadEdit: fields[4] as bool,
      leadDelete: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ModuleAccess obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.moduleAccessId)
      ..writeByte(1)
      ..write(obj.leadAccess)
      ..writeByte(2)
      ..write(obj.leadViewAll)
      ..writeByte(3)
      ..write(obj.leadCreate)
      ..writeByte(4)
      ..write(obj.leadEdit)
      ..writeByte(5)
      ..write(obj.leadDelete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleAccessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
