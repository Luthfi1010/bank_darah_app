class DonasiDarahModel {
  final int id;
  final int pendonorId;
  final int userId;
  final String tanggalDonor;
  final int jumlahKantong;
  final String status;
  final Map<String, dynamic>? pendonor;

  DonasiDarahModel({
    required this.id,
    required this.pendonorId,
    required this.userId,
    required this.tanggalDonor,
    required this.jumlahKantong,
    required this.status,
    this.pendonor,
  });

  factory DonasiDarahModel.fromJson(Map<String, dynamic> json) {
    return DonasiDarahModel(
      id:            json['id'],
      pendonorId:    json['pendonor_id'],
      userId:        json['user_id'],
      tanggalDonor:  json['tanggal_donor'],
      jumlahKantong: json['jumlah_kantong'],
      status:        json['status'],
      pendonor:      json['pendonor'],
    );
  }
}