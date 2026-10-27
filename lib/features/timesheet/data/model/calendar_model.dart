class CalendarModel {
  final String? companyHolidayId;
  final String date; // YYYY-MM-DD
  final String type; // WEEKEND, HOLIDAY, etc.
  final String? description;

  CalendarModel({
    this.companyHolidayId,
    required this.date,
    required this.type,
    this.description,
  });

  bool get isWeekend => type.toUpperCase() == 'WEEKEND';
  bool get isHoliday => type.toUpperCase() == 'HOLIDAY';

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      companyHolidayId: json['companyHolidayId']?.toString(),
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'companyHolidayId': companyHolidayId,
    'date': date,
    'type': type,
    'description': description,
  };
}
