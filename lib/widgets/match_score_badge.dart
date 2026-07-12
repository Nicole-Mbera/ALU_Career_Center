import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class MatchScoreBadge extends StatelessWidget {
  final double score; // 0.0 – 1.0

  const MatchScoreBadge({super.key, required this.score});

  Color get _color {
    if (score >= 0.7) return AppColors.matchHigh;
    if (score >= 0.4) return AppColors.matchMid;
    return AppColors.matchLow;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        '$pct% match',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
