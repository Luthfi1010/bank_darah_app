import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/stok_darah_model.dart';
import 'auth_service.dart';

class StokDarahService {
  final _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type':  'application/json',
      'Accept':        'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<StokDarahModel>> getAll() async {
    final response = await http.get(
      Uri.parse(ApiConstant.stokDarah),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => StokDarahModel.fromJson(e)).toList();
    }

    throw Exception('Gagal memuat stok darah');
  }

  Future<Map<String, dynamic>> createOrUpdate(String golonganDarah, String rhesus, int jumlahKantong) async {
  final response = await http.post(
    Uri.parse(ApiConstant.stokDarah),
    headers: await _headers(),
    body: jsonEncode({
      'golongan_darah': golonganDarah,
      'rhesus':         rhesus,
      'jumlah_kantong': jumlahKantong,
    }),
  );

  return jsonDecode(response.body);
}
}