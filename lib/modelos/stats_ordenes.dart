class EstadisticasOrdenes {
  final int hamburguesas;
  final int hotdogs;
  final int papasfritas;
  final int combos3x50;
  final int combos3x80;
  final int paquetehamburguesapapas;

  EstadisticasOrdenes({
    required this.hamburguesas,
    required this.hotdogs,
    required this.papasfritas,
    required this.combos3x50,
    required this.combos3x80,
    required this.paquetehamburguesapapas,
  });

  factory EstadisticasOrdenes.fromJson(Map<String, dynamic> json) {
  int toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  return EstadisticasOrdenes(
    hamburguesas: toInt(json["hamburguesas"]),
    hotdogs: toInt(json["hotdogs"]),
    papasfritas: toInt(json["papasfritas"]),
    combos3x50: toInt(json["combos3x50"]),
    combos3x80: toInt(json["combos3x80"]),
    paquetehamburguesapapas: toInt(json["paquetehamburguesapapas"]),
  );
}

}
