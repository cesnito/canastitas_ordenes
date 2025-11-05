import 'dart:convert';
import 'dart:developer';
import 'package:ordenes/api/canastitas_api.dart';
import 'package:ordenes/modelos/usuario.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ordenes/utils/haptic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/sucursal.dart';
import '../servicios/servicio_api.dart';
import '../utils/dialogo.dart';

class PantallaInicioSesion extends StatefulWidget {
  @override
  _PantallaInicioSesionState createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final ServicioAPI _apiService = ServicioAPI();
  CanastitasAPI api = CanastitasAPI();

  @override
  void initState() {
    super.initState();

    _usuarioController.text = "cesni";
    _passwordController.text = "cesni";
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarSesion() async {
    Haptic.sense();
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      _mostrarError('Todos los campos son obligatorios');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Iniciando sesión..."),
          ],
        ),
      ),
    );

    api.login(
      usuario,
      password,
      onSuccess: (res) async {
        Navigator.of(context).pop();
        if (res.data != null) {
          Usuario user = Usuario.fromJson(res.data);
          await Provider.of<SesionProvider>(
            context,
            listen: false,
          ).setSession(user);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Dialogo.mostrarMensaje(context, "Error al iniciar sesión");
        }
      },
      onError: (error) {
        Navigator.of(context).pop();
        Dialogo.mostrarMensaje(context, error.error.descripcion);
      },
    );
    /*
    final url =
        Uri.parse('https://cesnio-lascanastitas.com/api/api/sesion/iniciar');
    final response = await http.post(
      url,
      body: jsonEncode({
        'usuario': usuario,
        'password': password,
        'idSucursal': _sucursalSeleccionada,
      }),
      headers: {
        'Content-Type': 'application/jsoncanastitas',
        'Accept': 'application/jsoncanastitas'
      },
    );

    log('$_sucursalSeleccionada');

    Navigator.of(context).pop(); // cerrar el modal de carga

    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(data['data']);
      // final _sesion = data['data'];
      final token = data['data'];
      // print(_sesion);

      final s = Usuario(
          token: token,
          nombre: 'Javier',
          usuario: 'cesni',
          perfil: 'SuperAdmin');
      // final session = SesionData.fromJson(data);
      if (token != null) {
        await Provider.of<SesionProvider>(context, listen: false).setSession(s);
        // Aquí puedes navegar a otra pantalla
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _mostrarError('Token no recibido');
      }
    } else {
      _mostrarError('Credenciales incorrectas');
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // AppBar
          Positioned(
            top: 0,
            left: -10,
            right: 0,
            child: AppBar(
              toolbarHeight: 60,
              backgroundColor: Constantes.colorSecundario,
              elevation: 8,
              iconTheme: IconThemeData(color: Colors.black),
              title: Container(
                width: 200,
                height: 50,
                margin: EdgeInsets.only(top: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Las canastitas",
                      style: TextStyle(
                        fontSize: 20,
                        color: Constantes.colorSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Logo que sobresale del AppBar hacia abajo
          Positioned(
            top: 50, // sobresale del AppBar de altura 80
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  image: DecorationImage(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Positioned(
          //   top: 50,
          //   right: 10,
          //   child: Container(
          //     // width: 60,
          //     // height: 50,
          //     // color: Colors.black26,
          //     child: widget.botonSuperior,
          //   ),
          // ),
          Positioned.fill(
            top: 130, // 80 (AppBar) + 60 (mitad del logo sobresaliente)
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _usuarioController,
                            decoration: InputDecoration(labelText: 'Usuario'),
                          ),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _iniciarSesion,
                            child: Text('Iniciar sesión'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                decoration: BoxDecoration(color: Constantes.colorPrimario),
                alignment: Alignment.center,
                child: Text("Las canastitas 2025", style: TextStyle(color: Constantes.colorSecundario, fontSize: 20, ),),),
              ) 
              )
          
        ],
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     toolbarHeight: 60,
    //     backgroundColor: Constantes.colorSecundario,
    //     elevation: 8,
    //     iconTheme: IconThemeData(color: Colors.black),
    //     title: Container(
    //       width: 200,
    //       height: 50,
    //       margin: EdgeInsets.only(top: 10, left: 10),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(
    //             "Las Canastitas",
    //             style: TextStyle(
    //               fontSize: 20,
    //               color: Constantes.colorSecundario,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    //   body: Padding(
    //     padding: const EdgeInsets.all(20.0),
    //     child: Column(
    //       children: [
    //         TextField(
    //           controller: _usuarioController,
    //           decoration: InputDecoration(labelText: 'Usuario'),
    //         ),
    //         TextField(
    //           controller: _passwordController,
    //           decoration: InputDecoration(labelText: 'Contraseña'),
    //           obscureText: true,
    //         ),
    //         SizedBox(height: 20),
    //         DropdownButtonFormField<int>(
    //           value: _sucursalSeleccionada,
    //           hint: Text('Selecciona una sucursal'),
    //           onChanged: (value) {
    //             setState(() {
    //               _sucursalSeleccionada = value;
    //             });
    //           },
    //           items: _sucursales.map((sucursal) {
    //             return DropdownMenuItem<int>(
    //               value: sucursal.id,
    //               child: Text(sucursal.nombre),
    //             );
    //           }).toList(),
    //         ),
    //         SizedBox(height: 30),
    //         ElevatedButton(
    //           onPressed: _iniciarSesion,
    //           child: Text('Iniciar sesión'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
