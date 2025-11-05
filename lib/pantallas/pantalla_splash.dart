import 'package:ordenes/pantallas/pantalla_inicio.dart';
import 'package:ordenes/pantallas/pantalla_iniciar_sesion.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:flutter/material.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:provider/provider.dart';

class CanastitasSplash extends StatefulWidget {
  late int duration;
  late double logoSize;

  CanastitasSplash(
      {this.duration = 500, this.logoSize = 250.0});

  @override
  CanastitasSplashState createState() => CanastitasSplashState();
}

class CanastitasSplashState extends State<CanastitasSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.duration < 1000) widget.duration = 500;
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInCirc));
    _animationController.forward();
   
  }
  
  Future<void> _verificarSesion() async {
    final sessionProvider = Provider.of<SesionProvider>(context, listen: false);
    await sessionProvider.loadSession();

    if (sessionProvider.isLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => PantallaHome(),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => PantallaInicioSesion(),
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.reset();
  }

  Widget _buildAnimation() {
    return ScaleTransition(
        scale: Tween(begin: 1.5, end: 0.6).animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInCirc)),
        child: Center(
            child: SizedBox(
                height: widget.logoSize,
                child: Image(
                  image: AssetImage('assets/logo.png'),
                      fit: BoxFit.cover,
                ))));
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: widget.duration)).then((value) {
      // Navigator.of(context).pushReplacement(
      //     CupertinoPageRoute(builder: (BuildContext context) => _home));
	   _verificarSesion();
    });

    return Scaffold(backgroundColor: Constantes.colorSecundario, body: Container(
      color: Constantes.colorSecundario, // repetir color para asegurar
      width: double.infinity,
      height: double.infinity,
      child: _buildAnimation(),
    ));
  }
}
