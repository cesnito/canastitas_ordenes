import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ordenes/componentes/app_canastitas.dart';
import 'package:ordenes/modelos/orden_tiempo_real.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:provider/provider.dart';

class PantallaHome extends StatefulWidget {
  @override
  _PantallaHomeState createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  late DatabaseReference _ordenesRef;

@override
void initState() {
  super.initState();
  final sesion = Provider.of<SesionProvider>(context, listen: false).session!;
  int valor = sesion.idSucursal;
  _ordenesRef = FirebaseDatabase.instance.ref().child('ordenes/$valor');
}

  @override
  Widget build(BuildContext context) {
    return AppCanastitas(
      selectedIndex: 0,
      title: "Las canastitas",
      body: [
        StreamBuilder<DatabaseEvent>(
          stream: _ordenesRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final data =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              final ordenesPendientes = data.entries
                  // .where((e) => e.value['status'] == 'pendiente')
                  .toList();

              if (ordenesPendientes.isEmpty) {
                return Center(child: Text('No hay órdenes pendientes.'));
              }
              return Container(
                padding: EdgeInsets.all(5),
                height: MediaQuery.of(context).size.height - 270,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: ListView.builder(
                  itemCount: ordenesPendientes.length,
                  itemBuilder: (context, index) {
                    final _raworden = Map<String, dynamic>.from(
                      ordenesPendientes[index].value as Map,
                    );
                    OrdenTiempoReal orden = OrdenTiempoReal.fromJson(_raworden);
                    return Container(
                      // padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 100,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          // fit: BoxFit.cover,
                                          // scale: 0.2,
                                          image: AssetImage(
                                            'assets/deliver/${orden.tipoOrden}.png',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                        ),
                                        color: orden.obtenerEstatusColor(),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Orden #${orden.idOrden}",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            "${orden.obtenerEstatusOrden()}",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          Text(
                                            "${orden.obtenerHoraConHace()} - ${orden.obtenerMesa()}",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 45,
                            color: Colors.black,
                            margin: EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text(
                                      "${orden.cliente}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Constantes.colorPrimario,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: double.infinity,
                                    color: Constantes.colorSecundario,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.output_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        // Navegar a la pantalla de detalles pasando la orden
                                        Navigator.pushNamed(
                                          context,
                                          '/detallesOrdenCreada', // ruta definida en tu navigator
                                          arguments:
                                              orden, // pasas el objeto orden si quieres
                                        );
                                        // Navigator.pushReplacementNamed(context, '/detallesOrden');
                                      },
                                      tooltip: 'Ver detalles',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(child: Text('No hay ordenes pendientes'));
            }
          },
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.pushNamed(context, '/ordenar');
          Navigator.pushNamed(context, '/tipoconsumo');
        },
        child: Icon(Icons.add_shopping_cart),
        backgroundColor: Constantes.colorPrimario,
      ),
    );
  }
}
