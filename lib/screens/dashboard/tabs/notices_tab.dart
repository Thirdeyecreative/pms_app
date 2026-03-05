import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../providers/dashboard_provider.dart';


class NoticesTab extends StatelessWidget {
  final DashboardProvider dash;
  const NoticesTab({super.key, required this.dash});

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high': return AppColors.error;
      case 'medium': return AppColors.warning;
      default: return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notices = dash.announcements;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text('Noticeboard',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: theme.textTheme.titleLarge?.color)),

        const SizedBox(height: 16),
        if (notices.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(children: [
                Icon(Icons.notifications_none_rounded,
                    color: theme.hintColor.withAlpha(80), size: 48),
                const SizedBox(height: 12),
                Text('No announcements',
                    style: GoogleFonts.inter(
                        fontSize: 15, color: theme.hintColor)),

              ]),
            ),
          )
        else
          ...notices.map((a) {
            final color = _priorityColor(a.priority);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),

              child: Column(children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withAlpha(18),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Expanded(
                      child: Text(a.title,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.titleMedium?.color)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(a.priority.toUpperCase(),
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(a.message,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: theme.textTheme.bodyMedium?.color)),

                ),
              ]),
            );
          }),
      ],
    );
  }
}
