import 'package:geolocator/geolocator.dart';
import '../core/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  Future<List<AttendanceRecord>> getMyHistory() async {
    final data = await ApiClient.get('/attendance/my-history');
    final records = data['data'];
    if (records is List) {
      return records.map((r) => AttendanceRecord.fromJson(r)).toList();
    }
    return [];
  }

  Future<void> clockIn() async {
    final location = await _getLocation();
    await ApiClient.post('/attendance/check-in', body: {
      'location': location,
      'attendance_source': 'mobile',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> clockOut() async {
    final data = await ApiClient.post('/attendance/check-out', body: {});
    return data ?? {};
  }

  Future<String> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Location unavailable';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return 'Location permission denied';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
    } catch (_) {
      return 'Location unavailable';
    }
  }
}
