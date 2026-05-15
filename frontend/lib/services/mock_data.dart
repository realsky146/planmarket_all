import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../features/market_owner/market_pending_page.dart';
import '../features/guest/home_page.dart';
import '../features/guest/favorite_page.dart';
import '../features/guest/market_list_page.dart';

class MockData {
  // ✅ ต้องเป็น final List (ไม่ใช่ const) เพื่อให้ add() ได้
  static final List<Map<String, dynamic>> users = [
    {
      'id': 'u001',
      'name': 'นายสมชาย ใจดี',
      'email': 'customer@test.com',
      'password': '123456',
      'role': 'customer',
      'status': 'active',
      'phone': '081-234-5678',
      'avatar': null,
      'createdAt': '2024-01-15',
    },
    {
      'id': 'u002',
      'name': 'นางสาวมาลี ขายดี',
      'email': 'vendor@test.com',
      'password': '123456',
      'role': 'vendor',
      'status': 'active',
      'phone': '082-345-6789',
      'shopName': 'ร้านมาลีผัดไทย',
      'shopCategory': 'อาหาร',
      'reliabilityScore': 87,
      'createdAt': '2024-02-01',
    },
    {
      'id': 'u003',
      'name': 'นายประยุทธ์ ตลาดดี',
      'email': 'market@test.com',
      'password': '123456',
      'role': 'market_owner',
      'status': 'approved',
      'phone': '083-456-7890',
      'marketName': 'ตลาดจตุจักร',
      'createdAt': '2024-01-01',
    },
    {
      'id': 'u004',
      'name': 'นางสาวใหม่ ตลาดใหม่',
      'email': 'newmarket@test.com',
      'password': '123456',
      'role': 'market_owner',
      'status': 'pending',
      'phone': '084-567-8901',
      'marketName': 'ตลาดใหม่เอี่ยม',
      'createdAt': '2024-03-01',
    },
    {
      'id': 'u005',
      'name': 'Super Admin',
      'email': 'admin@planmarket.com',
      'password': 'admin1234',
      'role': 'super_admin',
      'status': 'active',
      'phone': '085-678-9012',
      'createdAt': '2024-01-01',
    },
    {
      'id': 'u005',
      'name': 'Admin ระบบ',
      'email': 'admin@planmarket.com',
      'password': 'admin1234',
      'role': 'super_admin',
      'status': 'active',
      'phone': '000-000-0000',
      'avatar': null,
      'createdAt': '2024-01-01',
    },
  ];

  // ── Markets ──────────────────────────────────────────────
  static final List<Map<String, dynamic>> markets = [
    {
      'id': 'm001',
      'name': 'ตลาดจตุจักร (โซนกลางคืน)',
      'ownerId': 'u003',
      'distance': 'จตุจักร 1.2กม.',
      'time': '17.00-23.00',
      'isOpen': true,
      'status': 'approved',
      'totalStalls': 120,
      'availableStalls': 45,
      'pricePerDay': 300,
      'rating': 4.8,
      'location': 'จตุจักร กรุงเทพฯ',
      'image': null,
      'submittedAt': '1 ม.ค. 2567',
      'ownerName': 'นายประยุทธ์ ตลาดดี',
    },
    {
      'id': 'm002',
      'name': 'ตลาดนัดรถไฟ',
      'ownerId': 'u003',
      'distance': 'รามอินทรา 4.2กม.',
      'time': '18.00-23.00',
      'isOpen': true,
      'status': 'approved',
      'totalStalls': 80,
      'availableStalls': 20,
      'pricePerDay': 250,
      'rating': 4.5,
      'location': 'รามอินทรา กรุงเทพฯ',
      'image': null,
      'submittedAt': '15 ม.ค. 2567',
      'ownerName': 'นายประยุทธ์ ตลาดดี',
    },
    {
      'id': 'm003',
      'name': 'ตลาดใหม่เอี่ยม',
      'ownerId': 'u004',
      'distance': 'ลาดพร้าว 6.0กม.',
      'time': '16.00-22.00',
      'isOpen': false,
      'status': 'pending', // ✅ รอ Admin อนุมัติ
      'totalStalls': 60,
      'availableStalls': 60,
      'pricePerDay': 200,
      'rating': 0.0,
      'location': 'ลาดพร้าว กรุงเทพฯ',
      'image': null,
      'submittedAt': '1 มี.ค. 2567',
      'ownerName': 'นางสาวใหม่ ตลาดใหม่',
    },
  ];

  // ── Bookings ─────────────────────────────────────────────
  static final List<Map<String, dynamic>> bookings = [
    {
      'id': 'b001',
      'vendorId': 'u002',
      'marketId': 'm001',
      'stallId': 'A-12',
      'date': '15 ม.ค. 2568',
      'status': 'pending',
      'price': 300,
      'type': 'รายวัน',
    },
    {
      'id': 'b002',
      'vendorId': 'u002',
      'marketId': 'm002',
      'stallId': 'B-05',
      'date': '18 ม.ค. 2568',
      'status': 'approved',
      'price': 250,
      'type': 'รายวัน',
    },
  ];
  // ⬇️ เพิ่ม Favorites (ขาดอยู่!)
  static final List<Map<String, dynamic>> favorites = [
    {
      'userId': 'u001',
      'marketId': 'm001',
      'addedAt': '2024-03-01',
    },
    {
      'userId': 'u002',
      'marketId': 'm002',
      'addedAt': '2024-03-05',
    },
  ];

  // ⬇️ เพิ่ม Notifications (สำหรับ Broadcast ของ Market Owner)
  static final List<Map<String, dynamic>> notifications = [];
}
