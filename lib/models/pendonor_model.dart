class PendonorModel {
  final int id;
  final String nama;
  final String nik;
  final String jenisKelamin;
  final String golonganDarah;
  final String rhesus;
  final String alamat;
  final String telepon;

  PendonorModel({
    required this.id,
    required this.nama,
    required this.nik,
    required this.jenisKelamin,
    required this.golonganDarah,
    required this.rhesus,
    required this.alamat,
    required this.telepon,
  });

  factory PendonorModel.fromJson(Map<String, dynamic> json) {
    return PendonorModel(
      id:            json['id'],
      nama:          json['nama'],
      nik:           json['nik'],
      jenisKelamin:  json['jenis_kelamin'],
      golonganDarah: json['golongan_darah'],
      rhesus:        json['rhesus'],
      alamat:        json['alamat'],
      telepon:       json['telepon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama':           nama,
      'nik':            nik,
      'jenis_kelamin':  jenisKelamin,
      'golongan_darah': golonganDarah,
      'rhesus':         rhesus,
      'alamat':         alamat,
      'telepon':        telepon,
    };
  }
}