class LeaveBalance {
  final String leaveTypeId;
  final String leaveType;
  final double totalLeaves;
  final double usedLeaves;
  final double balance;

  LeaveBalance({
    required this.leaveTypeId,
    required this.leaveType,
    required this.totalLeaves,
    required this.usedLeaves,
    required this.balance,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      leaveTypeId: json['leave_type_id']?.toString() ?? '',
      leaveType: json['leave_type_name'] ?? json['leave_type'] ?? json['type'] ?? 'Leave',
      totalLeaves: (json['max_days'] ?? json['total_leaves'] ?? json['total'] ?? 0).toDouble(),
      usedLeaves: (json['used_days'] ?? json['used_leaves'] ?? json['used'] ?? 0).toDouble(),
      balance: (json['balance'] ?? json['remaining'] ?? 0).toDouble(),
    );
  }

  double get usagePercent =>
      totalLeaves > 0 ? (usedLeaves / totalLeaves).clamp(0.0, 1.0) : 0.0;
}

class LeaveRequest {
  final String id;
  final String leaveTypeId;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String status;
  final double? totalDays;
  final String? reason;

  LeaveRequest({
    required this.id,
    required this.leaveTypeId,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.status,
    this.totalDays,
    this.reason,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id']?.toString() ?? '',
      leaveTypeId: json['leave_type_id']?.toString() ?? '',
      leaveType: json['leave_type_name'] ?? json['leave_type'] ?? 'Leave',
      fromDate: json['start_date'] ?? json['from_date'] ?? '',
      toDate: json['end_date'] ?? json['to_date'] ?? '',
      status: json['req_status'] ?? json['status'] ?? 'Pending',
      totalDays: (json['total_days'])?.toDouble(),
      reason: json['reason'],
    );
  }
}
