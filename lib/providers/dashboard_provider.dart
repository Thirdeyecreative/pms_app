import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';
import '../models/payslip_model.dart';
import '../models/expense_model.dart';
import '../models/extended_models.dart';
import '../services/employee_service.dart';
import '../services/attendance_service.dart';
import '../services/leave_service.dart';
import '../services/payroll_service.dart';
import '../services/expense_service.dart';
import '../services/tax_overtime_service.dart';

class DashboardProvider extends ChangeNotifier {
  final EmployeeService _employeeService = EmployeeService();
  final AttendanceService _attendanceService = AttendanceService();
  final LeaveService _leaveService = LeaveService();
  final PayrollService _payrollService = PayrollService();
  final AnnouncementService _announcementService = AnnouncementService();
  final ExpenseService _expenseService = ExpenseService();
  final TaxService _taxService = TaxService();
  final OvertimeService _overtimeService = OvertimeService();

  // Data
  EmployeeModel? _employee;
  List<AttendanceRecord> _attendanceHistory = [];
  List<LeaveBalance> _leaveBalance = [];
  List<LeaveRequest> _leaveRequests = [];
  List<LeaveType> _leaveTypes = [];
  List<Payslip> _payslips = [];
  List<Announcement> _announcements = [];
  List<ExpenseClaim> _expenses = [];
  List<ExpenseClaim> _allExpenses = [];
  List<ExpenseCategory> _expenseCategories = [];

  List<TaxDeclaration> _taxDeclarations = [];
  List<Form16> _form16s = [];
  List<OvertimeRequest> _otRequests = [];
  SalaryStructure? _activeSalary;
  AttendanceSummary _attendanceSummary = AttendanceSummary();
  String? _taxRegime;

  // State
  bool _isLoading = false;
  bool _clockLoading = false;
  String? _error;
  bool _isClockedIn = false;
  String? _clockInTime;
  String _workDuration = '0h 0m 0s';
  Timer? _workTimer;

  // Getters
  EmployeeModel? get employee => _employee;
  List<AttendanceRecord> get attendanceHistory => _attendanceHistory;
  List<LeaveBalance> get leaveBalance => _leaveBalance;
  List<LeaveRequest> get leaveRequests => _leaveRequests;
  List<LeaveType> get leaveTypes => _leaveTypes;
  List<Payslip> get payslips => _payslips;
  List<Announcement> get announcements => _announcements;
  List<ExpenseClaim> get expenses => _expenses;
  List<ExpenseClaim> get allExpenses => _allExpenses;
  List<ExpenseCategory> get expenseCategories => _expenseCategories;

  List<TaxDeclaration> get taxDeclarations => _taxDeclarations;
  List<Form16> get form16s => _form16s;
  List<OvertimeRequest> get otRequests => _otRequests;
  SalaryStructure? get activeSalary => _activeSalary;
  AttendanceSummary get attendanceSummary => _attendanceSummary;
  String? get taxRegime => _taxRegime;
  bool get isLoading => _isLoading;
  bool get clockLoading => _clockLoading;
  String? get error => _error;
  bool get isClockedIn => _isClockedIn;
  String? get clockInTime => _clockInTime;
  String get workDuration => _workDuration;

