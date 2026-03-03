import '../core/api_client.dart';
import '../models/payslip_model.dart';

class PayrollService {
  Future<List<Payslip>> getMyPayslips() async {
    try {
      final data = await ApiClient.get('/my-payroll/payslips');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      if (list is List) {
        return list.map((p) => Payslip.fromJson(p)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

class AnnouncementService {
  Future<List<Announcement>> getNoticeboard() async {
    try {
      final data = await ApiClient.get('/noticeboard/?page=1&page_size=10');
      final list = data is List ? data : (data['items'] ?? data['data'] ?? []);
      if (list is List) {
        return list.map((a) => Announcement.fromJson(a)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
