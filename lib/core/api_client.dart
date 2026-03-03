import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }
    String message = 'Request failed';
    try {
      final body = json.decode(response.body);
      message = body['detail'] ?? body['message'] ?? message;
    } catch (_) {}
    throw ApiException(message, statusCode: response.statusCode);
  }

  static Future<dynamic> get(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final response = await http.get(
      Uri.parse('$kApiBaseUrl$path'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    final response = await http.post(
      Uri.parse('$kApiBaseUrl$path'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    final response = await http.put(
      Uri.parse('$kApiBaseUrl$path'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    final response = await http.patch(
      Uri.parse('$kApiBaseUrl$path'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final response = await http.delete(
      Uri.parse('$kApiBaseUrl$path'),
      headers: headers,
    );
    return _handleResponse(response);
  }
}


