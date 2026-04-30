import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import หน้าจอของคุณให้ครบ
import '../vendor/vendor_home.dart';
import '../guest/home_page.dart'; // สมมติว่านี่คือหน้าลูกค้า
import '../market_owner/market_owner_home.dart';

class MainSwitchPage extends StatefulWidget {
  const MainSwitchPage({super.key});

  @override
  State<MainSwitchPage> createState() => _MainSwitchPageState();
}

class _MainSwitchPageState extends State<MainSwitchPage> {
  @override
  void initState() {
    super.initState();
    _checkRoleAndRedirect();
  }

  Future<void> _checkRoleAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role'); // ดึง Role ที่เซฟไว้ตอน Login

    if (!mounted) return;

    // ถ้าไม่มี Role (ไม่ได้ Login) ไปหน้า Guest
    if (role == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
      return;
    }

    // ถ้ามี Role แล้ว แยกทางเดิน
    switch (role) {
      case 'vendor':
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const VendorHome()));
        break;
      case 'market_owner':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const MarketOwnerHome()));
        break;
      case 'customer':
      default:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // หน้าจอโหลดขณะเช็ค Role
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
