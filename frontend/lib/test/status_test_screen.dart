// lib/screens/test/status_test_screen.dart
import 'package:flutter/material.dart';

class StatusTestScreen extends StatelessWidget {
  const StatusTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧪 Test Status Screens')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTestButton(
            context,
            '❌ Booking Rejected',
            Colors.red,
            () => _showRejectedScreen(context),
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            '🔒 Account Locked',
            Colors.orange,
            () => _showLockedScreen(context),
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            '🚫 Zone Full (ล็อคเต็ม)',
            Colors.grey,
            () => _showZoneFullScreen(context),
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            '⏳ Pending Approval',
            Colors.blue,
            () => _showPendingScreen(context),
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            '✅ Booking Approved',
            Colors.green,
            () => _showApprovedScreen(context),
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            '🚫 Account Suspended',
            Colors.red.shade900,
            () => _showSuspendedScreen(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  // ❌ หน้าจอถูกปฏิเสธ
  void _showRejectedScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingStatusScreen(
          status: BookingStatus.rejected,
          title: 'การจองถูกปฏิเสธ',
          message: 'ขออภัย การจองของคุณถูกปฏิเสธ',
          reason: 'เอกสารไม่ครบถ้วน กรุณาอัพโหลดสำเนาบัตรประชาชนใหม่',
          bookingInfo: BookingInfo(
            stallNumber: 'A-001',
            zoneName: 'โซน A - อาหารสด',
            date: '20 ม.ค. 2568',
            shopName: 'ร้านส้มตำแม่นิด',
          ),
        ),
      ),
    );
  }

  // 🔒 หน้าจอถูกล็อค
  void _showLockedScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountStatusScreen(
          status: AccountStatus.locked,
          title: 'บัญชีถูกระงับชั่วคราว',
          message: 'บัญชีของคุณถูกระงับเนื่องจากค้างชำระค่าเช่า',
          reason:
              'ค้างชำระค่าเช่า 2 งวด (ธ.ค. 67 - ม.ค. 68)\nยอดค้างชำระ: ฿6,000',
          actionText: 'ติดต่อแอดมิน',
          unlockDate: '25 ม.ค. 2568',
        ),
      ),
    );
  }

  // 🚫 หน้าจอล็อคเต็ม
  void _showZoneFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ZoneFullScreen(
          zoneName: 'โซน A - อาหารสด',
          totalStalls: 50,
          availableStalls: 0,
          waitingList: 12,
        ),
      ),
    );
  }

  // ⏳ หน้าจอรอการอนุมัติ
  void _showPendingScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingStatusScreen(
          status: BookingStatus.pending,
          title: 'รอการอนุมัติ',
          message: 'การจองของคุณอยู่ระหว่างการพิจารณา',
          bookingInfo: BookingInfo(
            stallNumber: 'B-015',
            zoneName: 'โซน B - เสื้อผ้า',
            date: '22 ม.ค. 2568',
            shopName: 'ร้านเสื้อผ้ามือสอง',
          ),
        ),
      ),
    );
  }

  // ✅ หน้าจออนุมัติแล้ว
  void _showApprovedScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingStatusScreen(
          status: BookingStatus.approved,
          title: 'การจองสำเร็จ!',
          message: 'การจองของคุณได้รับการอนุมัติแล้ว',
          bookingInfo: BookingInfo(
            stallNumber: 'C-008',
            zoneName: 'โซน C - ของใช้ทั่วไป',
            date: '25 ม.ค. 2568',
            shopName: 'ร้านของชำ',
          ),
        ),
      ),
    );
  }

  // 🚫 หน้าจอถูกระงับถาวร
  void _showSuspendedScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountStatusScreen(
          status: AccountStatus.suspended,
          title: 'บัญชีถูกระงับถาวร',
          message: 'บัญชีของคุณถูกระงับเนื่องจากละเมิดกฎระเบียบ',
          reason: 'ขายสินค้าผิดกฎหมาย',
          actionText: 'ยื่นอุทธรณ์',
        ),
      ),
    );
  }
}

// ==================== ENUMS ====================
enum BookingStatus { pending, approved, rejected, cancelled }

enum AccountStatus { active, locked, suspended }

// ==================== MODELS ====================
class BookingInfo {
  final String stallNumber;
  final String zoneName;
  final String date;
  final String shopName;

  const BookingInfo({
    required this.stallNumber,
    required this.zoneName,
    required this.date,
    required this.shopName,
  });
}

