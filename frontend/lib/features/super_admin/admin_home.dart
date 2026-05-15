import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../services/market_service.dart';
import '../auth/select_role_page.dart'; // ✅ แก้: ไป SelectRolePage แทน LoginPage
import 'market_approval_page.dart'; // ✅ ลบ import ซ้ำออก

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  final _pages = const [
    _AdminDashboardTab(),
    _AdminMarketListTab(),
    _AdminVendorListTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: _pages[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF2D9CDB).withOpacity(0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(
                Icons.dashboard,
                color: Color(0xFF2D9CDB),
              ),
              label: 'แดชบอร์ด',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(
                Icons.storefront,
                color: Color(0xFF2D9CDB),
              ),
              label: 'ตลาด',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(
                Icons.people,
                color: Color(0xFF2D9CDB),
              ),
              label: 'ผู้ใช้',
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Tab 1: Dashboard
// ══════════════════════════════════════════════════════════
class _AdminDashboardTab extends StatelessWidget {
  const _AdminDashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2D9CDB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan Market',
                            style: GoogleFonts.kanit(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Super Admin',
                            style: GoogleFonts.kanit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // ✅ แก้: Logout ไป SelectRolePage
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'ออกจากระบบ',
                        onPressed: () async {
                          // Confirm dialog
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                'ออกจากระบบ',
                                style: GoogleFonts.kanit(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'ต้องการออกจากระบบใช่ไหม?',
                                style: GoogleFonts.kanit(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    'ยกเลิก',
                                    style: GoogleFonts.kanit(),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    'ออกจากระบบ',
                                    style: GoogleFonts.kanit(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await AuthService().logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  // ✅ แก้: ไป SelectRolePage แทน LoginPage(role:'')
                                  builder: (_) => const SelectRolePage(),
                                ),
                                (route) => false,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stat Cards
                  Row(
                    children: [
                      _statCard(
                        'ตลาดทั้งหมด',
                        '12',
                        Icons.storefront_outlined,
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        'รออนุมัติ',
                        '2',
                        Icons.hourglass_empty,
                        bgColor: const Color(0xFFFFF3CD),
                        textColor: const Color(0xFFB45309),
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        'ผู้ใช้ทั้งหมด',
                        '348',
                        Icons.people_outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Body ───────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // คำขออนุมัติตลาด
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'คำขอลงทะเบียนตลาด',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MarketApprovalPage(),
                          ),
                        ),
                        child: Text(
                          'ดูทั้งหมด →',
                          style: GoogleFonts.kanit(
                            color: const Color(0xFF2D9CDB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Pending requests
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: MarketService().getPendingRequests(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2D9CDB),
                          ),
                        );
                      }
                      final requests = snapshot.data!;
                      if (requests.isEmpty) {
                        return _emptyCard('ไม่มีคำขอที่รออนุมัติ');
                      }
                      return Column(
                        children: requests
                            .take(2)
                            .map((r) => _pendingCard(context, r))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // สถิติภาพรวม
                  Text(
                    'สถิติภาพรวม',
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _overviewCard(
                        'ตลาดที่เปิดอยู่',
                        '8',
                        Icons.store,
                        const Color(0xFF22C55E),
                      ),
                      _overviewCard(
                        'ร้านค้าทั้งหมด',
                        '245',
                        Icons.shopping_bag_outlined,
                        const Color(0xFF8CBC63),
                      ),
                      _overviewCard(
                        'การจองวันนี้',
                        '38',
                        Icons.calendar_today,
                        const Color(0xFF2D9CDB),
                      ),
                      _overviewCard(
                        'รายรับรวม',
                        '฿125K',
                        Icons.payments_outlined,
                        const Color(0xFF6C5CE7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon, {
    Color bgColor = Colors.transparent,
    Color textColor = Colors.white,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor == Colors.transparent
              ? Colors.white.withOpacity(0.2)
              : bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.kanit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.kanit(
                fontSize: 10,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingCard(BuildContext context, Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFB000).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront,
              color: Color(0xFFB45309),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['marketName'] ?? '-',
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  r['ownerName'] ?? '-',
                  style: GoogleFonts.kanit(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
                Text(
                  r['submittedAt'] ?? '-',
                  style: GoogleFonts.kanit(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D9CDB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MarketApprovalPage(),
              ),
            ),
            child: Text(
              'ตรวจสอบ',
              style: GoogleFonts.kanit(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.kanit(color: const Color(0xFF9CA3AF)),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Tab 2: Market List
// ══════════════════════════════════════════════════════════
class _AdminMarketListTab extends StatelessWidget {
  const _AdminMarketListTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text(
          'ตลาดทั้งหมด',
          style: GoogleFonts.kanit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2D9CDB),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.pending_actions, color: Colors.white),
            tooltip: 'รออนุมัติ',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarketApprovalPage()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MarketService().getMarkets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D9CDB)),
            );
          }
          final markets = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: markets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final m = markets[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // รูปตลาด
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFFE5E7EB),
                        child: m['image'] != null
                            ? Image.asset(
                                m['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.storefront,
                                  color: Color(0xFF9CA3AF),
                                  size: 32,
                                ),
                              )
                            : const Icon(
                                Icons.storefront,
                                color: Color(0xFF9CA3AF),
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ข้อมูลตลาด
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['name'] ?? '-',
                            style: GoogleFonts.kanit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m['distance'] ?? '-',
                            style: GoogleFonts.kanit(
                              color: const Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            m['time'] ?? '-',
                            style: GoogleFonts.kanit(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: m['isOpen'] == true
                            ? const Color(0xFFDFF7E6)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        m['isOpen'] == true ? 'เปิดอยู่' : 'ปิดอยู่',
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: m['isOpen'] == true
                              ? const Color(0xFF0F7A36)
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Tab 3: User List
// ══════════════════════════════════════════════════════════
class _AdminVendorListTab extends StatelessWidget {
  const _AdminVendorListTab();

  static const _users = [
    {
      'name': 'สมชาย ใจดี',
      'email': 'customer@test.com',
      'role': 'ลูกค้า',
      'status': 'active',
    },
    {
      'name': 'ร้านอาชียะ',
      'email': 'vendor@test.com',
      'role': 'ร้านค้า',
      'status': 'active',
    },
    {
      'name': 'ตลาดจตุจักร',
      'email': 'market@test.com',
      'role': 'เจ้าของตลาด',
      'status': 'active',
    },
    {
      'name': 'ตลาดใหม่เอี่ยม',
      'email': 'newmarket@test.com',
      'role': 'เจ้าของตลาด',
      'status': 'pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text(
          'ผู้ใช้ทั้งหมด',
          style: GoogleFonts.kanit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2D9CDB),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final u = _users[i];
          final isPending = u['status'] == 'pending';

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF2D9CDB).withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF2D9CDB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u['name']!,
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        u['email']!,
                        style: GoogleFonts.kanit(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Role + Status Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D9CDB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u['role']!,
                        style: GoogleFonts.kanit(
                          fontSize: 10,
                          color: const Color(0xFF2D9CDB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isPending
                            ? const Color(0xFFFFF3CD)
                            : const Color(0xFFDFF7E6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPending ? 'รออนุมัติ' : 'ใช้งานอยู่',
                        style: GoogleFonts.kanit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPending
                              ? const Color(0xFFB45309)
                              : const Color(0xFF0F7A36),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
