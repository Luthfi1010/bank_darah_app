class ApiConstant {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const String login    = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout   = '$baseUrl/logout';
  static const String profile  = '$baseUrl/profile';

  // Pendonor
  static const String pendonor = '$baseUrl/pendonor';
  static String pendonorById(int id) => '$baseUrl/pendonor/$id';

  // Stok Darah
static const String stokDarah = '$baseUrl/stok-darah';
static String stokDarahById(int id) => '$baseUrl/stok-darah/$id';

// Donasi Darah
static const String donasiDarah = '$baseUrl/donasi-darah';
static String donasiDarahById(int id) => '$baseUrl/donasi-darah/$id';

}