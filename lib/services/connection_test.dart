import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ConnectionTest {
  static Future<Map<String, dynamic>> testConnection() async {
    List<String> urls = [
      'http://localhost/proyecto_crud/backend/api/categorias/read.php',
      'http://127.0.0.1/proyecto_crud/backend/api/categorias/read.php',
      'http://localhost:8080/proyecto_crud/backend/api/categorias/read.php',
      'http://127.0.0.1:8080/proyecto_crud/backend/api/categorias/read.php',
    ];

    Map<String, dynamic> results = {
      'working_urls': [],
      'failed_urls': [],
      'recommendations': [],
    };

    for (String url in urls) {
      try {
        final response = await http
            .get(Uri.parse(url), headers: ApiConfig.headers)
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          results['working_urls'].add(url);
        } else {
          results['failed_urls'].add({
            'url': url,
            'status': response.statusCode,
            'error': 'HTTP ${response.statusCode}',
          });
        }
      } catch (e) {
        results['failed_urls'].add({
          'url': url,
          'status': 'ERROR',
          'error': e.toString(),
        });
      }
    }

    // Generar recomendaciones
    if (results['working_urls'].isNotEmpty) {
      results['recommendations'].add('Usar: ${results['working_urls'].first}');
    } else {
      results['recommendations'].add('Verificar que XAMPP esté ejecutándose');
      results['recommendations'].add(
        'Verificar que Apache esté en el puerto correcto',
      );
      results['recommendations'].add(
        'Probar con tu IP local (ej: http://192.168.1.100/proyecto_crud/backend/api/categorias/read.php)',
      );
    }

    return results;
  }
}
