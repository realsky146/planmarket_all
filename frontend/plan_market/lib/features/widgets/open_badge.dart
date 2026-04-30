// lib/widgets/open_badge.dart

import 'package:flutter/material.dart';

class OpenBadge extends StatelessWidget {
  const OpenBadge({super.key, required this.isOpen});
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFDFF7E6) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isOpen ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'เปิดอยู่' : 'ปิดอยู่',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isOpen ? const Color(0xFF0F7A36) : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }
}
