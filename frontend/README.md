# plan_market

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Plan Market — สรุปฉบับส่งต่อทีม
1) แอปนี้คืออะไร
Plan Market คือแอปบริหารจัดการตลาดนัดและแผงค้า ที่เชื่อม 3 กลุ่มผู้ใช้เข้าหากัน
ลูกค้า (Guest)
  → หาตลาดใกล้บ้าน ดูว่าวันนี้เปิดไหม มีร้านอะไรบ้าง
ร้านค้า (Vendor)
  → จองแผงในตลาด จ่ายเงิน เช็กอิน สะสมคะแนนความน่าเชื่อถือ
เจ้าของตลาด (Market Owner)
  → จัดผังโซน คุมการจอง เก็บเงิน คุมคุณภาพร้านค้า
ผู้ดูแลระบบ (Super Admin)
  → อนุมัติตลาดใหม่ ดูภาพรวมทั้งระบบ

2) Tech Stack
Frontend   : Flutter (Dart)
Font       : Google Fonts (Kanit)
State      : setState (MVP ยังไม่ใช้ Provider/Bloc)
Data       : Mock Data (SharedPreferences)
Backend    : รอเพื่อนทำ (REST API หรือ Firebase)
Database   : Cloud Firestore (แผน)
Auth       : Firebase Auth (แผน)

3) โครงสร้างโฟลเดอร์ทั้งหมด
lib/
│
├── main.dart                          ← จุดเริ่มต้น + เช็ค role/session
│
├── services/                          ← Logic/Data Layer
│   ├── mock_data.dart                 ← ข้อมูล Mock ทั้งหมด
│   ├── auth_service.dart              ← login/signup/logout
│   └── market_service.dart            ← ข้อมูลตลาด/อนุมัติ
│
└── features/                          ← UI Layer แยกตาม Role
    │
    ├── auth/                          ← หน้าสมัคร/เข้าสู่ระบบ (ทุก Role)
    │   ├── select_role_page.dart      ← เลือก Role
    │   ├── login_page.dart            ← Sign in / Sign up
    │   ├── signin_page.dart           ← กรอก Email/Password
    │   ├── signup_page.dart           ← สมัครลูกค้า
    │   ├── signup_vendor_page.dart    ← สมัครร้านค้า
    │   └── signup_market_page.dart    ← สมัครเจ้าของตลาด
    │
    ├── guest/                         ← หน้าลูกค้า (ไม่ต้องล็อกอิน)
    │   ├── home_page.dart             ← หน้าแรก
    │   ├── favorite_page.dart         ← ร้านที่ถูกใจ
    │   ├── market_list_page.dart      ← ลิสต์ตลาด
    │   ├── market_detail_page.dart    ← รายละเอียดตลาด + แผนผัง
    │   ├── profile_page.dart          ← โปรไฟล์ลูกค้า
    │   ├── signin_page.dart           ← Sign in ลูกค้า
    │   └── signup_page.dart           ← Sign up ลูกค้า
    │
    ├── vendor/                        ← หน้าร้านค้า
    │   ├── vendor_home.dart           ← หน้าแรกร้านค้า
    │   ├── vendor_market_list_page.dart ← ตลาดแนะนำ
    │   ├── vendor_booking_page.dart   ← จองแผง
    │   ├── favorite_page.dart         ← ตลาดที่ถูกใจ
    │   └── profile_vendor_page.dart   ← โปรไฟล์ + สรุปรออนุมัติ
    │
    ├── market_owner/                  ← หน้าเจ้าของตลาด
    │   ├── market_pending_page.dart   ← รอ Admin อนุมัติ
    │   └── market_owner_home.dart     ← Dashboard + จัดการตลาด
    │
    └── super_admin/                   ← หน้าผู้ดูแลระบบ
        ├── admin_home.dart            ← Dashboard Admin
        └── market_approval_page.dart  ← อนุมัติ/ปฏิเสธตลาด

4) Flow การทำงาน
main.dart
    ↓ เช็ค SharedPreferences
    ↓
ไม่มี session → HomePage (Guest)
มี session    → เช็ค role + status
    ↓
super_admin   → AdminHome
market_owner
  approved    → MarketOwnerHome
  pending     → MarketPendingPage
  rejected    → HomePage (ล้าง session)
vendor        → VendorHome
customer      → ProfilePage

Flow ลูกค้า
HomePage (Guest)
    ├── ดูตลาดใกล้ฉัน
    ├── กดตลาด → MarketDetailPage (แผนผังล็อก)
    ├── กดถูกใจ → FavoritePage
    └── กดโปรไฟล์ → SelectRolePage → Login

Flow ร้านค้า
SelectRolePage → LoginPage(vendor) → SignUpVendorPage
    ↓ สมัครสำเร็จ
VendorHome
    ├── ถูกใจ  → VendorFavoritePage
    ├── ตลาด   → VendorMarketListPage → VendorBookingPage
    └── โปรไฟล์ → VendorProfilePage (ข้อมูล + รออนุมัติ)

Flow เจ้าของตลาด
SelectRolePage → LoginPage(market) → SignUpMarketPage
    ↓ ส่งคำขอ
MarketPendingPage (รอ Admin)
    ↓ Admin อนุมัติ
