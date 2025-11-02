class ApiConfig {
  static const String baseUrl = 'http://localhost/proyecto_crud/backend/api';

  static const List<String> alternativeUrls = [
    // ✅ Deja localhost primero, porque estás en Flutter Web
    'http://localhost/proyecto_crud/backend/api',
  ];

  static const String categoriasEndpoint = '$baseUrl/categorias';
  static const String productosEndpoint = '$baseUrl/productos';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;

  static List<String> getAllTestUrls(String endpointName) {
    String suffix = '';
    if (endpointName == 'categorias') {
      suffix = '/categorias';
    } else if (endpointName == 'productos') {
      suffix = '/productos';
    }

    return alternativeUrls.map((url) => '$url$suffix').toList();
  }
}
