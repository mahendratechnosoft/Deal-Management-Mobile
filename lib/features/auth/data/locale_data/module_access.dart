import 'package:hive/hive.dart';
part 'module_access.g.dart';

@HiveType(typeId: 1)
class ModuleAccess extends HiveObject {
  @HiveField(0)
  final String moduleAccessId;

  @HiveField(1)
  final bool leadAccess;

  @HiveField(2)
  final bool leadViewAll;

  @HiveField(3)
  final bool leadCreate;

  @HiveField(4)
  final bool leadEdit;

  @HiveField(5)
  final bool leadDelete;

  ModuleAccess({
    required this.moduleAccessId,
    required this.leadAccess,
    required this.leadViewAll,
    required this.leadCreate,
    required this.leadEdit,
    required this.leadDelete,
  });

  factory ModuleAccess.fromJson(Map<String, dynamic> json) {
    return ModuleAccess(
      moduleAccessId: json['moduleAccessId'],
      leadAccess: json['leadAccess'] ?? false,
      leadViewAll: json['leadViewAll'] ?? false,
      leadCreate: json['leadCreate'] ?? false,
      leadEdit: json['leadEdit'] ?? false,
      leadDelete: json['leadDelete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleAccessId': moduleAccessId,
      'leadAccess': leadAccess,
      'leadViewAll': leadViewAll,
      'leadCreate': leadCreate,
      'leadEdit': leadEdit,
      'leadDelete': leadDelete,
    };
  }
}
