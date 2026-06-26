import 'package:flutter/material.dart';
import '../../models/pendonor_model.dart';
import '../../services/pendonor_service.dart';

class PendonorFormScreen extends StatefulWidget {
  final PendonorModel? pendonor;
  const PendonorFormScreen({super.key, this.pendonor});

  @override
  State<PendonorFormScreen> createState() => _PendonorFormScreenState();
}

class _PendonorFormScreenState extends State<PendonorFormScreen> {
  final _service        = PendonorService();
  final _namaController = TextEditingController();
  final _nikController  = TextEditingController();
  final _alamatController   = TextEditingController();
  final _teleponController  = TextEditingController();

  String _jenisKelamin  = 'L';
  String _golonganDarah = 'A';
  String _rhesus        = '+';
  bool _isLoading       = false;

  bool get _isEdit => widget.pendonor != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.pendonor!;
      _namaController.text    = p.nama;
      _nikController.text     = p.nik;
      _alamatController.text  = p.alamat;
      _teleponController.text = p.telepon;
      _jenisKelamin           = p.jenisKelamin;
      _golonganDarah          = p.golonganDarah;
      _rhesus                 = p.rhesus;
    }
  }

  Future<void> _submit() async {
    if (_namaController.text.isEmpty ||
        _nikController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _teleponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pendonor = PendonorModel(
        id:            _isEdit ? widget.pendonor!.id : 0,
        nama:          _namaController.text.trim(),
        nik:           _nikController.text.trim(),
        jenisKelamin:  _jenisKelamin,
        golonganDarah: _golonganDarah,
        rhesus:        _rhesus,
        alamat:        _alamatController.text.trim(),
        telepon:       _teleponController.text.trim(),
      );

      if (_isEdit) {
        await _service.update(widget.pendonor!.id, pendonor);
      } else {
        await _service.create(pendonor);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Pendonor diupdate' : 'Pendonor ditambahkan')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown<T>(String label, T value, List<T> items, void Function(T?) onChanged) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Pendonor' : 'Tambah Pendonor'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField('Nama Lengkap', _namaController),
            const SizedBox(height: 16),
            _buildTextField('NIK', _nikController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildDropdown('Jenis Kelamin', _jenisKelamin, ['L', 'P'],
                (v) => setState(() => _jenisKelamin = v!)),
            const SizedBox(height: 16),
            _buildDropdown('Golongan Darah', _golonganDarah, ['A', 'B', 'AB', 'O'],
                (v) => setState(() => _golonganDarah = v!)),
            const SizedBox(height: 16),
            _buildDropdown('Rhesus', _rhesus, ['+', '-'],
                (v) => setState(() => _rhesus = v!)),
            const SizedBox(height: 16),
            _buildTextField('Alamat', _alamatController),
            const SizedBox(height: 16),
            _buildTextField('Telepon', _teleponController, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEdit ? 'Update' : 'Simpan',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}