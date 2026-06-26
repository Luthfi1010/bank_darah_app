import 'package:flutter/material.dart';
import '../../models/stok_darah_model.dart';
import '../../services/stok_darah_service.dart';

class StokDarahScreen extends StatefulWidget {
  const StokDarahScreen({super.key});

  @override
  State<StokDarahScreen> createState() => _StokDarahScreenState();
}

class _StokDarahScreenState extends State<StokDarahScreen> {
  final _service = StokDarahService();
  List<StokDarahModel> _list = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAll();
      setState(() {
        _list = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Color _golonganColor(String golongan) {
    switch (golongan) {
      case 'A':  return Colors.blue;
      case 'B':  return Colors.green;
      case 'AB': return Colors.purple;
      case 'O':  return Colors.orange;
      default:   return Colors.grey;
    }
  }

  Color _stokColor(int jumlah) {
    if (jumlah == 0)   return Colors.red;
    if (jumlah <= 5)   return Colors.orange;
    if (jumlah <= 10)  return Colors.yellow.shade700;
    return Colors.green;
  }

  String _stokLabel(int jumlah) {
    if (jumlah == 0)  return 'Habis';
    if (jumlah <= 5)  return 'Kritis';
    if (jumlah <= 10) return 'Rendah';
    return 'Aman';
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan per golongan darah
    final Map<String, List<StokDarahModel>> grouped = {};
    for (final s in _list) {
      grouped.putIfAbsent(s.golonganDarah, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Darah'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('Belum ada data stok'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary Card
                      Card(
                        color: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _summaryItem(
                                'Total Kantong',
                                _list.fold(0, (sum, s) => sum + s.jumlahKantong).toString(),
                                Icons.water_drop,
                                Colors.red,
                              ),
                              _summaryItem(
                                'Golongan',
                                grouped.length.toString(),
                                Icons.bloodtype,
                                Colors.blue,
                              ),
                              _summaryItem(
                                'Stok Kritis',
                                _list.where((s) => s.jumlahKantong <= 5).length.toString(),
                                Icons.warning,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List per golongan
                      ...grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Golongan ${entry.key}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _golonganColor(entry.key),
                                ),
                              ),
                            ),
                            ...entry.value.map((stok) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _golonganColor(stok.golonganDarah),
                                  child: Text(
                                    '${stok.golonganDarah}${stok.rhesus}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'Rhesus ${stok.rhesus}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${stok.jumlahKantong} kantong tersedia'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _stokColor(stok.jumlahKantong).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _stokColor(stok.jumlahKantong),
                                    ),
                                  ),
                                  child: Text(
                                    _stokLabel(stok.jumlahKantong),
                                    style: TextStyle(
                                      color: _stokColor(stok.jumlahKantong),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}