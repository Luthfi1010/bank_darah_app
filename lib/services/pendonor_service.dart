import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/pendonor_model.dart';
import 'auth_service.dart';

class PendonorService {
  final _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type':  'application/json',
      'Accept':        'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET semua pendonor
  Future<List<PendonorModel>> getAll() async {
    final response = await http.get(
      Uri.parse(ApiConstant.pendonor),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PendonorModel.fromJson(e)).toList();
    }

    throw Exception('Gagal memuat data pendonor');
  }

  // POST tambah pendonor
  Future<Map<String, dynamic>> create(PendonorModel pendonor) async {
    final response = await http.post(
      Uri.parse(ApiConstant.pendonor),
      headers: await _headers(),
      body: jsonEncode(pendonor.toJson()),
    );

    return jsonDecode(response.body);
  }

  // GET detail pendonor
  Future<PendonorModel> getById(int id) async {
    final response = await http.get(
      Uri.parse(ApiConstant.pendonorById(id)),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return PendonorModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Pendonor tidak ditemukan');
  }

  // PUT update pendonor
  Future<Map<String, dynamic>> update(int id, PendonorModel pendonor) async {
    final response = await http.put(
      Uri.parse(ApiConstant.pendonorById(id)),
      headers: await _headers(),
      body: jsonEncode(pendonor.toJson()),
    );

    return jsonDecode(response.body);
  }

  // DELETE pendonor
  Future<Map<String, dynamic>> delete(int id) async {
    final response = await http.delete(
      Uri.parse(ApiConstant.pendonorById(id)),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }
}