// lib/app/models/holiday_dto.dart

class HolidayDto {
  final DateTime date;
  final String name;

  HolidayDto({required this.date, required this.name});

  factory HolidayDto.fromJson(Map<String, dynamic> json) {
    return HolidayDto(
      date: DateTime.parse(json['date'] as String),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String().substring(0, 10), 'name': name};
  }
}
