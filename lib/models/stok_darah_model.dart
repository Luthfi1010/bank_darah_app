class StokDarahModel {
  final int id;
  final String golonganDarah;
  final String rhesus;
  final int jumlahKantong;

  StokDarahModel({
    required this.id,
    required this.golonganDarah,
    required this.rhesus,
    required this.jumlahKantong,
  });

  factory StokDarahModel.fromJson(Map<String, dynamic> json) {
    return StokDarahModel(
      id:            json['id'],
      golonganDarah: json['golongan_darah'],
      rhesus:        json['rhesus'],
      jumlahKantong: json['jumlah_kantong'],
    );
  }
}