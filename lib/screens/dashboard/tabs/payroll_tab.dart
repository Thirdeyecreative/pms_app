import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../providers/dashboard_provider.dart';

class PayrollTab extends StatefulWidget {
  final DashboardProvider dash;
  const PayrollTab({super.key, required this.dash});

  @override
  State<PayrollTab> createState() => _PayrollTabState();
}

class _PayrollTabState extends State<PayrollTab> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final dash = widget.dash;
    final salary = dash.activeSalary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Salary Structure Card
        _SectionHeader(title: 'Salary Information'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: salary == null
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.textMuted.withAlpha(80), size: 40),
                    const SizedBox(height: 12),
                    Text('No active salary structure found',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted)),
                  ]),
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Gross Annual
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(30),
                          AppColors.primaryDark.withAlpha(15)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withAlpha(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gross Annual Salary',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text(
                          '₹${NumberFormat('#,##,###').format(salary.grossSalary.round())}',
                          style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryLight),
                        ),
                        Text(
                          'Effective from: ${_fmtDate(salary.effectiveFrom)}',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Components
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text('Key Components',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 10),
                  ...salary.items
                      .take(_showAll ? salary.items.length : 3)
                      .map((item) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Row(children: [
                              Expanded(
                                child: Text(item.componentName,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                              ),
                              Text(
                                '₹${NumberFormat('#,##,###').format(item.amount.round())}',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                            ]),
                          )),
                  if (salary.items.length > 3)
                    TextButton(
                      onPressed: () => setState(() => _showAll = !_showAll),
                      child: Text(
                        _showAll
                            ? 'View Less ▲'
                            : '+ ${salary.items.length - 3} more components ▼',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                  const SizedBox(height: 8),
                ]),
        ),
        const SizedBox(height: 20),

        // Payslip History
        _SectionHeader(title: 'Payslip History'),
        const SizedBox(height: 10),
        if (dash.payslips.isEmpty)
          _emptyCard('No payslips found')
        else
          ...dash.payslips.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                    child: const Icon(Icons.description_rounded,
                        color: AppColors.primaryLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.displayMonth,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                      Text(
                            p.displayMonth,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      '₹${NumberFormat('#,##,###').format(p.netSalary.round())}',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Paid',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success)),
                    ),
                  ]),
                ]),
              )),
      ],
    );
  }

  String _fmtDate(String d) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));
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
