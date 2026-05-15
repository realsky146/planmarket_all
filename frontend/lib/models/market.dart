// lib/models/market.dart

class Market {
  final String name;
  final String subtitle;
  final String timeText;
  final bool isOpen;
  final List<String> tags;
  final String image;

  const Market({
    required this.name,
    required this.subtitle,
    required this.timeText,
    required this.isOpen,
    required this.tags,
    required this.image,
  });

  // เพิ่ม fromJson รองรับ API ในอนาคต
  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      timeText: json['time_text'] ?? '',
      isOpen: json['is_open'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      image: json['image'] ?? '',
    );
  }
}
///*** */