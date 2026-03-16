// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

// api_service.dart
const String API_BASE_URL = 'https://offscreen-overcool-rosalinda.ngrok-free.dev';

class ApiService {
  static String? _token;

  static void setToken(String token) => _token = token;

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token'
      };

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$API_BASE_URL/api/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // Register
  static Future<Map<String, dynamic>> register(
      String email,
      String password,
      String name,
      String contact,
      String address,
      bool smsOptIn) async {
    final res = await http.post(
      Uri.parse('$API_BASE_URL/api/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'contact_number': contact,
        'address': address,
        'sms_opt_in': smsOptIn
      }),
    );
    return jsonDecode(res.body);
  }

  // Recent readings
  static Future<List<dynamic>> recentReadings(String deviceId, {int limit = 20}) async {
  final res = await http.get(
    Uri.parse('$API_BASE_URL/api/readings/recent/$deviceId'),
    headers: _headers(),
  );

  final data = jsonDecode(res.body);
  return data;
}

  // Zones
  static Future<Map<String, dynamic>> getZones() async {
    final res = await http.get(Uri.parse('$API_BASE_URL/api/map/zones'), headers: _headers());
    return jsonDecode(res.body);
  }

  // Evac centers
  static Future<Map<String, dynamic>> getEvacCenters() async {
    final res = await http.get(Uri.parse('$API_BASE_URL/api/map/evac_centers'), headers: _headers());
    return jsonDecode(res.body);
  }

  // Notifications list
  static Future<Map<String, dynamic>> notificationsList() async {
    final res = await http.get(Uri.parse('$API_BASE_URL/api/notifications/list'), headers: _headers());
    return jsonDecode(res.body);
  }

  // User history
  static Future<List<dynamic>> userHistory() async {
    final res = await http.get(Uri.parse('$API_BASE_URL/api/history'), headers: _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['history'] ?? [];
    } else {
      throw Exception('Failed to load history');
    }
  }

  // Notifications
  static Future<List<dynamic>> getNotifications() async {
    final res = await http.get(Uri.parse('$API_BASE_URL/api/notifications'), headers: _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['notifications'] ?? [];
    } else {
      throw Exception("Failed to fetch notifications");
    }
  }
}
