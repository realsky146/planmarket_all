// lib/features/stall_recommendation/widgets/recommended_stall_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/recommendation_models.dart';

class RecommendedStallCard extends StatelessWidget {
  final RecommendedStall stall;
  final int rank;
  final VoidCallback onSelect;
  final bool isSelected;

  const RecommendedStallCard({
    super.key,
    required this.stall,
    required this.rank,
    required this.onSelect,
    this.isSelected = false,
  });

  // ❌ ลบ saveUserSelection() ออก - มันควรอยู่ใน recommendation_service.dart

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8CBC63) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF8CBC63).withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRankBadge(),
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      stall.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.storefront, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                stall.marketName,
                                style: GoogleFonts.kanit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (stall.isFromSameOwner)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '⭐ เจ้าของเดิม',
                                  style: GoogleFonts.kanit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ล็อค ${stall.stallCode} • ${stall.zone}',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.straighten,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              stall.size,
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 2),
                            Text(
                              '${stall.distance} กม.',
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '฿${stall.price.toInt()}',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8CBC63),
                        ),
                      ),
                      Text(
                        '/วัน',
                        style: GoogleFonts.kanit(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _buildStatChip(
                    icon: Icons.people_rounded,
                    label: 'คนเยอะ ${stall.trafficScore}%',
                    color: _getTrafficColor(stall.trafficScore),
                  ),
                  const SizedBox(width: 8),
                  if (stall.hasEvent)
                    _buildStatChip(
                      icon: Icons.celebration_rounded,
                      label: 'มีอีเว้นท์',
                      color: const Color(0xFFEC4899),
                    ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8CBC63), Color(0xFF6BA84A)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'ตรงใจ ${stall.matchScore.toInt()}%',
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (stall.matchedPreferences.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: stall.matchedPreferences.map((pref) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: pref.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${pref.icon} ${pref.title}',
                        style: GoogleFonts.kanit(
                          fontSize: 10,
                          color: pref.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    Color bgColor;
    Color textColor;
    String emoji;

    switch (rank) {
      case 1:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        emoji = '🥇';
        break;
      case 2:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        emoji = '🥈';
        break;
      case 3:
        bgColor = const Color(0xFFFED7AA);
        textColor = const Color(0xFFEA580C);
        emoji = '🥉';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        emoji = '#$rank';
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          emoji,
          style: GoogleFonts.kanit(
            fontSize: rank > 3 ? 11 : 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.kanit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrafficColor(int score) {
    if (score >= 70) return const Color(0xFF10B981);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
