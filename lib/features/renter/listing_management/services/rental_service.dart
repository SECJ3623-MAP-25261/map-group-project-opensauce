import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rental_analytics.dart';

class RentalService {
  // ⚠️ IMPORTANT FOR EMULATOR:
  // If using Android Emulator, use '10.0.2.2'.http://127.0.0.1:3000
  // If using a physical phone, use your laptop's IP address (e.g., 192.168.1.15).
  static const String baseUrl = 'http://127.0.0.1:3000/api/rental';

  Future<RentalAnalytics> getRentalAnalytics(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analyze-rental-data/$productId'),
      );

      if (response.statusCode == 200) {
        return RentalAnalytics.fromJson(jsonDecode(response.body));
      } else {
        // If server returns error, return zeros instead of crashing
        return RentalAnalytics(totalEarnings: 0, totalOrders: 0, totalDuration: 0);
      }
    } catch (e) {
      // If server is offline, return zeros
      print("Error fetching analytics: $e");
      return RentalAnalytics(totalEarnings: 0, totalOrders: 0, totalDuration: 0);
    }
  }
}