import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/attendance_model.dart';
import '../../../models/extended_models.dart';

class AttendanceTab extends StatelessWidget {
  final DashboardProvider dash;
  const AttendanceTab({super.key, required this.dash});

  @override
  Widget build(BuildContext context) {
    final s = dash.attendanceSummary;
    final history = dash.attendanceHistory;
    final otRequests = dash.otRequests;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text('Attendance Overview',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),

        // Stats grid
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _AttendStat(label: 'Present', value: s.present, color: AppColors.success),
            _AttendStat(label: 'Absent', value: s.absent, color: AppColors.error),
            _AttendStat(label: 'Leaves', value: s.leaves, color: AppColors.warning),
            _AttendStat(label: 'Holidays', value: s.holidays, color: AppColors.info),
            _AttendStat(label: 'LWP', value: s.lwp, color: const Color(0xFFFF8C00)),
            _AttendStat(label: 'Total Days', value: s.workingDays, color: AppColors.textMuted),
          ],
        ),
        const SizedBox(height: 20),

        // Recent Attendance
        Text('Recent Attendance',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        if (history.isEmpty)
          _emptyCard('No attendance records found')
        else
          ...history.map((rec) => _AttendanceCard(rec: rec)),

        if (otRequests.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Overtime Requests',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...otRequests.map((req) => _OTRequestCard(req: req, dash: dash)),
        ],
      ],
    );
  }
}

class _AttendStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _AttendStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$value',
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10, color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ]),
    );
  }
}

class _AttendanceCard extends StatefulWidget {
  final AttendanceRecord rec;
  const _AttendanceCard({required this.rec});

  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<_AttendanceCard> {
  bool _expanded = false;

  Color _statusColor(String s) {
    switch (s) {
      case 'present': case 'late': case 'half_day': return AppColors.success;
      case 'absent': return AppColors.error;
      case 'holiday': case 'leave': return AppColors.info;
      case 'lwp': return const Color(0xFFFF8C00);
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = widget.rec;
    final sColor = _statusColor(rec.status);
    final haslogs = rec.logs.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: haslogs ? () => setState(() => _expanded = !_expanded) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                  width: 6,
                  height: 30,
                  decoration: BoxDecoration(
                      color: sColor, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_fmtDate(rec.date),
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(_dayName(rec.date),
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textMuted)),
                    ]),
              ),
              Text(rec.totalHoursFormatted,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(rec.status.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: sColor)),
              ),
              if (haslogs)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
            ]),
          ),
        ),
        if (_expanded && haslogs)
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(children: [
              ...rec.logs.asMap().entries.map((e) {
                final idx = e.key;
                final log = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('S${idx + 1}',
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'In: ${_fmtTime(log.checkIn)}  |  Out: ${log.checkOut != null ? _fmtTime(log.checkOut!) : "Active"}',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    if (log.location != null && log.location!.isNotEmpty)
                      Icon(Icons.location_on_rounded,
                          color: AppColors.textMuted, size: 12),
                  ]),
                );
              }),
            ]),
          ),
      ]),
    );
  }

  String _fmtDate(String d) {
    try { return DateFormat('dd MMM yyyy').format(DateTime.parse(d)); } catch (_) { return d; }
  }

  String _dayName(String d) {
    try { return DateFormat('EEEE').format(DateTime.parse(d)); } catch (_) { return ''; }
  }

  String _fmtTime(String t) {
    try { return DateFormat('hh:mm a').format(DateTime.parse(t)); } catch (_) { return t; }
  }
}

class _OTRequestCard extends StatelessWidget {
  final OvertimeRequest req;
  final DashboardProvider dash;
  const _OTRequestCard({required this.req, required this.dash});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'submitted': return AppColors.info;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sColor = _statusColor(req.status);
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
            Text(
              '${_fmtTime(req.startTime)} – ${_fmtTime(req.endTime)}',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            Text(
              req.formattedDuration,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
            ),
            if (req.reason != null && req.reason!.isNotEmpty)
              Text(req.reason!,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: sColor.withAlpha(22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(req.status.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700, color: sColor)),
        ),
        if (req.status == 'draft') ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => dash.actionOT(req.id, 'CONFIRM'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text('Submit',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ]),
    );
  }

  String _fmtTime(String t) {
    try { return DateFormat('hh:mm a').format(DateTime.parse(t)); } catch (_) { return t; }
  }
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
