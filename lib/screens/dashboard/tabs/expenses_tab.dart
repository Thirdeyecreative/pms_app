import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/expense_model.dart';
import '../../../services/expense_service.dart';

class ExpensesTab extends StatefulWidget {
  final DashboardProvider dash;
  const ExpensesTab({super.key, required this.dash});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  bool _submitting = false;

  void _showSubmitExpense(BuildContext context) {
    final dash = widget.dash;
    final categories = dash.expenseCategories;
    String? selectedCatId;
    final amtCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? expenseDate;
    final formKey = GlobalKey<FormState>();

    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),

      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: StatefulBuilder(builder: (ctx, setSS) {
          Future<void> pickDate() async {
            final d = await showDatePicker(
              context: ctx,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(primary: AppColors.primary)),
                child: child!,
              ),
            );
            if (d != null) setSS(() => expenseDate = d);
          }

          return SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Text('Submit Expense',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleLarge?.color)),

                const SizedBox(height: 20),

                if (categories.isEmpty)
                  Text('No expense categories available',
                      style: GoogleFonts.inter(color: AppColors.textMuted))
                else
                  DropdownButtonFormField<String>(
                    value: selectedCatId,
                    decoration: _inputDeco(context, 'Category'),
                    dropdownColor: theme.cardTheme.color,

                    items: categories.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name,
                          style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color)),
                    )).toList(),

                    validator: (v) => v == null ? 'Select category' : null,
                    onChanged: (v) => setSS(() => selectedCatId = v),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amtCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                  decoration: _inputDeco(context, 'Amount (₹)'),

                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter amount';
                    if (double.tryParse(v) == null) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),

                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.textMuted, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        expenseDate != null
                            ? DateFormat('dd MMM yyyy').format(expenseDate!)
                            : 'Expense Date',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: expenseDate != null
                                ? theme.textTheme.bodyLarge?.color
                                : theme.hintColor),
                      ),

                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                  decoration: _inputDeco(context, 'Description'),

                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate() ||
                          expenseDate == null) {
                        if (expenseDate == null) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('Please select expense date'),
                            backgroundColor: AppColors.error,
                          ));
                        }
                        return;
                      }
                      Navigator.pop(ctx);
                      setState(() => _submitting = true);
                      try {
                        final svc = ExpenseService();
                        final claim = await svc.createClaim(
                          categoryId: selectedCatId!,
                          amount: double.parse(amtCtrl.text),
                          expenseDate: DateFormat('yyyy-MM-dd').format(expenseDate!),
                          description: descCtrl.text,
                        );
                        dash.addExpense(claim);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Expense submitted!'),
                                backgroundColor: AppColors.success,
                              ));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppColors.error,
                          ));
                        }
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
                    child: Text('Submit Expense',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          );
        }),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'approved': case 'reimbursed': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dash = widget.dash;
    final theme = Theme.of(context);
    final exps = dash.expenses;
    final totalApproved = exps
        .where((e) => ['approved', 'reimbursed'].contains(e.status.toLowerCase()))
        .fold(0.0, (sum, e) => sum + e.amount);
    final pending = exps.where((e) => e.status.toLowerCase() == 'pending').length;
    final approved =
        exps.where((e) => e.status.toLowerCase() == 'approved').length;
    final rejected =
        exps.where((e) => e.status.toLowerCase() == 'rejected').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(children: [
          Text('My Expenses',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _submitting ? null : () => _showSubmitExpense(context),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('Submit',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        // Stats
        Row(children: [
          _StatCard(
            label: 'Total Approved',
            value: '₹${NumberFormat('#,##,###').format(totalApproved.round())}',
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _StatCard(label: 'Pending', value: '$pending', color: AppColors.warning),
          const SizedBox(width: 8),
          _StatCard(label: 'Approved', value: '$approved', color: AppColors.info),
          const SizedBox(width: 8),
          _StatCard(label: 'Rejected', value: '$rejected', color: AppColors.error),
        ]),
        const SizedBox(height: 20),
        Text('Expense History',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color)),

        const SizedBox(height: 10),
        if (exps.isEmpty)
          _emptyCard(context, 'No expenses submitted yet')

        else
          ...exps.map((e) {
            final sColor = _statusColor(e.status);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),

              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_rounded,
                      color: AppColors.primaryLight, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.description,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.titleMedium?.color),
                            maxLines: 1,

                            overflow: TextOverflow.ellipsis),
                        Text(e.categoryName,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.textMuted)),
                      ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    '₹${NumberFormat('#,##,###').format(e.amount.round())}',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleMedium?.color),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: sColor.withAlpha(22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(e.status.toUpperCase(),
                        style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: sColor)),
                  ),
                ]),
              ]),
            );
          }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color),
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: GoogleFonts.inter(fontSize: 9, color: theme.hintColor),
              textAlign: TextAlign.center),

        ]),
      ),
    );
  }
}

InputDecoration _inputDeco(BuildContext context, String label) {
  final theme = Theme.of(context);
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.inter(color: theme.hintColor),
    filled: true,
    fillColor: theme.cardTheme.color,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.dividerColor),
    ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  ),
  );
}

Widget _emptyCard(BuildContext context, String msg) {
  final theme = Theme.of(context);
  return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(msg,
          style: GoogleFonts.inter(fontSize: 13, color: theme.hintColor)));
}

