import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/producto.dart';

class ProductoService {
  static const String _baseUrl = ApiConfig.productosEndpoint;

  // ✅ Obtener todos los productos
  static Future<List<Producto>> getProductos({int? categoriaId}) async {
    try {
      List<String> baseUrls = ApiConfig.getAllTestUrls('productos');
      baseUrls.insert(0, _baseUrl);

      String query = '';
      if (categoriaId != null) query = '?categoria_id=$categoriaId';

      http.Response? response;
      String? lastError;

      for (String url in baseUrls) {
        String finalUrl = '$url/read.php$query';
        print('🌐 Probando conexión a: $finalUrl');

        try {
          response = await http
              .get(Uri.parse(finalUrl), headers: ApiConfig.headers)
              .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

          if (response.statusCode == 200) break;
        } catch (e) {
          lastError = e.toString();
        }
      }

      if (response == null) {
        throw Exception(
          '❌ No se pudo conectar a ninguna URL. Último error: $lastError',
        );
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> productosJson = data['data'];
          return productosJson.map((json) => Producto.fromJson(json)).toList();
        } else {
          throw Exception(
            'Error del servidor: ${data['message'] ?? 'Error desconocido'}',
          );
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  // ✅ Obtener un producto por ID
  static Future<Producto> getProducto(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/read_one.php?id=$id'),
            headers: ApiConfig.headers,
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return Producto.fromJson(data['data']);
        } else {
          throw Exception(
            'Error del servidor: ${data['message'] ?? 'Error desconocido'}',
          );
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener producto: $e');
    }
  }

  // ✅ Crear un producto nuevo
  static Future<Producto> createProducto(Producto producto) async {
    try {
      final Map<String, dynamic> body = {
        'categoria_id': producto.categoriaId,
        'nombre': producto.nombre,
        'descripcion': producto.descripcion ?? '',
        'precio': producto.precio,
        'stock': producto.stock,
        'imagen_url': producto.imagenUrl ?? '',
        'sku': producto.sku ?? '',
        'activo': producto.activo ? 1 : 0, // 👈 Asegura tipo int
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/create.php'),
            headers: ApiConfig.headers,
            body: json.encode(body),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          // Si el backend devuelve un id
          int newId = int.tryParse(data['id']?.toString() ?? '0') ?? 0;
          return producto.copyWith(id: newId);
        } else {
          throw Exception(
            'Error del servidor: ${data['message'] ?? 'Error desconocido'}',
          );
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  // ✅ Actualizar producto existente (ahora usa POST para evitar error JSON vacío)
  static Future<Producto> updateProducto(Producto producto) async {
    try {
      final Map<String, dynamic> body = {
        'id': producto.id,
        'categoria_id': producto.categoriaId,
        'nombre': producto.nombre,
        'descripcion': producto.descripcion ?? '',
        'precio': producto.precio,
        'stock': producto.stock,
        'imagen_url': producto.imagenUrl ?? '',
        'sku': producto.sku ?? '',
        'activo': producto.activo ? 1 : 0,
      };

      // 🔄 Cambiado de PUT a POST para evitar error "Formato JSON inválido o vacío"
      final response = await http
          .post(
            Uri.parse('$_baseUrl/update.php'),
            headers: ApiConfig.headers,
            body: json.encode(body),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return producto;
        } else {
          throw Exception(
            'Error del servidor: ${data['message'] ?? 'Error desconocido'}',
          );
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  // ✅ Eliminar producto
  static Future<bool> deleteProducto(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/delete.php'),
            headers: ApiConfig.headers,
            body: json.encode({'id': id}),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }
}
