import 'dart:convert';
import 'package:ordenes/modelos/sucursal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServicioAPI {
  static const String baseUrl = 'https://cesnio-lascanastitas.com/api/api/';


  Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<void> borrarToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
  }
  // Future<List<Map<String, dynamic>>> obtenerSucursales() async {
  //   final url = Uri.parse('$baseUrl/sucursales');
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     return data.map<Map<String, dynamic>>((item) {
  //       return {
  //         'id': item['id'],
  //         'nombre': item['nombre'],
  //       };
  //     }).toList();
  //   } else {
  //     throw Exception('No se pudieron cargar las sucursales');
  //   }
  // }

  Future<List<Sucursal>> obtenerSucursales() async {
    final url = Uri.parse('$baseUrl/sesion/sucursales');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data'];

      return data.map((item) => Sucursal.fromJson(item)).toList();
    } else {
      throw Exception('No se pudieron cargar las sucursales');
    }
  }

  Future<String> iniciarSesion({
    required String usuario,
    required String password,
    required String sucursalId,
  }) async {
    final url = Uri.parse('$baseUrl/sesion/iniciar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario': usuario,
        'password': password,
        'sucursal_id': sucursalId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', token);
        return token;
      } else {
        throw Exception('Token no recibido');
      }
    } else {
      throw Exception('Credenciales incorrectas');
    }
  }

  Future<http.Response> getConToken(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = Uri.parse('$baseUrl/$endpoint');

    final response = await http.get(
      url,
      headers: {
        'key': token, // 👈 Header personalizado con JWT
      },
    );

    return response;
  }

  Future<http.Response> postConToken(
      String endpoint, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = Uri.parse('$baseUrl/$endpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'key': token, // 👈 JWT como header personalizado
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<List<dynamic>> obtenerOrdenesCurso() async {
    return [];
    /*
    final token = await obtenerToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Token no disponible');
    }

    final url = Uri.parse('$baseUrl/ordenes/curso');
    final response = await http.get(
      url,
      headers: {
        'key': token,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      throw Exception('Formato de respuesta inválido');
    } else if (response.statusCode == 403) {
      await borrarToken();
      throw AuthException('Token expirado o inválido'); // 👈
    } else {
      throw Exception('Error al obtener órdenes: ${response.statusCode}');
    }
    */
  }
}
class AuthException implements Exception {
  final String mensaje;
  AuthException(this.mensaje);

  @override
  String toString() => mensaje;
}
