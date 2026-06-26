import 'package:flutter/material.dart';
import '../../models/pendonor_model.dart';
import '../../services/donasi_darah_service.dart';
import '../../services/pendonor_service.dart';

class DonasiDarahFormScreen extends StatefulWidget {
  const DonasiDarahFormScreen({super.key});

  @override
  State<DonasiDarahFormScreen> createState() => _DonasiDarahFormScreenState();
}

class _DonasiDarahFormScreenState extends State<DonasiDarahFormScreen> {
  final _donasiService  = DonasiDarahService();
  final _pendonorService = PendonorService();

  List<PendonorModel> _pendonorList = [];
  PendonorModel? _selectedPendonor;
  String _status = 'berhasil';
  int _jumlahKantong = 1;
  DateTime _tanggalDonor = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingPendonor = true;

  @override
  void initState() {
    super.initState();
    _loadPendonor();
  }

  Future<void> _loadPendonor() async {
    try {
      final data = await _pendonorService.getAll();
      setState(() {
        _pendonorList = data;
        _isLoadingPendonor = false;
      });
    } catch (e) {
      setState(() => _isLoadingPendonor = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalDonor,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _tanggalDonor = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedPendonor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pendonor terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _donasiService.create(
        pendonorId:    _selectedPendonor!.id,
        tanggalDonor:  _tanggalDonor.toIso8601String().split('T')[0],
        jumlahKantong: _jumlahKantong,
        status:        _status,
      );

      if (!mounted) return;

      if (result['data'] != null || result['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _status == 'berhasil'
                  ? 'Donasi berhasil! Stok darah ${_selectedPendonor!.golonganDarah}${_selectedPendonor!.rhesus} bertambah $_jumlahKantong kantong'
                  : 'Donasi dicatat dengan status gagal',
            ),
            backgroundColor: _status == 'berhasil' ? Colors.green : Colors.orange,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan donasi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Donasi Darah'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingPendonor
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pilih Pendonor
                  const Text('Pilih Pendonor',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PendonorModel>(
                    initialValue: _selectedPendonor,
                    decoration: InputDecoration(
                      hintText: 'Pilih pendonor...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _pendonorList.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text('${p.nama} (${p.golonganDarah}${p.rhesus})'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedPendonor = v),
                  ),

                  // Info pendonor terpilih
                  if (_selectedPendonor != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Golongan: ${_selectedPendonor!.golonganDarah}${_selectedPendonor!.rhesus}  |  ${_selectedPendonor!.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Tanggal Donor
                  const Text('Tanggal Donor',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(
                            '${_tanggalDonor.day}-${_tanggalDonor.month}-${_tanggalDonor.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Jumlah Kantong
                  const Text('Jumlah Kantong',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_jumlahKantong > 1) {
                            setState(() => _jumlahKantong--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle, color: Colors.red, size: 36),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$_jumlahKantong',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _jumlahKantong++),
                        icon: const Icon(Icons.add_circle, color: Colors.red, size: 36),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Status
                  const Text('Status Donasi',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _status = 'berhasil'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _status == 'berhasil'
                                  ? Colors.green
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: _status == 'berhasil'
                                        ? Colors.white
                                        : Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Berhasil',
                                  style: TextStyle(
                                    color: _status == 'berhasil'
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _status = 'gagal'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _status == 'gagal'
                                  ? Colors.red
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel,
                                    color: _status == 'gagal'
                                        ? Colors.white
                                        : Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Gagal',
                                  style: TextStyle(
                                    color: _status == 'gagal'
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Tombol Simpan
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
                          : const Text('Simpan Donasi',
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}