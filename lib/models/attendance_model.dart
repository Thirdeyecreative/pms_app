class AttendanceLog {
  final String checkIn;
  final String? checkOut;
  final String? location;

  AttendanceLog({required this.checkIn, this.checkOut, this.location, required bool isActive});

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'],
      location: json['location'],
      isActive: json['check_out'] == null && (json['check_in'] ?? '').isNotEmpty,
    );
  }

  bool get isActive => checkOut == null && checkIn.isNotEmpty;
}

class AttendanceRecord {
  final String date;
  final String status;
  final List<AttendanceLog> logs;

  AttendanceRecord({
    required this.date,
    required this.status,
    required this.logs,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final rawLogs = json['logs'];
    return AttendanceRecord(
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      logs: rawLogs is List
          ? rawLogs.map((l) => AttendanceLog.fromJson(l)).toList()
          : [],
    );
  }

  /// Total worked minutes today across all log sessions
  int get totalMinutes {
    int total = 0;
    for (final log in logs) {
      try {
        final start = DateTime.parse(log.checkIn);
        final end = log.checkOut != null
            ? DateTime.parse(log.checkOut!)
            : DateTime.now();
        total += end.difference(start).inMinutes.clamp(0, 1440);
      } catch (_) {}
    }
    return total;
  }

  String get totalHoursFormatted {
    final m = totalMinutes;
    if (m == 0) return '-';
    return '${m ~/ 60}h ${m % 60}m';
  }
}

class AttendanceSummary {
  int present;
  int absent;
  int leaves;
  int holidays;
  int lwp;
  int workingDays;

  AttendanceSummary({
    this.present = 0,
    this.absent = 0,
    this.leaves = 0,
    this.holidays = 0,
    this.lwp = 0,
    this.workingDays = 0,
  });
}
