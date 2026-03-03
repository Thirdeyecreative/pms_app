import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/extended_models.dart';

class TaxTab extends StatelessWidget {
  final DashboardProvider dash;
  const TaxTab({super.key, required this.dash});

  @override
  Widget build(BuildContext context) {
    final emp = dash.employee;
    final taxRegime = emp?.taxRegime ?? 'old';
    final decls = dash.taxDeclarations;
    final f16s = dash.form16s;

    final totalDeclared = decls.fold(0.0, (s, d) => s + d.declaredAmount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text('Tax & Investment Declarations',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 16),

        // Summary cards
        Row(children: [
          _TaxCard(
            label: 'Declared Investment',
            value: '₹${_fmt(totalDeclared)}',
            sub: 'Total',
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          _TaxCard(
            label: 'Tax Regime',
            value: taxRegime.toLowerCase() == 'new' ? 'New' : 'Old',
            sub: 'FY 2025-26',
            color: AppColors.primary,
          ),
        ]),
        const SizedBox(height: 20),

        // Investment Declarations
        Text('Investment Declarations',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        if (decls.isEmpty)
          _emptyCard('No tax declarations found')
        else
          ...decls.map((d) => _DeclCard(d: d, dash: dash, context: context)),

        const SizedBox(height: 20),

        // Form 16
        Text('My Form 16',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        if (f16s.isEmpty)
          _emptyCard('No Form 16 available')
        else
          ...f16s.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
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
                      color: AppColors.primary.withAlpha(22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.article_rounded,
                        color: AppColors.primaryLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Form 16 – FY ${f.financialYear}',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Text(
                            'Generated ${f.generatedAt?.substring(0, 10) ?? ''}',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ]),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Form 16 download coming soon'),
                        backgroundColor: AppColors.primary,
                      ));
                    },
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: Text('Download',
                        style: GoogleFonts.inter(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ]),
              )),
      ],
    );
  }

  String _fmt(double v) {
    if (v < 1000) return v.round().toString();
    return v.round().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  }
}

class _TaxCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _TaxCard(
      {required this.label,
      required this.value,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(sub,
              style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

Widget _DeclCard(
    {required TaxDeclaration d,
    required DashboardProvider dash,
    required BuildContext context}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.glassBorder),
    ),
    child: Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${d.sectionName} – ${d.sectionDescription}',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            'Declared: ₹${d.declaredAmount.round()}  |  Max: ₹${d.maxLimit.round()}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
          ),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('Verified',
            style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.success)),
      ),
      const SizedBox(width: 6),
      IconButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text('Delete Declaration',
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              content: Text('Are you sure you want to delete this declaration?',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Cancel',
                        style: GoogleFonts.inter(color: AppColors.textMuted))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Delete',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            try {
              await dash.deleteTaxDeclaration(d.id);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Declaration deleted'),
                backgroundColor: AppColors.success,
              ));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppColors.error,
              ));
            }
          }
        },
        icon: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ]),
  );
}

Widget _emptyCard(String msg) => Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(msg,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)));
