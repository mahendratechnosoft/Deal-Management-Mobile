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
      expiryDate: fields[4] as String?,
      loginUserName: fields[5] as String?,
      employeeId: fields[6] as String?,
      adminId: fields[7] as String?,
      customerId: fields[8] as String?,
      logo: fields[9] as String?,
      contactId: fields[10] as String?,
      moduleAccess: fields[11] as ModuleAccess,
    );
  }

  @override
  void write(BinaryWriter writer, LoginResponse obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.jwtToken)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.loginEmail)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.expiryDate)
      ..writeByte(5)
      ..write(obj.loginUserName)
      ..writeByte(6)
      ..write(obj.employeeId)
      ..writeByte(7)
      ..write(obj.adminId)
      ..writeByte(8)
      ..write(obj.customerId)
      ..writeByte(9)
      ..write(obj.logo)
      ..writeByte(10)
      ..write(obj.contactId)
      ..writeByte(11)
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
