// lib/app/models/anniversary_dtos.dart

class AnniversaryCreateRequestDto {
  final String title;
  final String date; // "YYYY-MM-DD"

  AnniversaryCreateRequestDto({
    required this.title,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
    };
  }
}

class AnniversaryUpdateRequestDto {
  final String? title;
  final String? date; // "YYYY-MM-DD"

  AnniversaryUpdateRequestDto({
    this.title,
    this.date,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) {
      data['title'] = title;
    }
    if (date != null) {
      data['date'] = date;
    }
    return data;
  }
}

class AnniversaryResponseDto {
  final String id;
  final String title;
  final String date; // "YYYY-MM-DD"

  AnniversaryResponseDto({
    required this.id,
    required this.title,
    required this.date,
  });

  factory AnniversaryResponseDto.fromJson(Map<String, dynamic> json) {
    return AnniversaryResponseDto(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
    );
  }

  DateTime get dateTime => DateTime.parse(date);
}