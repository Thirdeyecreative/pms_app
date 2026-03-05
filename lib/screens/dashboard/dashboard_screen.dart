import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'tabs/home_tab.dart';
import 'tabs/attendance_tab.dart';
import 'tabs/leave_tab.dart';
import 'tabs/payroll_tab.dart';
import 'tabs/expenses_tab.dart';
import 'tabs/documents_tab.dart';
import 'tabs/tax_tab.dart';
import 'tabs/notices_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _tabs = const [
    Tab(text: 'Home'),
    Tab(text: 'Leave'),
    Tab(text: 'Payroll'),
    Tab(text: 'Expenses'),
    Tab(text: 'Attendance'),
    Tab(text: 'Documents'),
    Tab(text: 'Tax'),
    Tab(text: 'Notices'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';
    if (userId.isNotEmpty) {
      await context.read<DashboardProvider>().loadAll(userId);
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<DashboardProvider>(builder: (context, dash, _) {
      if (dash.isLoading && dash.employee == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (dash.error != null && dash.employee == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load data', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(dash.error!, style: GoogleFonts.inter(color: AppColors.textMuted), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        );
      }

      final emp = dash.employee;
      final firstName = emp?.fullName.split(' ').first ?? 'Employee';

      return Column(
        children: [
          // Header + clock area
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(28),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()},',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: theme.hintColor),
                      ),
                      Text(
                        firstName,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildClockCard(context, dash),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabCtrl,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelStyle: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle:
                      GoogleFonts.inter(fontSize: 13),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: theme.hintColor,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: theme.dividerColor,
                  tabs: _tabs,
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                HomeTab(
                  dash: dash, 
                  onApplyLeave: () => _tabCtrl.animateTo(3), // Navigate to Expenses tab
                ),
                LeaveTab(dash: dash),
                PayrollTab(dash: dash),
                ExpensesTab(dash: dash),
                AttendanceTab(dash: dash),
                DocumentsTab(dash: dash),
                TaxTab(dash: dash),
                NoticesTab(dash: dash),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildClockCard(BuildContext context, DashboardProvider dash) {
    final theme = Theme.of(context);
    final isClockedIn = dash.isClockedIn;
    final statusColor = isClockedIn ? AppColors.accent : theme.hintColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isClockedIn
              ? AppColors.accent.withAlpha(60)
              : theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isClockedIn ? 'Currently Working' : 'Not Clocked In',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(
                  dash.workDuration,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                Text("Today's work time",
                    style: GoogleFonts.inter(
                        fontSize: 11, color: theme.hintColor)),
              ],
            ),
          ),


          GestureDetector(
            onTap: dash.clockLoading ? null : () => _handleClockAction(dash),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isClockedIn
                    ? [AppColors.accentWarm, const Color(0xFFFF4444)]
                    : [AppColors.primary, AppColors.primaryDark]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isClockedIn
                            ? AppColors.accentWarm
                            : AppColors.primary)
                        .withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: dash.clockLoading
                  ? const Padding(
                      padding: EdgeInsets.all(17),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Icon(
                      isClockedIn
                          ? Icons.logout_rounded
                          : Icons.login_rounded,
                      color: Colors.white,
                      size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClockAction(DashboardProvider dash) async {
    final wasClockedIn = dash.isClockedIn;
    Map<String, dynamic>? result;
    if (wasClockedIn) {
      result = await dash.clockOut();
    } else {
      result = await dash.clockIn();
    }
    if (!mounted) return;

    if (result != null && result['error'] != null) {
      _showSnack(result['error'], AppColors.error);
    } else if (result != null && result['is_overtime'] == true) {
      // Show overtime detected snack
      final mins = result['overtime_minutes'] ?? 0;
      final h = mins ~/ 60;
      final m = mins % 60;
      _showSnack('Overtime detected: ${h}h ${m}m! Submitted automatically.', AppColors.warning);
    } else {
      final msg = wasClockedIn
          ? 'Clocked out successfully 👋'
          : 'Clocked in successfully 🚀';
      _showSnack(msg, AppColors.success);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
    ));
  }
}
