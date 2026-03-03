import '../core/api_client.dart';
import '../models/leave_model.dart';
import '../models/extended_models.dart';

class LeaveService {
  // Real endpoints confirmed from web frontend leave.ts
  Future<List<LeaveBalance>> getMyLeaveBalance() async {
    try {
      final data = await ApiClient.get('/my-leaves/balance');
      final list = data is List ? data : (data['data'] ?? []);
      if (list is List) {
        return list.map((l) => LeaveBalance.fromJson(l)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<LeaveRequest>> getMyLeaveRequests() async {
    try {
      final data = await ApiClient.get('/my-leaves/requests');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      if (list is List) {
        return list.map((l) => LeaveRequest.fromJson(l)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<LeaveType>> getLeaveTypes() async {
    try {
      final data = await ApiClient.get('/leave/types');
      final list = data is List ? data : (data['data'] ?? []);
      return (list as List).map((e) => LeaveType.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> applyLeave({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    await ApiClient.post('/my-leaves/requests', body: {
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
    });
  }

  Future<void> cancelLeave(String requestId, {String reason = ''}) async {
    await ApiClient.post('/my-leaves/requests/$requestId/cancel', body: {
      'reason': reason,
    });
  }
}
