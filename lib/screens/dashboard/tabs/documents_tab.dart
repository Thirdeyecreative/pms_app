import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../providers/dashboard_provider.dart';

class DocumentsTab extends StatelessWidget {
  final DashboardProvider dash;
  const DocumentsTab({super.key, required this.dash});

  @override
  Widget build(BuildContext context) {
    final emp = dash.employee;
    final docs = emp?.documents ?? [];
    final selfDocs = docs.where((d) => d['uploaded_by'] == 'self').toList();
    final adminDocs = docs.where((d) => d['uploaded_by'] == 'admin').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text('My Documents',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        _DocSection(title: 'My Uploads', docs: selfDocs, iconColor: AppColors.primary),
        const SizedBox(height: 16),
        _DocSection(title: 'Employment Documents', docs: adminDocs, iconColor: AppColors.success),
      ],
    );
  }
}

class _DocSection extends StatelessWidget {
  final String title;
  final List docs;
  final Color iconColor;
  const _DocSection(
      {required this.title, required this.docs, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      if (docs.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text('No documents found',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
        )
      else
        ...docs.map((doc) => _DocTile(doc: doc, iconColor: iconColor)),
    ]);
  }
}

class _DocTile extends StatelessWidget {
  final dynamic doc;
  final Color iconColor;
  const _DocTile({required this.doc, required this.iconColor});

  String _fmtDate(String? d) {
    if (d == null) return 'N/A';
    try { return DateFormat('dd MMM yyyy').format(DateTime.parse(d)); } catch (_) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(22),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.description_rounded, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc['name'] ?? 'Document',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text('Uploaded: ${_fmtDate(doc['created_at'])}',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ]),
        ),
        if (doc['url'] != null)
          IconButton(
            icon: const Icon(Icons.download_rounded,
                color: AppColors.textMuted, size: 20),
            onPressed: () {
              // URL launch would go here; shown as info snack for now
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Opening: ${doc['url']}',
                    style: GoogleFonts.inter(fontSize: 12)),
                backgroundColor: AppColors.primary,
              ));
            },
          ),
      ]),
    );
  }
}
