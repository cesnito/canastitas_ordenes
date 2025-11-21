import 'package:ordenes/api/cliente.dart';
import 'package:ordenes/api/respuestas/base_response.dart';
import 'package:ordenes/modelos/orden_tiempo_real.dart';
import 'package:ordenes/modelos/usuario.dart';

class CanastitasAPI {
  final ApiClient api = ApiClient(
    baseUrl: "https://cesnio-lascanastitas.com/api/api/",
    // baseUrl: "http://192.168.100.63/apicanastitas/api/",
  );

  final Usuario? usuario;

  CanastitasAPI({this.usuario});

  Future<void> login(
    String usuario,
    String password, {
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final data = {'usuario': usuario, 'password': password};

    final response = await api.post('sesion/iniciar', data);
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> obtenerSucursales({
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final response = await api.get('sesion/sucursales');
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> obtenerTokenFirebase({
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final response = await api.post(
      'firebase/token',
      null,
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> obtenerProductos({
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final response = await api.post(
      'productos/obtener',
      null,
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> realizarPedido(
    Map<String, dynamic> pedidoData, {
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final response = await api.post(
      'ordenes/realizar',
      pedidoData,
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> editarPedido(
    Map<String, dynamic> pedidoData, {
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final response = await api.post(
      'ordenes/actualizarorden',
      pedidoData,
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> actualizaEstatusOrden(
    Map<String, dynamic> ordenData, {
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final response = await api.post(
      'ordenes/actualizarestatus',
      ordenData,
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> obtenerDetallesOrden(
    int idOrden, {
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final orden = {'idOrden': idOrden};

    final response = await api.post(
      'ordenes/detalles',
      orden,
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> verificarDisponibilidadProducto(
    Map<String, dynamic> ordenData, {
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final response = await api.post(
      'productos/disponibilidad',
      ordenData,
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> obtenerOrdenes(
    String fecha, {
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final datax = {'fecha': fecha};

    final response = await api.post(
      'ordenes/obtener',
      datax,  
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  Future<void> obtenerOrdenes2(
    String fecha, {
    required void Function(APIResponse) onSuccess,
    required void Function(APIResponse) onError,
  }) async {
    final datax = {'fecha': fecha};

    final response = await api.post(
      'ordenes/obtener2',
      datax,  
      token: usuario!.token,
    );
    try {
      if (response.estatus == 200) {
        onSuccess(response);
      } else {
        onError(response);
      }
    } catch (e) {
      print("Fallo aqui");
      print(e);
      print("Fallo aqui");
      var res = APIResponse();
      res.error = APIError(descripcion: e.toString());
      onError(APIResponse());
    }
  }

  // Future<List<dynamic>> obtenerOrdenes(String token) async {
  //   final response = await api.get('/ordenes/curso', token: token);
  //   return response['data'];
  // }
}
