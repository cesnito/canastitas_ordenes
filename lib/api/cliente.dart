import 'dart:convert';
import 'package:ordenes/api/respuestas/base_response.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<APIResponse> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print(uri);
    final response = await http.get(
      uri,
      headers: _buildHeaders(token),
    );
    
    try {
      final decodedString = utf8.decode(response.bodyBytes);
      print(decodedString);
      final Map<String, dynamic> jsonBody = json.decode(decodedString);
      // final Map<String, dynamic> jsonBody = json.decode(response.body);
      int estatus = jsonBody['estatus'];
      APIResponse res = APIResponse(estatus: estatus, data: jsonBody['data']);
      res.raw = response.body;

      final dynamic errorsJson = jsonBody['errors'];
      if (errorsJson is List) {
        if(errorsJson.isNotEmpty){
          res.error = APIError.fromJson(errorsJson.first as Map<String, dynamic>);
        } 
      }
      return res;
    } catch (e) {
      print(e);
      return APIResponse();
    }
  }

  Future<APIResponse> post(String endpoint, Map<String, dynamic>? data,
      {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print(uri.toString());
    print('"${token}"');
    final response = await http.post(
      uri,
      headers: _buildHeaders(token),
      body: jsonEncode(data),
    );
    try {
      print(response.body);
      final decodedString = utf8.decode(response.bodyBytes);
      print(decodedString);
      final Map<String, dynamic> jsonBody = json.decode(decodedString);
      // final Map<String, dynamic> jsonBody = json.decode(response.body);
      int estatus = jsonBody['estatus'];
      APIResponse res = APIResponse(estatus: estatus, data: jsonBody['data']);
      res.raw = response.body;
      final dynamic errorsJson = jsonBody['errors'];
      if (errorsJson is List) {
        if(errorsJson.isNotEmpty){
          res.error = APIError.fromJson(errorsJson.first as Map<String, dynamic>);
        } 
      }
      return res;
    } catch (e) {
      return APIResponse();
    }
  }

  Map<String, String> _buildHeaders(String? token) {
    final headers = {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Key'] = token; // Header personalizado
    }
    print(headers); 
    return headers;
  }
  // dynamic _handleResponse(http.Response response) {
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else if (response.statusCode == 403) {
  //     // Opcional: puedes lanzar una excepción personalizada aquí
  //     throw UnauthorizedException();
  //   } else {
  //     throw Exception('Error ${response.statusCode}: ${response.body}');
  //   }
  // }
}

class UnauthorizedException implements Exception {}
