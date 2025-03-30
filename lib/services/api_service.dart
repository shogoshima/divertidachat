import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<dynamic> get(String endpoint, [String? token]) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      [String? token]) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    late dynamic json;
    try {
      json = jsonDecode(response.body);
    } catch (error) {
      throw Exception('Error in the response body. Try again later.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    } else {
      throw Exception('[Error ${response.statusCode}] ${json['msg']}');
    }
  }
}
