import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/leave_model.dart';

class LeaveTab extends StatefulWidget {
  final DashboardProvider dash;
  const LeaveTab({super.key, required this.dash});

  @override
  State<LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends State<LeaveTab> {
  bool _applying = false;
  bool _cancelling = false;
  String? _cancellingId;

  void _showApplyLeaveSheet(BuildContext context) {
    final dash = widget.dash;
    String? selectedTypeId;
    DateTime? startDate;
    DateTime? endDate;
    final reasonCtrl = TextEditingController();
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
          Future<void> pickDate(bool isStart) async {
            final d = await showDatePicker(
              context: ctx,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (d != null) {
              setSS(() {
                if (isStart) startDate = d;
                else endDate = d;
              });
            }
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
                Text('Apply Leave',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleLarge?.color)),

                const SizedBox(height: 20),
                // Leave type dropdown
                DropdownButtonFormField<String>(
                  value: selectedTypeId,
                  decoration: InputDecoration(
                    labelText: 'Leave Type',
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
                  ),
                  dropdownColor: theme.cardTheme.color,

                  items: dash.leaveBalance.map((lb) => DropdownMenuItem(
                    value: lb.leaveTypeId,
                    child: Text(lb.leaveType,
                        style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color)),
                  )).toList(),

                  validator: (v) => v == null ? 'Select leave type' : null,
                  onChanged: (v) => setSS(() => selectedTypeId = v),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _DateField(
                    label: 'Start Date',
                    value: startDate,
                    onTap: () => pickDate(true),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _DateField(
                    label: 'End Date',
                    value: endDate,
                    onTap: () => pickDate(false),
                  )),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    labelText: 'Reason',
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
                  ),

                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter reason' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: startDate == null || endDate == null || selectedTypeId == null
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            Navigator.pop(ctx);
                            setState(() => _applying = true);
                            try {
                              await dash.applyLeave(
                                leaveTypeId: selectedTypeId!,
                                startDate: DateFormat('yyyy-MM-dd').format(startDate!),
                                endDate: DateFormat('yyyy-MM-dd').format(endDate!),
                                reason: reasonCtrl.text,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Leave applied successfully! 🎉'),
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
                              if (mounted) setState(() => _applying = false);
                            }
                          },
                    child: Text(_applying ? 'Applying...' : 'Submit Leave',
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

  @override
  Widget build(BuildContext context) {
    final dash = widget.dash;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Header with apply button
        Row(children: [
          Text('Leave Management',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color)),


          const Spacer(),
          ElevatedButton.icon(
            onPressed: _applying ? null : () => _showApplyLeaveSheet(context),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('Apply', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Leave Balance Cards
        if (dash.leaveBalance.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 110,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: dash.leaveBalance.length,
            itemBuilder: (_, i) => _LeaveBalanceDetailCard(lb: dash.leaveBalance[i]),
          ),
          const SizedBox(height: 20),
        ],

        // Leave history
        Text('Leave History',
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color)),

        const SizedBox(height: 10),
        if (dash.leaveRequests.isEmpty)
          _emptyCard(context, 'No leave history found')

        else
          ...dash.leaveRequests.map((req) => _LeaveRequestCard(
            req: req,
            isCancelling: _cancelling && _cancellingId == req.id,
            onCancel: req.status.toLowerCase() == 'pending'
                ? () async {
                    setState(() {
                      _cancelling = true;
                      _cancellingId = req.id;
                    });
                    try {
                      await dash.cancelLeave(req.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Leave cancelled'), backgroundColor: AppColors.success));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString()), backgroundColor: AppColors.error));
                      }
                    } finally {
                      if (mounted) setState(() { _cancelling = false; _cancellingId = null; });
                    }
                  }
                : null,
          )),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const _DateField({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: theme.hintColor)),
          const SizedBox(height: 4),
          Text(
            value != null ? DateFormat('dd MMM yyyy').format(value!) : 'Select date',
            style: GoogleFonts.inter(
                fontSize: 13,
                color: value != null ? theme.textTheme.bodyLarge?.color : theme.hintColor),
          ),
        ]),
      ),
    );
  }
}


class _LeaveBalanceDetailCard extends StatelessWidget {
  final LeaveBalance lb;
  const _LeaveBalanceDetailCard({required this.lb});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),

      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lb.leaveType,
            style: GoogleFonts.inter(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: lb.balance.toStringAsFixed(0),
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w800,
                    color: theme.textTheme.titleLarge?.color)),
            TextSpan(
                text: ' available',
                style: GoogleFonts.inter(fontSize: 11, color: theme.hintColor)),
          ]),
        ),

        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: lb.usagePercent,
            minHeight: 4,
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(
                lb.balance > 0 ? AppColors.primary : AppColors.error),
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Text('Used: ${lb.usedLeaves.toStringAsFixed(0)}',
              style: GoogleFonts.inter(fontSize: 10, color: theme.hintColor)),
          const Spacer(),
          Text('Total: ${lb.totalLeaves.toStringAsFixed(0)}',
              style: GoogleFonts.inter(fontSize: 10, color: theme.hintColor)),
        ]),

      ]),
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final LeaveRequest req;
  final bool isCancelling;
  final VoidCallback? onCancel;
  const _LeaveRequestCard(
      {required this.req, this.isCancelling = false, this.onCancel});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(req.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),

      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(req.leaveType,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color)),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(req.status.toUpperCase(),
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
          '${_fmtDate(req.fromDate)} → ${_fmtDate(req.toDate)}',
          style: GoogleFonts.inter(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
        ),
        if (req.totalDays != null) ...[
          const SizedBox(height: 2),
          Text('${req.totalDays?.toStringAsFixed(0)} day(s)',
              style: GoogleFonts.inter(fontSize: 11, color: theme.hintColor)),
        ],

        if (onCancel != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isCancelling ? null : onCancel,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(isCancelling ? 'Cancelling...' : 'Cancel Leave',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ]),
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

Widget _emptyCard(BuildContext context, String msg) {
  final theme = Theme.of(context);
  return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(msg,
          style: GoogleFonts.inter(fontSize: 13, color: theme.hintColor)));
}

