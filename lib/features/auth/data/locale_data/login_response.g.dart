// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginResponseAdapter extends TypeAdapter<LoginResponse> {
  @override
  final int typeId = 2;

  @override
  LoginResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginResponse(
      jwtToken: fields[0] as String,
      userId: fields[1] as String,
      loginEmail: fields[2] as String,
      role: fields[3] as String,
      loginUserName: fields[4] as String?,
      employeeId: fields[5] as String?,
      adminId: fields[6] as String?,
      moduleAccess: fields[7] as ModuleAccess,
    );
  }

  @override
  void write(BinaryWriter writer, LoginResponse obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.jwtToken)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.loginEmail)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.loginUserName)
      ..writeByte(5)
      ..write(obj.employeeId)
      ..writeByte(6)
      ..write(obj.adminId)
      ..writeByte(7)
      ..write(obj.moduleAccess);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
