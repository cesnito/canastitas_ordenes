import 'package:ordenes/modelos/usuario.dart';
import 'package:ordenes/pantallas/pantalla_inicio.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/servicios/servicio_api.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:flutter/material.dart';
import 'package:ordenes/utils/haptic.dart';
import 'package:provider/provider.dart';

class AppCanastitas extends StatefulWidget {
  final String? title;
  final List<Widget> body;
  final Widget? botonSuperior;
  final FloatingActionButton? floatingActionButton;
  final int selectedIndex;
  final Function(int)? onTabSelected;
  final VoidCallback? onBackPresionado;
  final bool esEdicion;

  const AppCanastitas({
    required this.body,
    this.title,
    this.floatingActionButton,
    this.selectedIndex = 1,
    this.onTabSelected,
    this.botonSuperior,
    this.onBackPresionado,
    this.esEdicion = false,
    Key? key,
  }) : super(key: key);

  @override
  State<AppCanastitas> createState() => AppCanastitasState();
}

class AppCanastitasState extends State<AppCanastitas> {
  bool _checking = true;
  final ServicioAPI _apiService = ServicioAPI();
  late final Usuario sesion;

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    sesion = Provider.of<SesionProvider>(context, listen: false).session!;

    if (sesion != null) {
      setState(() {
        _checking = false;
      });
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => PantallaHome()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return PopScope(
      canPop: false, // Evita que se cierre solo
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Ejecutar solo si la función está definida
          if (widget.onBackPresionado != null) {
            widget.onBackPresionado!();
          }
        }
      },
      child: Scaffold(
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
                backgroundColor: (!widget.esEdicion)
                    ? Constantes.colorPrimario
                    : Constantes.colorSecundario,
                elevation: 8,
                iconTheme: (widget.esEdicion)
                    ? IconThemeData(color: Colors.red)
                    : IconThemeData(color: Colors.black),
                title: (widget.esEdicion)
                    ? Container(
                        width: 200,
                        height: 50,
                        margin: EdgeInsets.only(top: 10, left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Modificando",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Orden",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: 200,
                        height: 50,
                        margin: EdgeInsets.only(top: 10, left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sesion.nombre,
                              style: TextStyle(
                                fontSize: 20,
                                color: Constantes.colorSecundario,
                              ),
                            ),
                            Text(
                              sesion.perfil,
                              style: TextStyle(
                                fontSize: 17,
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
            Positioned(
              top: 50,
              right: 10,
              child: Container(
                // width: 60,
                // height: 50,
                // color: Colors.black26,
                child: widget.botonSuperior,
              ),
            ),

            // Contenido de la app, debajo del AppBar y el logo
            Positioned.fill(
              top: 130, // 80 (AppBar) + 60 (mitad del logo sobresaliente)
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: SingleChildScrollView(
                  child: Column(children: widget.body),
                ),
              ),
              // child: SingleChildScrollView(
              //   child: Column(children: widget.body),
              // ),
            ),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Fija los colores aunque tengas más de 3 items
          currentIndex: widget.selectedIndex,
          selectedItemColor: Constantes.colorPrimario,
          unselectedItemColor: Colors.black54, // Color de los no seleccionados
          // currentIndex: widget.selectedIndex,
          // selectedItemColor: Constantes.colorPrimario,
          // onTap: widget.onTabSelected ?? (_) {},
          onTap: (index) {
            Haptic.sense();
            if (index == widget.selectedIndex) {
              return;
            }
            if (index == 0) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (Route<dynamic> route) => false,
              );
            } else if (index == 1) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/ordenar',
                (Route<dynamic> route) => false,
              );
            } 
            else if (index == 2) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/ordenes',
                (Route<dynamic> route) => false,
              );
            }  
            else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cerrar sesión'),
                  content: Text('¿Estás seguro que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el diálogo
                      },
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<SesionProvider>(
                          context,
                          listen: false,
                        ).clearSession();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text('Sí'),
                    ),
                  ],
                ),
              );
            }
            // if (index == 2) Navigator.pushReplacementNamed(context, '/perfil');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Nueva orden',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), 
              label: 'Ordenes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Cerrar sesión',
            ),
          ],
        ),
      ),
    );
  }
}
