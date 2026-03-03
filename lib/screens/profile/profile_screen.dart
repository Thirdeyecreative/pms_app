import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/employee_model.dart';
import '../../models/extended_models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showAllComponents = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, dash, _) {
      if (dash.isLoading && dash.employee == null) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      final emp = dash.employee;
      if (emp == null) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.person_off_rounded,
                color: AppColors.textMuted.withAlpha(80), size: 48),
            const SizedBox(height: 12),
            Text('Profile unavailable',
                style:
                    GoogleFonts.inter(fontSize: 15, color: AppColors.textMuted)),
          ]),
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        children: [
          _HeroSection(emp: emp, onEdit: () => _showEditSheet(context, dash, emp)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(children: [
              _EmploymentCard(emp: emp),
              const SizedBox(height: 14),
              _IdentificationCard(emp: emp),
              const SizedBox(height: 14),
              _SalaryCard(
                salary: dash.activeSalary,
                showAll: _showAllComponents,
                onToggle: () => setState(() => _showAllComponents = !_showAllComponents),
              ),
              const SizedBox(height: 14),
              _CompanyCard(emp: emp),
              const SizedBox(height: 14),
            ]),
          ),
        ],
      );
    });
  }

  void _showEditSheet(BuildContext context, DashboardProvider dash, EmployeeModel emp) {
    final phoneCtrl = TextEditingController(text: emp.phone);
    final currentAddrCtrl = TextEditingController(text: emp.currentAddress ?? '');
    final permanentAddrCtrl = TextEditingController(text: emp.permanentAddress ?? '');
    final panCtrl = TextEditingController(text: emp.panNo ?? '');
    final aadhaarCtrl = TextEditingController(text: emp.aadhaarNo ?? '');
    bool _saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.glassBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSS) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text('Edit Profile',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              _editField(phoneCtrl, 'Phone Number', Icons.phone_rounded),
              const SizedBox(height: 12),
              _editField(currentAddrCtrl, 'Current Address', Icons.location_on_rounded, maxLines: 2),
              const SizedBox(height: 12),
              _editField(permanentAddrCtrl, 'Permanent Address', Icons.home_rounded, maxLines: 2),
              const SizedBox(height: 12),
              _editField(panCtrl, 'PAN Number', Icons.credit_card_rounded),
              const SizedBox(height: 12),
              _editField(aadhaarCtrl, 'Aadhaar Number', Icons.badge_rounded),
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
                  onPressed: _saving
                      ? null
                      : () async {
                          setSS(() => _saving = true);
                          try {
                            final auth = context.read<AuthProvider>();
                            final userId = auth.currentUser?.id ?? '';
                            await dash.updateProfile(userId, {
                              'phone': phoneCtrl.text,
                              'current_address': currentAddrCtrl.text,
                              'permanent_address': permanentAddrCtrl.text,
                              'pan_no': panCtrl.text,
                              'aadhaar_no': aadhaarCtrl.text,
                            });
                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Profile updated! ✅'),
                                      backgroundColor: AppColors.success));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: AppColors.error));
                            }
                          } finally {
                            if (mounted) setSS(() => _saving = false);
                          }
                        },
                  child: Text(_saving ? 'Saving...' : 'Save Changes',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        );
      }),
    );
  }

  Widget _editField(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final EmployeeModel emp;
  final VoidCallback onEdit;
  const _HeroSection({required this.emp, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isActive = emp.status == 1;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withAlpha(28), AppColors.background],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(children: [
        // Avatar
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Center(
            child: Text(emp.initials,
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(height: 14),
        Text(emp.fullName,
            style: GoogleFonts.inter(
                fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text('${emp.designation} • ${emp.departmentName}',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 10),
        // Badges
        Wrap(spacing: 8, children: [
          _Badge(text: emp.employeeCode, color: AppColors.primary),
          _Badge(
            text: isActive ? 'Active' : 'Inactive',
            color: isActive ? AppColors.success : AppColors.error,
          ),
          _Badge(text: emp.roleName, color: AppColors.info),
        ]),
        const SizedBox(height: 14),
        // Quick info row
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 6,
          children: [
            _InfoChip(icon: Icons.email_rounded, text: emp.email),
            _InfoChip(icon: Icons.phone_rounded, text: emp.phone),
            if (emp.displayLocation != 'N/A')
              _InfoChip(icon: Icons.location_on_rounded, text: emp.displayLocation, maxWidth: 160),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded, size: 16),
          label: Text('Edit Profile',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final double maxWidth;
  const _InfoChip({required this.icon, required this.text, this.maxWidth = 220});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppColors.textMuted),
      const SizedBox(width: 4),
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(text,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}

class _EmploymentCard extends StatelessWidget {
  final EmployeeModel emp;
  const _EmploymentCard({required this.emp});

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Employee ID', 'value': emp.employeeCode},
      {
        'label': 'Joining Date',
        'value': _fmtDate(emp.joiningDate) ?? 'N/A'
      },
      {'label': 'Reporting To', 'value': emp.managerName},
      {'label': 'Department', 'value': emp.departmentName},
      {'label': 'Designation', 'value': emp.designation},
      {'label': 'Employment Type', 'value': emp.employmentType},
      {
        'label': 'Work Location',
        'value': emp.currentAddress ?? emp.permanentAddress ?? 'N/A'
      },
    ];

    return _InfoCard(
      icon: Icons.work_outline_rounded,
      title: 'Employment Information',
      rows: rows,
    );
  }
}

class _IdentificationCard extends StatelessWidget {
  final EmployeeModel emp;
  const _IdentificationCard({required this.emp});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.badge_rounded,
      title: 'Identification Details',
      rows: [
        {'label': 'PAN Number', 'value': emp.panNo ?? 'N/A'},
        {'label': 'Aadhaar Number', 'value': emp.aadhaarNo ?? 'N/A'},
        {'label': 'Date of Birth', 'value': _fmtDate(emp.dateOfBirth) ?? 'N/A'},
      ],
    );
  }
}

class _SalaryCard extends StatelessWidget {
  final SalaryStructure? salary;
  final bool showAll;
  final VoidCallback onToggle;
  const _SalaryCard({this.salary, required this.showAll, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(children: [
            const Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 8),
            Text('Salary Information',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
        ),
        Container(height: 1, color: AppColors.glassBorder),
        Padding(
          padding: const EdgeInsets.all(16),
          child: salary == null
              ? Row(children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.textMuted.withAlpha(80), size: 30),
                  const SizedBox(width: 12),
                  Text('No active salary structure found',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textMuted)),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.primary.withAlpha(26),
                        AppColors.primaryDark.withAlpha(13),
                      ]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withAlpha(40)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Gross Annual Salary',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        '₹${NumberFormat('#,##,###').format(salary!.grossSalary.round())}',
                        style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryLight),
                      ),
                      Text(
                        'Effective from: ${_fmtDate(salary!.effectiveFrom) ?? salary!.effectiveFrom}',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Text('Key Components',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  ...salary!.items
                      .take(showAll ? salary!.items.length : 3)
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              Expanded(
                                child: Text(item.componentName,
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: AppColors.textSecondary)),
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
                  if (salary!.items.length > 3)
                    Center(
                      child: TextButton(
                        onPressed: onToggle,
                        child: Text(
                          showAll ? 'View Less ▲' : '+ ${salary!.items.length - 3} more ▼',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary),
                        ),
                      ),
                    ),
                ]),
        ),
      ]),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final EmployeeModel emp;
  const _CompanyCard({required this.emp});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(children: [
            const Icon(Icons.business_rounded, color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 8),
            Text('Company Details',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
        ),
        Container(height: 1, color: AppColors.glassBorder),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.apartment_rounded,
                  color: AppColors.primaryLight, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Joyn People HRM',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('Active Employee',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Official',
                  style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Map<String, String>> rows;
  const _InfoCard(
      {required this.icon, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(children: [
            Icon(icon, color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
        ),
        Container(height: 1, color: AppColors.glassBorder),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: rows.map((row) {
              final isLast = row == rows.last;
              return Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(row['label']!,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textMuted)),
                    ),
                    Expanded(
                      child: Text(row['value']!,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
                if (!isLast)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: AppColors.glassBorder,
                  ),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

String? _fmtDate(String? d) {
  if (d == null) return null;
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(d));
  } catch (_) {
    return d;
  }
}
