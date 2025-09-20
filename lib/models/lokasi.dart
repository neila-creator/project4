// lib/models/lokasi.dart - FIXED jika perlu jalan field
class Lokasi {
  final String id;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String provinsi;
  final String kodePos;
  final String? jalan;  // Optional jalan field

  Lokasi({
    required this.id,
    required this.dusun,
    required this.desa,
    required this.kecamatan,
    required this.kabupaten,
    required this.provinsi,
    required this.kodePos,
    this.jalan,
  });

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      id: json['id']?.toString() ?? '',
      dusun: json['dusun']?.toString() ?? '',
      desa: json['desa']?.toString() ?? '',
      kecamatan: json['kecamatan']?.toString() ?? '',
      kabupaten: json['kabupaten']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      kodePos: json['kode_pos']?.toString() ?? '',
      jalan: json['jalan']?.toString(), // Optional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dusun': dusun,
      'desa': desa,
      'kecamatan': kecamatan,
      'kabupaten': kabupaten,
      'provinsi': provinsi,
      'kode_pos': kodePos,
      if (jalan != null) 'jalan': jalan,
    };
  }
}