  Future<void> loadAll(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load employee first (required for profile display)
      _employee = await _employeeService.getEmployee(userId);
      _taxRegime = _employee?.taxRegime;
      notifyListeners();

      // Load everything else in parallel — gracefully handle individual failures
      final results = await Future.wait([
        _attendanceService.getMyHistory().catchError((_) => <AttendanceRecord>[]),
        _leaveService.getMyLeaveBalance().catchError((_) => <LeaveBalance>[]),
        _leaveService.getMyLeaveRequests().catchError((_) => <LeaveRequest>[]),
        _leaveService.getLeaveTypes().catchError((_) => <LeaveType>[]),
        _payrollService.getMyPayslips().catchError((_) => <Payslip>[]),
        _announcementService.getNoticeboard().catchError((_) => <Announcement>[]),
        _expenseService.getMyClaims().catchError((_) => <ExpenseClaim>[]),
        _expenseService.getAllClaims().catchError((_) => <ExpenseClaim>[]),
        _expenseService.getCategories().catchError((_) => <ExpenseCategory>[]),

        _taxService.getTaxDeclarations().catchError((_) => <TaxDeclaration>[]),
        _taxService.getMyForm16s().catchError((_) => <Form16>[]),
        _overtimeService.getMyRequests().catchError((_) => <OvertimeRequest>[]),
        _employeeService.getSalaryStructures(userId).catchError((_) => <SalaryStructure>[]),
      ]);

      _attendanceHistory = results[0] as List<AttendanceRecord>;
      _leaveBalance = results[1] as List<LeaveBalance>;
      _leaveRequests = results[2] as List<LeaveRequest>;
      _leaveTypes = results[3] as List<LeaveType>;
      _payslips = results[4] as List<Payslip>;
      _announcements = results[5] as List<Announcement>;
      _expenses = results[6] as List<ExpenseClaim>;
      _allExpenses = results[7] as List<ExpenseClaim>;
      _expenseCategories = results[8] as List<ExpenseCategory>;
      _taxDeclarations = results[9] as List<TaxDeclaration>;
      _form16s = results[10] as List<Form16>;
      _otRequests = results[11] as List<OvertimeRequest>;


      // Find active salary structure
      final allStructures = results[12] as List<SalaryStructure>;
      final now = DateTime.now();
      final valid = allStructures
          .where((s) {
            if (s.status != 1) return false;
            try {
              final d = DateTime.parse(s.effectiveFrom);
              return !d.isAfter(now);
            } catch (_) {
              return false;
            }
          })
          .toList()
        ..sort((a, b) {
          try {
            return DateTime.parse(b.effectiveFrom)
                .compareTo(DateTime.parse(a.effectiveFrom));
          } catch (_) {
            return 0;
          }
        });
      _activeSalary = valid.isNotEmpty ? valid.first : null;

      _computeAttendanceSummary();
      _detectClockStatus();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _computeAttendanceSummary() {
    final summary = AttendanceSummary();
    for (final record in _attendanceHistory) {
      switch (record.status) {
        case 'present':
        case 'late':
        case 'half_day':
          summary.present++;
          break;
        case 'absent':
          summary.absent++;
          break;
        case 'leave':
          summary.leaves++;
          break;
        case 'holiday':
          summary.holidays++;
          break;
        case 'lwp':
          summary.lwp++;
          break;
      }
    }
    summary.workingDays = _attendanceHistory.length;
    _attendanceSummary = summary;
  }

  void _detectClockStatus() {
    if (_attendanceHistory.isNotEmpty) {
      _isClockedIn = false;
      for (final record in _attendanceHistory) {
        if (record.logs.any((l) => l.isActive)) {
          final activeLog = record.logs.firstWhere((l) => l.isActive);
          _isClockedIn = true;
          _clockInTime = activeLog.checkIn;
          _startWorkTimer();
          return;
        }
      }
    } else if (_employee != null) {
      _isClockedIn = _employee!.isCheckedIn;
    }
  }

  void _startWorkTimer() {
    _workTimer?.cancel();
    _workTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _computeWorkDuration();
      notifyListeners();
    });
  }

  void _computeWorkDuration() {
    int totalMs = 0;
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    for (final record in _attendanceHistory) {
      // Ensure we match the date part correctly
      final recordDate = record.date.length >= 10 ? record.date.substring(0, 10) : record.date;
      if (recordDate != today) continue;
      
      for (final log in record.logs) {
        try {
          if (log.checkOut != null && log.checkOut!.isNotEmpty) {
            final start = DateTime.parse(log.checkIn).millisecondsSinceEpoch;
            final end = DateTime.parse(log.checkOut!).millisecondsSinceEpoch;
            totalMs += end - start;
          } else if (log.isActive) {
            final start = DateTime.parse(log.checkIn).millisecondsSinceEpoch;
            totalMs += now.millisecondsSinceEpoch - start;
          }
        } catch (_) {}
      }
    }

    final hours = totalMs ~/ (1000 * 60 * 60);
    final minutes = (totalMs % (1000 * 60 * 60)) ~/ (1000 * 60);
    final seconds = (totalMs % (1000 * 60)) ~/ 1000;
    _workDuration = '${hours}h ${minutes}m ${seconds}s';
  }

  Future<Map<String, dynamic>?> clockIn() async {
    _clockLoading = true;
    notifyListeners();
    try {
      final userId = _employee?.id ?? '';
      await _attendanceService.clockIn(userId);
      _isClockedIn = true;
      _clockInTime = DateTime.now().toIso8601String();
      _attendanceHistory = await _attendanceService.getMyHistory();
      _computeAttendanceSummary();
      _startWorkTimer();
      _clockLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _clockLoading = false;
      notifyListeners();
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> clockOut() async {
    _clockLoading = true;
    notifyListeners();
    try {
      final userId = _employee?.id ?? '';
      final result = await _attendanceService.clockOut(userId);
      _isClockedIn = false;
      _workTimer?.cancel();
      _attendanceHistory = await _attendanceService.getMyHistory();
      _computeAttendanceSummary();
      _otRequests = await _overtimeService.getMyRequests();
      _clockLoading = false;
      notifyListeners();
      // Return overtime info if detected
      if (result != null && result['is_overtime'] == true) {
        return result as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _clockLoading = false;
      notifyListeners();
      return {'error': e.toString()};
    }
  }

  // Leave actions
  Future<void> applyLeave({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    await _leaveService.applyLeave(
      leaveTypeId: leaveTypeId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
    _leaveRequests = await _leaveService.getMyLeaveRequests();
    _leaveBalance = await _leaveService.getMyLeaveBalance();
    notifyListeners();
  }

  Future<void> cancelLeave(String requestId, {String reason = ''}) async {
    await _leaveService.cancelLeave(requestId, reason: reason);
    _leaveRequests = await _leaveService.getMyLeaveRequests();
    _leaveBalance = await _leaveService.getMyLeaveBalance();
    notifyListeners();
  }

  // Expense actions
  Future<void> addExpense(ExpenseClaim claim) {
    _expenses = [claim, ..._expenses];
    _allExpenses = [claim, ..._allExpenses];
    notifyListeners();
    return Future.value();
  }

  Future<void> loadAllExpenses() async {
    _allExpenses = await _expenseService.getAllClaims();
    notifyListeners();
  }

  Future<void> updateExpenseStatus(String id, String status, {String? summary}) async {
    final updated = await _expenseService.updateClaimStatus(id, status, summary: summary);
    final idx = _allExpenses.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _allExpenses[idx] = updated;
    }
    final myIdx = _expenses.indexWhere((e) => e.id == id);
    if (myIdx != -1) {
      _expenses[myIdx] = updated;
    }
    notifyListeners();
  }


  // Tax actions
  Future<void> deleteTaxDeclaration(String id) async {
    await _taxService.deleteTaxDeclaration(id);
    _taxDeclarations = _taxDeclarations.where((d) => d.id != id).toList();
    notifyListeners();
  }

  // OT actions
  Future<void> actionOT(String id, String action, {String? reason}) async {
    await _overtimeService.actionRequest(id, action, reason: reason);
    _otRequests = await _overtimeService.getMyRequests();
    notifyListeners();
  }

  // Profile update
  Future<void> updateProfile(String employeeId, Map<String, dynamic> fields) async {
    await _employeeService.updateProfile(employeeId, fields);
    _employee = await _employeeService.getEmployee(employeeId);
    notifyListeners();
  }

  @override
  void dispose() {
    _workTimer?.cancel();
    super.dispose();
  }
}
