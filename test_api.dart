import 'package:dio/dio.dart';
import 'lib/features/dashboard/models/dashboard_stats.dart';
import 'lib/core/api/api_client.dart';

void main() async {
  // NOTE: You need a valid Bearer token for api-dev.converf.com to test this properly.
  // Replace YOUR_TOKEN_HERE with a real token if you have one.
  const String token = 'YOUR_TOKEN_HERE';

  final dio = Dio(BaseOptions(
    baseUrl: 'https://api-dev.converf.com',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != 'YOUR_TOKEN_HERE') 'Authorization': 'Bearer $token',
    },
  ));

  final apiClient = ApiClient(dio);

  print('--- Converf Dashboard API Test ---');
  print('Target: https://api-dev.converf.com/api/v1/dashboard');
  
  try {
    final response = await apiClient.get('/api/v1/dashboard');
    print('Status: ${response.statusCode}');
    
    final dashboardResponse = DashboardResponse.fromJson(response.data);
    print('Message: ${dashboardResponse.message}');
    
    if (dashboardResponse.data != null) {
      final data = dashboardResponse.data!;
      print('\nSuccess! Parsed Dashboard Data:');
      print('- Active Projects: ${data.activeProjects}');
      print('- Quality Score: ${data.avgQualityScore}%');
      print('- Ball-in-courts: ${data.ballInCourts}');
      print('- Portfolio Value: ${data.portfolioValue}');
    } else {
      print('\nResponse received but "data" field is null.');
      print('Raw Data: ${response.data}');
    }
  } catch (e) {
    print('\nError during API test: $e');
    print('If you see a 401 error, please update the token in this script.');
  }
  print('----------------------------------');
}
