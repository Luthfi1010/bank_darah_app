import 'package:flutter/material.dart';
import '../../models/pendonor_model.dart';
import '../../services/pendonor_service.dart';
import 'pendonor_form_screen.dart';

class PendonorScreen extends StatefulWidget {
  const PendonorScreen({super.key});

  @override
  State<PendonorScreen> createState() => _PendonorScreenState();
}

class _PendonorScreenState extends State<PendonorScreen> {
  final _service = PendonorService();
  late Future<List<PendonorModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

 void _load() {
  _future = _service.getAll();
  setState(() {});
}

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pendonor'),
        content: const Text('Yakin ingin menghapus pendonor ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.delete(id);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendonor berhasil dihapus')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pendonor'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PendonorFormScreen()),
  ).then((_) => _load());
},
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<PendonorModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final list = snapshot.data!;

          if (list.isEmpty) {
            return const Center(child: Text('Belum ada data pendonor'));
          }

          return RefreshIndicator(
            onRefresh: () async {
  _load();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final p = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _golonganColor(p.golonganDarah),
                      child: Text(
                        '${p.golonganDarah}${p.rhesus}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      p.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NIK: ${p.nik}'),
                        Text('📞 ${p.telepon}'),
                        Text('📍 ${p.alamat}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit',  child: Text('Edit')),
                        const PopupMenuItem(value: 'hapus', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (value) {
  if (value == 'edit') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PendonorFormScreen(pendonor: p),
      ),
    ).then((_) => _load());
  } else if (value == 'hapus') {
    _delete(p.id);
  }
},
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}