import 'package:practica_04/utils/api_endpoints.dart';

class Utils {
  static String replaceBaseUrl(String url) {
    return url.replaceAll('http://localhost:3000', ApiEndPoints.baseUrl);
  }
}