MarketOwnerHome
    ├── Dashboard (สรุปวันนี้)
    ├── ผังตลาด (โซน + ล็อก)
    ├── การจอง (อนุมัติ/ปฏิเสธ)
    ├── ร้านค้า (Reliability Score)
    └── ประกาศ (Broadcast)

Flow Admin
Login (admin@planmarket.com)
    ↓
AdminHome
    ├── Dashboard (ภาพรวมระบบ)
    ├── ตลาดทั้งหมด
    ├── ผู้ใช้ทั้งหมด
    └── MarketApprovalPage
            ├── รออนุมัติ → กดอนุมัติ/ปฏิเสธ
            ├── อนุมัติแล้ว
            └── ปฏิเสธแล้ว

5) Mock Account ทดสอบ
Role          Email                    Password
─────────────────────────────────────────────────
ลูกค้า        customer@test.com        123456
ร้านค้า        vendor@test.com          123456
ตลาด(อนุมัติ) market@test.com          123456
ตลาด(รออนุมัติ) newmarket@test.com    123456
Super Admin   admin@planmarket.com     admin1234

6) สิ่งที่ Mock อยู่ (ต้องต่อ Backend ทีหลัง)
lib/services/mock_data.dart    ← ข้อมูลทดสอบทั้งหมด
lib/services/auth_service.dart ← login/signup (Mock)
lib/services/market_service.dart ← ข้อมูลตลาด (Mock)

วิธีต่อ Backend (แก้แค่ services/ เท่านั้น)
// ตอนนี้ (Mock)
Future<Map<String,dynamic>> signIn(...) async {
  await Future.delayed(1 second); // จำลอง network
  final user = MockData.users.where(...).first;
  return {'success': true, ...};
}

// ตอนต่อ Backend (เปลี่ยนแค่นี้)
Future<Map<String,dynamic>> signIn(...) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    body: jsonEncode({...}),
  );
  return jsonDecode(response.body);
}
// UI ไม่ต้องแตะเลย ✅

7) สิ่งที่ยังไม่ได้ทำ (Backlog)
Priority สูง
  ├── ต่อ Firebase Auth + Firestore
  ├── ระบบชำระเงิน (PromptPay QR)
  ├── Push Notification (FCM)
  └── QR Code Check-in จริง

Priority กลาง
  ├── หน้า "ร้านค้า" (Tab ที่ 4 ใน Bottom Nav)
  ├── แผนที่ใกล้ฉัน (Google Maps / OpenStreetMap)
  ├── Weather API (แจ้งฝนตก)
  └── Reliability Score จริง (คำนวณจาก Check-in)

Priority ต่ำ
  ├── i18n (ภาษาตามเครื่อง)
  ├── Dark Mode
  └── Export รายงาน CSV

8) สิ่งที่คนรับงานต้องรู้
Pattern ที่ใช้ตลอด
// 1) Bottom Nav แบบปุ่มลอย (ทุกหน้าใช้เหมือนกัน)
AnimatedPositioned(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOutBack,
  left: (itemWidth * currentIndex) + (itemWidth/2) - 31,
  ...
)

// 2) Header โค้งสีเขียว (Wave)
CustomPaint(painter: _TopWavePainter())
// ทุกหน้าใช้ _TopWavePainter เหมือนกัน

// 3) navigate พร้อม animation delay
void _navigateToPage(int index) {
  setState(() => currentIndex = index);
  Future.delayed(Duration(milliseconds: 300), () {
    Navigator.pushReplacement(...);
  });
}

// 4) Mock → Real แก้แค่ services/
// UI ไม่ต้องแตะ

สีหลัก
Primary Green   : #8CBC63 (ปุ่ม/Header)
Dark Green      : #6E9B4C (ปุ่มกลม/Active)
Wave Green      : #73A34F (Header Wave)
Background      : #EEEEEE
White Card      : #FFFFFF
Admin Blue      : #2D9CDB (Super Admin)

Dependencies ที่ใช้
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1
  shared_preferences: ^2.x.x
  image_picker: ^1.x.x

# ต้องเพิ่มทีหลัง
  firebase_core: ^x.x.x
  firebase_auth: ^x.x.x
  cloud_firestore: ^x.x.x
  http: ^x.x.x

9) Checklist ก่อนส่งงาน
✅ ทำแล้ว
  [✅] โครงสร้างโฟลเดอร์
  [✅] Mock Data + Services
  [✅] หน้า Auth (Select Role/Login/Signin/Signup)
  [✅] หน้า Guest (Home/Favorite/MarketList/Detail/Profile)
  [✅] หน้า Vendor (Home/MarketList/Booking/Favorite/Profile)
  [✅] หน้า MarketOwner (Pending/Home/Layout/Booking/Vendor/Broadcast)
  [✅] หน้า SuperAdmin (Home/MarketApproval)
  [✅] Navigation ครบทุก Role
  [✅] Main.dart เช็ค Role/Status

⬜ ยังไม่ได้ทำ
  [⬜] ต่อ Backend API
  [⬜] Firebase Auth/Firestore
  [⬜] ชำระเงิน PromptPay
  [⬜] Push Notification
  [⬜] แผนที่จริง
  [⬜] QR Check-in จริง