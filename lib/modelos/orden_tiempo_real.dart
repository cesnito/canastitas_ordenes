import 'dart:ui';

import 'package:ordenes/utils/constantes.dart';
import 'package:intl/intl.dart';

class OrdenTiempoReal {
  static const CREADA = 0;
  static const PREPARANDOSE = 1;
  static const LISTA = 2;
  static const ENTREGADA = 3;

  final String cliente;
  final String hora;
  final int idMesa;
  final int idOrden;
  final int ordenModificada;
  final int productos;
  final int statusOrden;
  final String tipoOrden;
  final double total;

  OrdenTiempoReal({
    required this.idOrden,
    required this.ordenModificada,
    required this.idMesa,
    required this.productos,
    required this.cliente,
    required this.statusOrden,
    required this.tipoOrden,
    required this.hora,
    required this.total,
  });

  factory OrdenTiempoReal.fromJson(Map<String, dynamic> json) {
    return OrdenTiempoReal(
      idOrden: json['idOrden'],
      ordenModificada: json['ordenModificada'] ?? 0,
      idMesa: json['idMesa'],
      productos: json['productos'],
      cliente: json['cliente'],
      statusOrden: json['statusOrden'],
      tipoOrden: json['tipoOrden'],
      hora: json['hora'],
      total: (json['total'] as num).toDouble(),
    );
  }

  String obtenerEstatusOrden() {
    String estatus = "Creada";
    if (statusOrden == CREADA) {
      estatus = "Creada";
    }
    if (statusOrden == PREPARANDOSE) {
      estatus = "Preparandose";
    }
    if (statusOrden == LISTA) {
      estatus = "Lista para entregar";
    }
    return estatus;
  }

  Color obtenerEstatusColor() {
    Color estatus = Constantes.ordenCreada;
    if (statusOrden == CREADA) {
      estatus = Constantes.ordenCreada;
    }
    if (statusOrden == PREPARANDOSE) {
      estatus = Constantes.ordenPreparacion;
    }
    if (statusOrden == LISTA) {
      estatus = Constantes.ordenLista;
    }
    return estatus;
  }

  String obtenerMesa() {
    String mesa = "Mesa ${idMesa}";
    if (idMesa == 0) {
      mesa = "Sin mesa";
    }
    return mesa;
  }

  String obtenerHoraConHace() {
    DateTime ahora = DateTime.now();

    // Parsear la hora pasada
    DateTime horaDada = DateFormat("HH:mm").parse(hora);
    horaDada = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      horaDada.hour,
      horaDada.minute,
    );

    // Formato 12 horas con am/pm
    String hora12 = DateFormat("hh:mm a").format(horaDada).toLowerCase();

    // Calcular diferencia
    Duration diff = ahora.difference(horaDada);
    String hace = "";

    if (diff.inMinutes < 60) {
      hace = "hace ${diff.inMinutes} mins";
    } else if (diff.inHours < 24) {
      int horas = diff.inHours;
      int minutos = diff.inMinutes % 60;
      if (minutos > 0) {
        hace = "hace $horas hrs $minutos mins";
      } else {
        hace = "hace $horas hrs";
      }
    } else {
      hace = "hace más de un día";
    }

    return "$hora12 ($hace)";
  }

  bool esOrdenModificada(){ 
    return ordenModificada == 1;
  }

  bool ordenLista() {
    return statusOrden == LISTA;
  }
  bool ordenPreparandose() {
    return statusOrden == PREPARANDOSE;
  }
}
