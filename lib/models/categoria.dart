class Categoria {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final String? color;
  final bool activo;
  final int totalProductos;
  final String fechaCreacion;
  final String fechaActualizacion;

  Categoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.color,
    required this.activo,
    required this.totalProductos,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      // ✅ Conversión segura de String → int
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,

      nombre: json['nombre']?.toString() ?? '',

      descripcion: json['descripcion']?.toString(),
      icono: json['icono']?.toString(),
      color: json['color']?.toString(),

      // ✅ Convertir correctamente activo (puede venir como 0/1 o true/false)
      activo:
          json['activo'] == 1 ||
          json['activo'] == true ||
          json['activo'] == '1',

      // ✅ Evitar errores si el backend no devuelve total_productos
      totalProductos: json['total_productos'] != null
          ? int.tryParse(json['total_productos'].toString()) ?? 0
          : 0,

      // ✅ Evitar null en fechas (por si vienen vacías)
      fechaCreacion: json['fecha_creacion']?.toString() ?? '',
      fechaActualizacion: json['fecha_actualizacion']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
      'activo': activo,
      'total_productos': totalProductos,
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
      'activo': activo ? 1 : 0, // ✅ enviar como número
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
      'activo': activo ? 1 : 0,
    };
  }

  Categoria copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? icono,
    String? color,
    bool? activo,
    int? totalProductos,
    String? fechaCreacion,
    String? fechaActualizacion,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      activo: activo ?? this.activo,
      totalProductos: totalProductos ?? this.totalProductos,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'Categoria{id: $id, nombre: $nombre, descripcion: $descripcion, activo: $activo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Categoria && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
