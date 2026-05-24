// lib/features/stall_recommendation/models/recommendation_models.dart

import 'package:flutter/material.dart';

/// ประเภทความต้องการของร้านค้า
enum StallPreference {
  nearby, // ใกล้ที่สุด
  highTraffic, // คนเยอะ
  hasEvent, // มีอีเว้นท์
  cheapest, // ราคาถูก
  sameCat, // ประเภทสินค้าเดียวกัน
  parking, // มีที่จอดรถ
  aircon, // มีแอร์/พัดลม
  weekend, // เปิดเฉพาะวันหยุด
}

extension StallPreferenceExtension on StallPreference {
  String get title {
    switch (this) {
      case StallPreference.nearby:
        return 'ใกล้ที่สุด';
      case StallPreference.highTraffic:
        return 'คนเยอะ';
      case StallPreference.hasEvent:
        return 'มีอีเว้นท์';
      case StallPreference.cheapest:
        return 'ราคาถูก';
      case StallPreference.sameCat:
        return 'สินค้าประเภทเดียวกัน';
      case StallPreference.parking:
        return 'มีที่จอดรถ';
      case StallPreference.aircon:
        return 'มีแอร์/พัดลม';
      case StallPreference.weekend:
        return 'เปิดวันหยุด';
    }
  }

  String get icon {
    switch (this) {
      case StallPreference.nearby:
        return '📍';
      case StallPreference.highTraffic:
        return '👥';
      case StallPreference.hasEvent:
        return '🎉';
      case StallPreference.cheapest:
        return '💰';
      case StallPreference.sameCat:
        return '🏷️';
      case StallPreference.parking:
        return '🅿️';
      case StallPreference.aircon:
        return '❄️';
      case StallPreference.weekend:
        return '📅';
    }
  }

  Color get color {
    switch (this) {
      case StallPreference.nearby:
        return const Color(0xFF3B82F6);
      case StallPreference.highTraffic:
        return const Color(0xFFF59E0B);
      case StallPreference.hasEvent:
        return const Color(0xFFEC4899);
      case StallPreference.cheapest:
        return const Color(0xFF10B981);
      case StallPreference.sameCat:
        return const Color(0xFF8B5CF6);
      case StallPreference.parking:
        return const Color(0xFF6366F1);
      case StallPreference.aircon:
        return const Color(0xFF06B6D4);
      case StallPreference.weekend:
        return const Color(0xFFEF4444);
    }
  }
}

/// เหตุผลที่ถูกปฏิเสธ
enum RejectionReason {
  stallFull, // ล็อคเต็ม
  rejected, // ถูกปฏิเสธจากเจ้าของตลาด
  categoryMismatch, // ประเภทสินค้าไม่ตรง
  documentIssue, // เอกสารไม่ครบ
  other, // อื่นๆ
}

extension RejectionReasonExtension on RejectionReason {
  String get message {
    switch (this) {
      case RejectionReason.stallFull:
        return 'ล็อคที่คุณเลือกเต็มแล้ว';
      case RejectionReason.rejected:
        return 'การจองถูกปฏิเสธจากเจ้าของตลาด';
      case RejectionReason.categoryMismatch:
        return 'ประเภทสินค้าไม่ตรงกับโซนที่เลือก';
      case RejectionReason.documentIssue:
        return 'เอกสารไม่ครบถ้วน';
      case RejectionReason.other:
        return 'ไม่สามารถดำเนินการได้';
    }
  }

  String get icon {
    switch (this) {
      case RejectionReason.stallFull:
        return '🚫';
      case RejectionReason.rejected:
        return '❌';
      case RejectionReason.categoryMismatch:
        return '⚠️';
      case RejectionReason.documentIssue:
        return '📄';
      case RejectionReason.other:
        return '❓';
    }
  }
}

/// ข้อมูลล็อคที่แนะนำ
class RecommendedStall {
  final String id;
  final String marketId;
  final String marketName;
  final String stallCode;
  final String zone;
  final String size;
  final double price;
  final String imageUrl;
  final double distance;
  final int trafficScore;
  final bool hasEvent;
  final List<String> eventNames;
  final double matchScore;
  final List<StallPreference> matchedPreferences;
  final bool isFromSameOwner;

  RecommendedStall({
    required this.id,
    required this.marketId,
    required this.marketName,
    required this.stallCode,
    required this.zone,
    required this.size,
    required this.price,
    required this.imageUrl,
    required this.distance,
    required this.trafficScore,
    required this.hasEvent,
    this.eventNames = const [],
    required this.matchScore,
    this.matchedPreferences = const [],
    this.isFromSameOwner = false,
  });

  factory RecommendedStall.fromJson(Map<String, dynamic> json) {
    return RecommendedStall(
      id: json['id'] as String,
      marketId: json['marketId'] as String,
      marketName: json['marketName'] as String,
      stallCode: json['stallCode'] as String,
      zone: json['zone'] as String,
      size: json['size'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      distance: (json['distance'] as num).toDouble(),
      trafficScore: json['trafficScore'] as int,
      hasEvent: json['hasEvent'] as bool,
      eventNames: List<String>.from(json['eventNames'] ?? []),
      matchScore: (json['matchScore'] as num).toDouble(),
      matchedPreferences: (json['matchedPreferences'] as List?)
              ?.map((e) => StallPreference.values[e as int])
              .toList() ??
          [],
      isFromSameOwner: json['isFromSameOwner'] as bool? ?? false,
    );
  }
}

/// ผลลัพธ์การแนะนำ
class RecommendationResult {
  final bool success;
  final RejectionReason reason;
  final String originalMarketName;
  final String originalStallCode;
  final List<RecommendedStall> recommendations;
  final DateTime generatedAt;

  RecommendationResult({
    required this.success,
    required this.reason,
    required this.originalMarketName,
    required this.originalStallCode,
    required this.recommendations,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
}
