class Producto {
  final int id;
  final int categoriaId;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final String? imagenUrl;
  final String? sku;
  final bool activo;
  final String fechaCreacion;
  final CategoriaInfo? categoria;

  Producto({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    this.imagenUrl,
    this.sku,
    required this.activo,
    required this.fechaCreacion,
    this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      categoriaId: json['categoria_id'] != null
          ? int.tryParse(json['categoria_id'].toString()) ?? 0
          : (json['categoria']?['id'] != null
                ? int.tryParse(json['categoria']['id'].toString()) ?? 0
                : 0),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      precio: json['precio'] != null
          ? double.tryParse(json['precio'].toString()) ?? 0.0
          : 0.0,
      stock: json['stock'] != null
          ? int.tryParse(json['stock'].toString()) ?? 0
          : 0,
      imagenUrl: json['imagen_url']?.toString(),
      sku: json['sku']?.toString(),
      activo:
          json['activo'] == 1 ||
          json['activo'] == true ||
          json['activo'] == '1',
      fechaCreacion: json['fecha_creacion']?.toString() ?? '',
      categoria: json['categoria'] != null
          ? CategoriaInfo.fromJson(json['categoria'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagen_url': imagenUrl,
      'sku': sku,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion,
      'categoria': categoria?.toJson(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagen_url': imagenUrl,
      'sku': sku,
      'activo': activo ? 1 : 0,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagen_url': imagenUrl,
      'sku': sku,
      'activo': activo ? 1 : 0,
    };
  }

  Producto copyWith({
    int? id,
    int? categoriaId,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    String? imagenUrl,
    String? sku,
    bool? activo,
    String? fechaCreacion,
    CategoriaInfo? categoria,
  }) {
    return Producto(
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      sku: sku ?? this.sku,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  String toString() {
    return 'Producto{id: $id, nombre: $nombre, precio: $precio, stock: $stock}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Producto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CategoriaInfo {
  final int id;
  final String nombre;
  final String? color;
  final String? icono;

  CategoriaInfo({
    required this.id,
    required this.nombre,
    this.color,
    this.icono,
  });

  factory CategoriaInfo.fromJson(Map<String, dynamic> json) {
    return CategoriaInfo(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      nombre: json['nombre']?.toString() ?? '',
      color: json['color']?.toString(),
      icono: json['icono']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'color': color, 'icono': icono};
  }
}
