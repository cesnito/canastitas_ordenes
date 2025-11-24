import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ordenes/modelos/orden_tiempo_real.dart';

class OrdenMuestra {
  final int idOrden;
  final int idUsuario;
  final int statusOrden;
  final int numeroMesa;
  final int idServicioEntrega;
  final int idSucursal;
  final String nombreCliente;
  final double total;
  final int metodoPago;
  final double totalEnApp;
  final String notas;
  final int esParaLlevar;
  final String creado;
  final String actualizado;

  const OrdenMuestra({
    required this.idOrden,
    required this.idUsuario,
    required this.statusOrden,
    required this.numeroMesa,
    required this.idServicioEntrega,
    required this.idSucursal,
    required this.nombreCliente,
    required this.total,
    required this.metodoPago,
    required this.totalEnApp,
    required this.notas,
    required this.esParaLlevar,
    required this.creado,
    required this.actualizado,
  });

  factory OrdenMuestra.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return OrdenMuestra(
      idOrden: parseInt(json['idOrden']),
      idUsuario: parseInt(json['idUsuario']),
      statusOrden: parseInt(json['statusOrden']),
      numeroMesa: parseInt(json['numeroMesa']),
      idServicioEntrega: parseInt(json['idServicioEntrega']),
      idSucursal: parseInt(json['idSucursal']),
      nombreCliente: json['nombreCliente'] ?? '',
      total: parseDouble(json['total']),
      metodoPago: parseInt(json['metodoPago']),
      totalEnApp: parseDouble(json['totalEnApp']),
      notas: json['notas'] ?? '',
      esParaLlevar: parseInt(json['esParaLlevar']),
      creado: json['creado'] ?? '',
      actualizado: json['actualizado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'idOrden': idOrden,
    'idUsuario': idUsuario,
    'statusOrden': statusOrden,
    'numeroMesa': numeroMesa,
    'idServicioEntrega': idServicioEntrega,
    'idSucursal': idSucursal,
    'nombreCliente': nombreCliente,
    'total': total.toStringAsFixed(2),
    'metodoPago': metodoPago,
    'totalEnApp': totalEnApp.toStringAsFixed(2),
    'notas': notas,
    'esParaLlevar': esParaLlevar,
    'creado': creado,
    'actualizado': actualizado,
  };

  String get estatusTexto {
    switch (statusOrden) {
      case -1:
        return 'Cancelada';
      case 0:
        return 'Creada';
      case 1:
        return 'Preparándose';
      case 2:
        return 'Lista';
      case 3:
        return 'Entregada';
      case 4:
        return 'Cobrada / Finalizada';
      default:
        return 'Desconocido';
    }
  }
  String get estatusMetodoPago {
    switch (metodoPago) {
      case 1:
        return 'Efectivo';
      case 2:
        return 'Tarjeta';
      case 3:
        return 'Transferencia';
      case 4:
        return 'Otro';
      default:
        return 'Desconocido';
    }
  }

  IconData getIconoMetodoPago() {
  switch (metodoPago) {
    case 1: return Icons.payments;        // efectivo
    case 2: return Icons.credit_card;     // tarjeta
    case 3: return Icons.account_balance; // transferencia
    case 4: return Icons.more_horiz;      // otro
    default: return Icons.help_outline;
  }
}

  String tiempoQueTomo() {
  try {
    final inicio = DateFormat('yyyy-MM-dd HH:mm:ss').parse(creado);
    final fin = DateFormat('yyyy-MM-dd HH:mm:ss').parse(actualizado);

    final diff = fin.difference(inicio).inMinutes;
    return "Tomó $diff mins";
  } catch (e) {
    return "";
  }
}

  OrdenTiempoReal toOrdenRT() {
  return OrdenTiempoReal(
    idOrden: idOrden,
    ordenModificada: 1,
    idMesa: numeroMesa,
    productos: 0,
    cliente: nombreCliente ?? "Sin nombre",
    statusOrden: statusOrden ?? 0,
    tipoOrden: "Desconocido",
    hora: "00:00",
    total: total ?? 0.0,
  );
}
}
