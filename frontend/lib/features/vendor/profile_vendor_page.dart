import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/select_role_page.dart';
import 'vendor_home.dart';
import 'vendor_market_list_page.dart';
import 'favorite_vendor_page.dart';
import 'vendor_shop_info_page.dart';
import 'vendor_edit_profile_page.dart';
import '../../services/api_service.dart';

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  int _currentIndex = 4;
  bool _isLoading = true;
  
  String _name = '';
  String _email = '';
  String _phone = '';
  String _imageUrl = '';
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('userId') ?? '0') ?? 0;
      
      setState(() {
        _userId = userId;
        _name = prefs.getString('userName') ?? '';
        _email = prefs.getString('email') ?? '';
        _imageUrl = prefs.getString('userImage') ?? '';
      });

      if (userId > 0) {
        // ดึงข้อมูลจาก API
        final response = await ApiService.getUsers();
        if (response['success'] == true) {
          final users = response['data'] as List;
          final user = users.firstWhere(
            (u) => u['id'] == userId,
            orElse: () => null,
          );
          if (user != null && mounted) {
            setState(() {
              _name = user['name'] ?? _name;
              _email = user['email'] ?? _email;
              _phone = user['phone'] ?? '';
              _imageUrl = user['image_url'] ?? '';
            });
            // บันทึกลง SharedPreferences
            await prefs.setString('userName', _name);
            await prefs.setString('userImage', _imageUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ออกจากระบบ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการออกจากระบบหรือไม่?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('ยกเลิก', style: GoogleFonts.kanit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('ออกจากระบบ', style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SelectRolePage()),
          (route) => false,
        );
      }
    }
  }

  void _navigateToPage(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Widget? page;
      switch (index) {
        case 0: page = const VendorFavoritePage(); break;
        case 1: page = const VendorMarketListPage(); break;
        case 2: page = VendorHome(); break;
        case 3: page = const VendorShopInfoPage(); break;
        case 4: return;
      }
      if (page != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8CBC63)))
          : Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CBC63),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _imageUrl.isNotEmpty
                                ? NetworkImage(_imageUrl)
                                : null,
                            backgroundColor: Colors.white,
                            child: _imageUrl.isEmpty
                                ? const Icon(Icons.person, size: 50, color: Color(0xFF8CBC63))
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _name.isEmpty ? 'ผู้ใช้งาน' : _name,
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _email,
                        style: GoogleFonts.kanit(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Info Card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ข้อมูลส่วนตัว', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
                                  TextButton.icon(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const VendorEditProfilePage()),
                                      );
                                      _loadProfile();
                                    },
                                    icon: const Icon(Icons.edit, size: 16, color: Color(0xFF8CBC63)),
                                    label: Text('แก้ไข', style: GoogleFonts.kanit(color: const Color(0xFF8CBC63))),
                                  ),
                                ],
                              ),
                              const Divider(),
                              _infoRow('ชื่อบัญชี', _name.isEmpty ? '-' : _name),
                              _infoRow('เบอร์โทรศัพท์', _phone.isEmpty ? '-' : _phone),
                              _infoRow('E-mail', _email.isEmpty ? '-' : _email, locked: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Edit Shop Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8CBC63),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const VendorEditProfilePage()),
                              );
                              _loadProfile();
                            },
                            child: Text('แก้ไขข้อมูลร้านค้า', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _signOut,
                            child: Text('ออกจากระบบ', style: GoogleFonts.kanit(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _infoRow(String label, String value, {bool locked = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              if (locked)
                const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
            ],
          ),
          if (locked)
            Text('อีเมลไม่สามารถเปลี่ยนแปลงได้', style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.favorite_border_rounded, 'label': 'ถูกใจ'},
      {'icon': Icons.storefront_rounded, 'label': 'ตลาด'},
      {'icon': Icons.home_rounded, 'label': 'หน้าแรก'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'ร้านค้า'},
      {'icon': Icons.account_circle_rounded, 'label': 'โปรไฟล์'},
    ];

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF8CBC63),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = _currentIndex == i;
          return GestureDetector(
            onTap: () => _navigateToPage(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  items[i]['label'] as String,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
