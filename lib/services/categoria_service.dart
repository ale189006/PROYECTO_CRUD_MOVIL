import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/categoria.dart';

class CategoriaService {
  static const String _baseUrl =
      'http://localhost/proyecto_crud/backend/api/categorias';

  // ✅ Obtener todas las categorías
  static Future<List<Categoria>> getCategorias() async {
    try {
      final urls = [_baseUrl, ...ApiConfig.getAllTestUrls('categorias')];
      http.Response? response;
      String? lastError;

      for (final url in urls) {
        final finalUrl = '$url/read.php';
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
          'No se pudo conectar al backend. Último error: $lastError',
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> categoriasJson = data['data'];
          return categoriasJson
              .map((json) => Categoria.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Error desconocido en servidor');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  // ✅ Obtener una categoría por ID
  static Future<Categoria> getCategoria(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/read_one.php?id=$id'),
            headers: ApiConfig.headers,
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Categoria.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error desconocido en servidor');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener categoría: $e');
    }
  }

  // ✅ Crear nueva categoría
  static Future<Categoria> createCategoria(Categoria categoria) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/create.php'),
            headers: ApiConfig.headers,
            body: json.encode(categoria.toCreateJson()),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // ✅ Convertir ID a entero si viene como string
          final idValue = data['id'];
          final parsedId = idValue != null
              ? int.tryParse(idValue.toString())
              : null;

          return categoria.copyWith(id: parsedId);
        } else {
          throw Exception(data['message'] ?? 'Error al crear categoría');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear categoría: $e');
    }
  }

  // ✅ Actualizar categoría existente
  static Future<Categoria> updateCategoria(Categoria categoria) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/update.php'),
            headers: ApiConfig.headers,
            body: json.encode({
              'id': categoria.id,
              ...categoria.toUpdateJson(),
            }),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return categoria;
        } else {
          throw Exception(data['message'] ?? 'Error al actualizar categoría');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  // ✅ Eliminar categoría
  static Future<bool> deleteCategoria(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/delete.php'),
            headers: ApiConfig.headers,
            body: json.encode({'id': id}),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }
}
