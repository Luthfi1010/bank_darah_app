import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/donasi_darah_model.dart';
import 'auth_service.dart';

class DonasiDarahService {
  final _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type':  'application/json',
      'Accept':        'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<DonasiDarahModel>> getAll() async {
    final response = await http.get(
      Uri.parse(ApiConstant.donasiDarah),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DonasiDarahModel.fromJson(e)).toList();
    }

    throw Exception('Gagal memuat data donasi');
  }

  Future<Map<String, dynamic>> create({
    required int pendonorId,
    required String tanggalDonor,
    required int jumlahKantong,
    required String status,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstant.donasiDarah),
      headers: await _headers(),
      body: jsonEncode({
        'pendonor_id':    pendonorId,
        'tanggal_donor':  tanggalDonor,
        'jumlah_kantong': jumlahKantong,
        'status':         status,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> delete(int id) async {
    final response = await http.delete(
      Uri.parse(ApiConstant.donasiDarahById(id)),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }
}