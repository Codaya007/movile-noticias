class ApiEndPoints {
  // static final String baseUrl = 'http://localhost:3000';
  static final String baseUrl = 'http://192.168.0.104:3000';

  static _AuthEndPoints authEndpoints = _AuthEndPoints();
  static _CrudsEndPoints crudsEndpoints = _CrudsEndPoints();
}

class _AuthEndPoints {
  final String registerEmail = '/users/auth/register';
  final String loginEmail = '/accounts/login';
}

class _CrudsEndPoints {
  final String news = '/news';
  final String comments = '/comments';
}