// ==================== BOOKING STATUS SCREEN ====================
class BookingStatusScreen extends StatelessWidget {
  final BookingStatus status;
  final String title;
  final String message;
  final String? reason;
  final BookingInfo? bookingInfo;

  const BookingStatusScreen({
    super.key,
    required this.status,
    required this.title,
    required this.message,
    this.reason,
    this.bookingInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: _getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Icon
              _buildStatusIcon(),
              const SizedBox(height: 24),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: _getTextColor().withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Booking Info Card
              if (bookingInfo != null) _buildBookingInfoCard(),
              // Reason Card (for rejected)
              if (reason != null && status == BookingStatus.rejected) ...[
                const SizedBox(height: 16),
                _buildReasonCard(),
              ],
              const Spacer(),
              // Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    double size = 100;

    switch (status) {
      case BookingStatus.pending:
        icon = Icons.hourglass_top_rounded;
        color = Colors.white;
        break;
      case BookingStatus.approved:
        icon = Icons.check_circle_rounded;
        color = Colors.white;
        break;
      case BookingStatus.rejected:
        icon = Icons.cancel_rounded;
        color = Colors.white;
        break;
      case BookingStatus.cancelled:
        icon = Icons.remove_circle_rounded;
        color = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  Widget _buildBookingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('🏪', 'ร้านค้า', bookingInfo!.shopName),
          const Divider(height: 24),
          _buildInfoRow('📍', 'ล็อค', bookingInfo!.stallNumber),
          const Divider(height: 24),
          _buildInfoRow('🗺️', 'โซน', bookingInfo!.zoneName),
          const Divider(height: 24),
          _buildInfoRow('📅', 'วันที่', bookingInfo!.date),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'เหตุผลที่ปฏิเสธ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason!,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (status) {
      case BookingStatus.rejected:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('จองใหม่', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'กลับหน้าหลัก',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      case BookingStatus.pending:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ยกเลิกการจอง'),
          ),
        );
      case BookingStatus.approved:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ดูรายละเอียด', style: TextStyle(fontSize: 16)),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case BookingStatus.pending:
        return Colors.blue;
      case BookingStatus.approved:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.cancelled:
        return Colors.grey;
    }
  }

  Color _getTextColor() => Colors.white;
}

// ==================== ACCOUNT STATUS SCREEN ====================
class AccountStatusScreen extends StatelessWidget {
  final AccountStatus status;
  final String title;
  final String message;
  final String? reason;
  final String? actionText;
  final String? unlockDate;

  const AccountStatusScreen({
    super.key,
    required this.status,
    required this.title,
    required this.message,
    this.reason,
    this.actionText,
    this.unlockDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          status == AccountStatus.locked ? Colors.orange : Colors.red,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Lock Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == AccountStatus.locked
                      ? Icons.lock_rounded
                      : Icons.block_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Reason Card
              if (reason != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'รายละเอียด',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        reason!,
                        style: TextStyle(
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      if (unlockDate != null) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.event, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'ปลดล็อคอัตโนมัติ: $unlockDate',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              const Spacer(),
              // Action Buttons
              if (actionText != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.support_agent),
                    label: Text(actionText!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: status == AccountStatus.locked
                          ? Colors.orange
                          : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ออกจากระบบ',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ZONE FULL SCREEN ====================
class ZoneFullScreen extends StatelessWidget {
  final String zoneName;
  final int totalStalls;
  final int availableStalls;
  final int waitingList;

  const ZoneFullScreen({
    super.key,
    required this.zoneName,
    required this.totalStalls,
    required this.availableStalls,
    required this.waitingList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('ไม่สามารถจองได้'),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 80,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            const Text(
              'ล็อคเต็มทั้งหมดแล้ว',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              zoneName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            // Stats Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    'ล็อคทั้งหมด',
                    '$totalStalls ล็อค',
                    Icons.grid_view_rounded,
                    Colors.blue,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    'ล็อคว่าง',
                    '$availableStalls ล็อค',
                    Icons.check_circle_outline,
                    availableStalls > 0 ? Colors.green : Colors.red,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    'คิวรอจอง',
                    '$waitingList คน',
                    Icons.people_outline,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'คุณสามารถลงทะเบียนเข้าคิวรอได้ เมื่อมีล็อคว่างระบบจะแจ้งเตือนอัตโนมัติ',
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('เลือกโซนอื่น'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ลงทะเบียนเข้าคิวเรียบร้อย!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('เข้าคิวรอ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey))),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}
