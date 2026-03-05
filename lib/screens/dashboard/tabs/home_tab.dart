import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/leave_model.dart';

class HomeTab extends StatelessWidget {
  final DashboardProvider dash;
  final VoidCallback? onApplyLeave;
  const HomeTab({super.key, required this.dash, this.onApplyLeave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = dash.attendanceSummary;
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: theme.cardTheme.color,

      onRefresh: () async {
        final auth = context.read<AuthProvider>();
        final id = auth.currentUser?.id ?? '';
        if (id.isNotEmpty) await dash.loadAll(id);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Quick Actions
          _sectionLabel(context, 'Quick Actions'),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _QuickAction(
                icon: Icons.calendar_today_rounded,
                label: 'Apply Leave',
                color: AppColors.primary,
                onTap: () => onApplyLeave?.call(),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.history_rounded,
                label: 'Regularize',
                color: AppColors.warning,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.receipt_long_rounded,
                label: 'View Payslip',
                color: AppColors.accent,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.attach_money_rounded,
                label: 'Submit Expense',
                color: AppColors.accentWarm,
                onTap: () => onApplyLeave?.call(), // Navigate to Expenses tab via parent callback
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Pending Tasks (Matching React)
          _sectionLabel(context, 'Pending Tasks'),
          const SizedBox(height: 10),
          _PendingTaskRow(title: 'Submit investment proofs', deadline: '15 Jan 2026', icon: Icons.description_rounded),
          _PendingTaskRow(title: 'Complete mandatory training', deadline: '20 Jan 2026', icon: Icons.school_rounded),
          const SizedBox(height: 20),

          // Attendance Overview
          _sectionLabel(context, 'Attendance This Month'),
          const SizedBox(height: 10),
          Row(children: [
            _StatChip(label: 'Present', value: s.present, color: AppColors.success),
            const SizedBox(width: 8),
            _StatChip(label: 'Absent', value: s.absent, color: AppColors.error),
            const SizedBox(width: 8),
            _StatChip(label: 'Leaves', value: s.leaves, color: AppColors.warning),
            const SizedBox(width: 8),
            _StatChip(label: 'Holiday', value: s.holidays, color: AppColors.info),
          ]),
          const SizedBox(height: 20),

          // Leave Balance
          _sectionLabel(context, 'Leave Balance'),
          const SizedBox(height: 10),
          if (dash.leaveBalance.isEmpty)
            _emptyCard(context, 'No leave balance data')
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dash.leaveBalance.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) =>
                    _LeaveBalanceCard(lb: dash.leaveBalance[i]),
              ),
            ),
          const SizedBox(height: 20),

          // Recent Payslips
          if (dash.payslips.isNotEmpty) ...[
            _sectionLabel(context, 'Recent Payslips'),
            const SizedBox(height: 10),
            ...dash.payslips.take(3).map((p) => _PayslipRow(p: p)),
            const SizedBox(height: 20),
          ],

          // Announcements
          _sectionLabel(context, 'Announcements'),
          const SizedBox(height: 10),
          if (dash.announcements.isEmpty)
            _emptyCard(context, 'No announcements')
          else
            ...dash.announcements.take(3).map((a) => _AnnouncementRow(
                  title: a.title,
                  message: a.message,
                  priority: a.priority,
                )),
        ],

      ),
    );
  }
}

Widget _sectionLabel(BuildContext context, String text) => Text(text,
    style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.titleMedium?.color));


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


class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 90,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withAlpha(22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}


class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(children: [
          Text('$value',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 10, color: theme.hintColor)),
        ]),
      ),
    );
  }
}


class _LeaveBalanceCard extends StatelessWidget {
  final LeaveBalance lb;
  const _LeaveBalanceCard({required this.lb});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(lb.leaveType,
              style: GoogleFonts.inter(
                  fontSize: 10, color: theme.textTheme.bodyMedium?.color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: lb.balance.toStringAsFixed(0),
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleLarge?.color)),
              TextSpan(
                  text: '/${lb.totalLeaves.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: theme.hintColor)),
            ]),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: lb.usagePercent,
              minHeight: 3,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                  lb.balance > 0 ? AppColors.primary : AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}


class _PayslipRow extends StatelessWidget {
  final dynamic p;
  const _PayslipRow({required this.p});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(22),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: AppColors.primaryLight, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(p.displayMonth,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color)),
        ),
        Text(
          '₹${NumberFormat('#,##,###').format(p.netSalary.round())}',
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.titleLarge?.color),
        ),
      ]),
    );
  }
}


class _AnnouncementRow extends StatelessWidget {
  final String title;
  final String message;
  final String priority;
  const _AnnouncementRow(
      {required this.title, required this.message, required this.priority});

  Color _color() {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color)),
            const SizedBox(height: 3),
            Text(message,
                style: GoogleFonts.inter(
                    fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }
}

class _PendingTaskRow extends StatelessWidget {
  final String title;
  final String deadline;
  final IconData icon;
  const _PendingTaskRow({required this.title, required this.deadline, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color)),
            Text('Deadline: $deadline', style: GoogleFonts.inter(fontSize: 11, color: theme.hintColor)),
          ]),
        ),
        Icon(Icons.chevron_right_rounded, color: theme.hintColor, size: 20),
      ]),
    );
  }
}

