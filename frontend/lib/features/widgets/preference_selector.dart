// lib/features/stall_recommendation/widgets/preference_selector.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/recommendation_models.dart';

class PreferenceSelector extends StatefulWidget {
  final List<StallPreference> selectedPreferences;
  final ValueChanged<List<StallPreference>> onChanged;
  final int maxSelections;

  const PreferenceSelector({
    super.key,
    required this.selectedPreferences,
    required this.onChanged,
    this.maxSelections = 3,
  });

  @override
  State<PreferenceSelector> createState() => _PreferenceSelectorState();
}

class _PreferenceSelectorState extends State<PreferenceSelector> {
  late List<StallPreference> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedPreferences);
  }

  void _togglePreference(StallPreference pref) {
    setState(() {
      if (_selected.contains(pref)) {
        _selected.remove(pref);
      } else if (_selected.length < widget.maxSelections) {
        _selected.add(pref);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เลือกได้สูงสุด ${widget.maxSelections} ข้อ',
              style: GoogleFonts.kanit(),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '🎯 เลือกความต้องการ',
              style: GoogleFonts.kanit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF8CBC63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selected.length}/${widget.maxSelections}',
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8CBC63),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'เลือกได้สูงสุด ${widget.maxSelections} ข้อ เพื่อให้ระบบหาล็อคที่เหมาะสมที่สุด',
          style: GoogleFonts.kanit(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StallPreference.values.map((pref) {
            final isSelected = _selected.contains(pref);
            final order = isSelected ? _selected.indexOf(pref) + 1 : 0;

            return GestureDetector(
              onTap: () => _togglePreference(pref),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? pref.color.withOpacity(0.15) : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? pref.color : Colors.grey!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: pref.color.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: pref.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$order',
                            style: GoogleFonts.kanit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      pref.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pref.title,
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? pref.color : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
