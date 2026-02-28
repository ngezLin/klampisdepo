class ApiEndpoints {
  // Replace with actual local IP for emulator or device testing
  // e.g. 192.168.1.5 for local network, or 10.0.2.2 for Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  static const String login = '/auth/login';
  static const String items = '/items';
  static const String transactions = '/transactions';
  static const String cashSessions = '/cash-sessions';
}
