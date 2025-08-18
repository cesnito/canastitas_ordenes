import 'package:flutter/material.dart';
import 'package:ordenes/componentes/app_canastitas.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:ordenes/widgets/para_llevar.dart';

class TipoConsumoScreen extends StatefulWidget {
  const TipoConsumoScreen({Key? key}) : super(key: key);

  @override
  State<TipoConsumoScreen> createState() => _TipoConsumoScreenState();
}

class _TipoConsumoScreenState extends State<TipoConsumoScreen> {
  bool _isParaLlevar = false;

  void _confirmarSeleccion() {
    final mensaje = _isParaLlevar ? "Has elegido: Para llevar" : "Has elegido: Comer aquí";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );

    // Si quieres devolver el resultado a otra pantalla:
    // Navigator.pop(context, _isParaLlevar);
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("Tipo de consumo"),
    //     backgroundColor: Constantes.colorPrimario,
    //   ),
    //   body: ,
    // );
    return AppCanastitas(body: [Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "¿Cómo deseas tu pedido?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ParaLlevarSwitch(
              isParaLlevarPorDefecto: false,
              onChanged: (value) {
                setState(() {
                  _isParaLlevar = value;
                });
              },
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constantes.colorPrimario,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _confirmarSeleccion,
              child: const Text(
                "Confirmar selección",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      )]);
  }
}
