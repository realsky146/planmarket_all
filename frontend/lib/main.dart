import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ เพิ่ม
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/guest/home_page.dart';
import 'features/guest/profile_page.dart';
import 'features/vendor/vendor_home.dart';
import 'features/market_owner/market_owner_home.dart';
import 'features/market_owner/market_pending_page.dart';
import 'features/super_admin/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlanMarketApp());
}

class PlanMarketApp extends StatelessWidget {
  const PlanMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8CBC63),
        ),
      ),

      // ✅ เพิ่มตรงนี้
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th', 'TH'),
        Locale('en', 'US'),
      ],
      locale: const Locale('th', 'TH'),

      home: const SplashRouter(),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final status = prefs.getString('status') ?? 'active';

    if (!mounted) return;

    if (role == null) {
      _go(const HomePage());
      return;
    }

    switch (role) {
      case 'super_admin':
        _go(const AdminHome());
        break;
      case 'market_owner':
        if (status == 'approved') {
          _go(const MarketOwnerHome());
        } else if (status == 'pending') {
          _go(const MarketPendingPage());
        } else {
          await prefs.clear();
          if (!mounted) return;
          _go(const HomePage());
        }
        break;
      case 'vendor':
        _go(const VendorHome());
        break;
      case 'customer':
        _go(const HomePage());
        break;
      default:
        _go(const HomePage());
    }
  }

  void _go(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8CBC63),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Plan Market',
              style: GoogleFonts.kanit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ตลาดนัดออนไลน์',
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
