// lib/utils/role_navigator.dart
import 'package:flutter/material.dart';
import '../features/guest/home_page.dart';
import '../features/vendor/vendor_home.dart';
import '../features/market_owner/market_owner_home.dart';
import '../features/market_owner/market_pending_page.dart';
import '../features/super_admin/admin_home.dart';

class RoleNavigator {
  static Widget getPageForRole({
    required String role,
    String status = 'active',
  }) {
    switch (role) {
      case 'super_admin':
        return const AdminHome();
      case 'market_owner':
      case 'market':
        return status == 'approved'
            ? const MarketOwnerHome()
            : const MarketPendingPage();
      case 'vendor':
        return const VendorHome();
      case 'customer':
      default:
        return const HomePage();
    }
  }

  static void navigate(
    BuildContext context, {
    required String role,
    String status = 'active',
    bool clearStack = true,
  }) {
    final page = getPageForRole(role: role, status: status);
    if (clearStack) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => page),
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }
  }
}
