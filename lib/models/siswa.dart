// lib/models/siswa.dart - UPDATE
// Tambah alamat dan tanggal lahir untuk orang tua/wali

class Siswa {
  final String id;
  final String nisn;
  final String namaLengkap;
  final String jenisKelamin;
  final String agama;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String noTelp;
  final String nik;
  final String jalan;
  final String rtRw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String provinsi;
  final String kodePos;
  
  // Orang Tua dengan alamat dan tanggal lahir
  final String namaAyah;
  final String alamatAyah;
  final String namaIbu;
  final String alamatIbu;
  
  // Wali (opsional)
  final String? namaWali;
  final String? alamatWali;

  Siswa({
    required this.id,
    required this.nisn,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.agama,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.noTelp,
    required this.nik,
    required this.jalan,
    required this.rtRw,
    required this.dusun,
    required this.desa,
    required this.kecamatan,
    required this.kabupaten,
    required this.provinsi,
    required this.kodePos,
    required this.namaAyah,
    required this.alamatAyah,
    required this.namaIbu,
    required this.alamatIbu,
    this.namaWali,
    this.alamatWali,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    final lokasi = json['lokasi'] as Map<String, dynamic>? ?? {};
    final orangTua = json['orang_tua'] as Map<String, dynamic>? ?? {};
    final waliData = json['wali'] as Map<String, dynamic>? ?? {};
    
    return Siswa(
      id: json['id']?.toString() ?? '',
      nisn: json['nisn']?.toString() ?? '',
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
      agama: json['agama']?.toString() ?? '',
      tempatLahir: json['tempat_lahir']?.toString() ?? '',
      tanggalLahir: DateTime.tryParse(json['tanggal_lahir']?.toString() ?? '') ?? DateTime.now(),
      noTelp: json['no_telp']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      jalan: json['jalan']?.toString() ?? '',
      rtRw: json['rt_rw']?.toString() ?? '',
      dusun: lokasi['dusun']?.toString() ?? '',
      desa: lokasi['desa']?.toString() ?? '',
      kecamatan: lokasi['kecamatan']?.toString() ?? '',
      kabupaten: lokasi['kabupaten']?.toString() ?? '',
      provinsi: lokasi['provinsi']?.toString() ?? '',
      kodePos: lokasi['kode_pos']?.toString() ?? '',
      
      // Orang Tua data
      namaAyah: orangTua['nama_ayah']?.toString() ?? '',
      alamatAyah: orangTua['alamat_ayah']?.toString() ?? '',
      namaIbu: orangTua['nama_ibu']?.toString() ?? '',
      alamatIbu: orangTua['alamat_ibu']?.toString() ?? '',
      
      // Wali data
      namaWali: waliData['nama_wali']?.toString(),
      alamatWali: waliData['alamat_wali']?.toString(),
    );
  }

  Object? get waliId => null;

  Object? get orangTuaId => null;

  Map<String, dynamic> toJson() {
    return {
      'nisn': nisn,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'agama': agama,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir.toIso8601String(),
      'no_telp': noTelp,
      'nik': nik,
      'jalan': jalan,
      'rt_rw': rtRw,
      'dusun': dusun,
      'desa': desa,
      'kecamatan': kecamatan,
      'kabupaten': kabupaten,
      'provinsi': provinsi,
      'kode_pos': kodePos,
      'nama_ayah': namaAyah,
      'alamat_ayah': alamatAyah,
      'nama_ibu': namaIbu,
      'alamat_ibu': alamatIbu,
      'nama_wali': namaWali,
      'alamat_wali': alamatWali,
    };
  }
}