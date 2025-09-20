// lib/services/supabase_service.dart - FIXED duplicate location handling
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/siswa.dart';
import '../models/lokasi.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Connectivity _connectivity = Connectivity();

  // Check koneksi
  Future<bool> _isConnected() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Error handler - FIXED (sync version)
  Future<Exception> _createError(String action, dynamic error) async {
    if (!await _isConnected()) {
      return Exception('Tidak ada koneksi internet');
    }
    if (error is PostgrestException) {
      return Exception('Supabase Error: ${error.message}');
    }
    return Exception('Error $action: ${error.toString()}');
  }

  // Get all lokasi
  Future<List<Lokasi>> getLokasi() async {
    try {
      if (!await _isConnected()) {
        throw Exception('Tidak ada koneksi internet');
      }
      
      final response = await _supabase
          .from('lokasi')
          .select()
          .order('dusun');
      
      return response.map<Lokasi>((json) => Lokasi.fromJson(json)).toList();
    } catch (e) {
      throw _createError('mengambil lokasi', e);
    }
  }

  // Search dusun - WORKING AUTOCOMPLETE
  Future<List<Lokasi>> searchDusun(String query) async {
    try {
      if (!await _isConnected()) {
        return [];
      }
      
      if (query.length < 2) return [];
      
      print('Searching for: $query');  // Debug log
      
      final response = await _supabase
          .from('lokasi')
          .select()
          .ilike('dusun', '%$query%')
          .limit(10)
          .order('dusun');
      
      final results = response.map<Lokasi>((json) => Lokasi.fromJson(json)).toList();
      print('Found ${results.length} suggestions');  // Debug log
      
      return results;
    } catch (e) {
      print('Search error: $e');  // Debug log
      throw _createError('mencari dusun', e);
    }
  }

  // FIXED: Get location ID by dusun - Handle duplicates
  Future<String> _getLocationIdByDusun(String dusun) async {
    try {
      final response = await _supabase
          .from('lokasi')
          .select('id, dusun, desa, kecamatan')
          .eq('dusun', dusun)
          .limit(1);  // FIXED: Use limit(1) instead of maybeSingle()
      
      if (response.isEmpty) {
        throw Exception('Lokasi tidak ditemukan: $dusun');
      }
      
      final result = response.first;
      final lokasiId = result['id'] as String;
      print('Found location ID: $lokasiId for dusun: $dusun');  // Debug
      
      return lokasiId;
    } catch (e) {
      print('Error getting location ID: $e');  // Debug
      throw Exception('Lokasi tidak ditemukan: $dusun');
    }
  }

  // Insert siswa - SIMPLIFIED - FIXED duplicate handling
  Future<String> insertSiswa(Siswa siswa) async {
    if (!await _isConnected()) {
      throw Exception('Tidak ada koneksi internet untuk simpan');
    }

    try {
      print('Inserting siswa: ${siswa.namaLengkap}');  // Debug

      // 1. Insert orang_tua - SIMPLIFIED
      final orangTuaJson = {
        'nama_ayah': siswa.namaAyah,
        'alamat_ayah': siswa.alamatAyah.isEmpty ? 'Sama dengan alamat siswa' : siswa.alamatAyah,
        'nama_ibu': siswa.namaIbu,
        'alamat_ibu': siswa.alamatIbu.isEmpty ? 'Sama dengan alamat siswa' : siswa.alamatIbu,
      };
      
      final otResponse = await _supabase
          .from('orang_tua')
          .insert(orangTuaJson)
          .select('id')
          .single();
      
      final otId = otResponse['id'] as String;
      print('Orang tua ID: $otId');  // Debug

      // 2. Insert wali jika ada - SIMPLIFIED
      String? waliId;
      if (siswa.namaWali != null && siswa.namaWali!.isNotEmpty) {
        final waliJson = {
          'nama_wali': siswa.namaWali,
          'alamat_wali': siswa.alamatWali?.isEmpty ?? true ? 'Sama dengan alamat siswa' : siswa.alamatWali,
        };
        
        final wResponse = await _supabase
            .from('wali')
            .insert(waliJson)
            .select('id')
            .single();
        
        waliId = wResponse['id'] as String;
        print('Wali ID: $waliId');  // Debug
      }

      // 3. FIXED: Get lokasi_id berdasarkan dusun - Handle duplicates
      final lokasiId = await _getLocationIdByDusun(siswa.dusun);
      
      // 4. Insert siswa dengan foreign keys
      final siswaJson = {
        'nisn': siswa.nisn,
        'nama_lengkap': siswa.namaLengkap,
        'jenis_kelamin': siswa.jenisKelamin,
        'agama': siswa.agama,
        'tempat_lahir': siswa.tempatLahir,
        'tanggal_lahir': siswa.tanggalLahir.toIso8601String(),
        'no_telp': siswa.noTelp,
        'nik': siswa.nik,
        'jalan': siswa.jalan,
        'rt_rw': siswa.rtRw,
        'lokasi_id': lokasiId,
        'orang_tua_id': otId,
        'wali_id': waliId,
      };

      final sResponse = await _supabase
          .from('siswa')
          .insert(siswaJson)
          .select('id')
          .single();
      
      final siswaId = sResponse['id'] as String;
      print('Siswa berhasil disimpan dengan ID: $siswaId');  // Debug
      
      return siswaId;
    } catch (e) {
      print('Insert error: $e');  // Debug
      throw _createError('menyimpan siswa', e);
    }
  }

  // Get all siswa - UPDATED untuk handle data orang tua lengkap
  Future<List<Siswa>> getAllSiswa() async {
    try {
      if (!await _isConnected()) {
        return [];
      }
      
      print('Loading all siswa...');  // Debug
      
      final response = await _supabase
          .from('siswa')
          .select('*, lokasi: lokasi_id(*), orang_tua: orang_tua_id(*), wali: wali_id(*)')
          .order('nama_lengkap');
      
      final siswas = response.map<Siswa>((json) => Siswa.fromJson(json)).toList();
      print('Loaded ${siswas.length} siswa');  // Debug
      
      return siswas;
    } catch (e) {
      print('Get all siswa error: $e');  // Debug
      throw _createError('mengambil siswa', e);
    }
  }

  // FIXED: Update location ID by dusun
  Future<String> _updateLocationIdByDusun(String dusun) async {
    try {
      final response = await _supabase
          .from('lokasi')
          .select('id, dusun, desa, kecamatan')
          .eq('dusun', dusun)
          .limit(1);
      
      if (response.isEmpty) {
        throw Exception('Lokasi tidak ditemukan: $dusun');
      }
      
      final result = response.first;
      final lokasiId = result['id'] as String;
      print('Updated location ID: $lokasiId for dusun: $dusun');  // Debug
      
      return lokasiId;
    } catch (e) {
      print('Error updating location ID: $e');  // Debug
      throw Exception('Lokasi tidak ditemukan: $dusun');
    }
  }

  // UPDATE SISWA - COMPLETE dengan orang tua/wali - FIXED duplicate handling
  Future<void> updateSiswa(Siswa siswa) async {
    if (!await _isConnected()) {
      throw Exception('Tidak ada koneksi internet untuk update');
    }

    try {
      print('Updating siswa: ${siswa.namaLengkap}');  // Debug

      // 1. Update orang_tua
      final orangTuaJson = {
        'nama_ayah': siswa.namaAyah,
        'alamat_ayah': siswa.alamatAyah,
        'nama_ibu': siswa.namaIbu,
        'alamat_ibu': siswa.alamatIbu,
      };
      
      // FIXED: Handle nullable orangTuaId
      if (siswa.orangTuaId != null) {
        await _supabase
            .from('orang_tua')
            .update(orangTuaJson)
            .eq('id', siswa.orangTuaId!);
        print('Orang tua updated');  // Debug
      } else {
        // If no orangTuaId, create new one
        final otResponse = await _supabase
            .from('orang_tua')
            .insert(orangTuaJson)
            .select('id')
            .single();
        
        final otId = otResponse['id'] as String;
        
        // Update siswa with new orangTuaId
        await _supabase
            .from('siswa')
            .update({'orang_tua_id': otId})
            .eq('id', siswa.id);
        
        print('New orang tua created: $otId');  // Debug
      }

      // 2. Handle wali
      if (siswa.namaWali != null && siswa.namaWali!.isNotEmpty) {
        if (siswa.waliId != null) {
          // Update existing wali - FIXED nullable
          final waliJson = {
            'nama_wali': siswa.namaWali,
            'alamat_wali': siswa.alamatWali,
          };
          
          await _supabase
              .from('wali')
              .update(waliJson)
              .eq('id', siswa.waliId!);  // Use ! since we checked != null
          
          print('Wali updated');  // Debug
        } else {
          // Create new wali
          final waliJson = {
            'nama_wali': siswa.namaWali,
            'alamat_wali': siswa.alamatWali,
          };
          
          final wResponse = await _supabase
              .from('wali')
              .insert(waliJson)
              .select('id')
              .single();
          
          final waliId = wResponse['id'] as String;
          
          // Update siswa wali_id
          await _supabase
              .from('siswa')
              .update({'wali_id': waliId})
              .eq('id', siswa.id);
          
          print('New wali created: $waliId');  // Debug
        }
      } else if (siswa.waliId != null) {
        // Hapus wali jika kosong - FIXED nullable
        await _supabase
            .from('wali')
            .delete()
            .eq('id', siswa.waliId!);  // Use ! since we checked != null
        
        // Update siswa wali_id to null
        await _supabase
            .from('siswa')
            .update({'wali_id': null})
            .eq('id', siswa.id);
        
        print('Wali deleted');  // Debug
      }

      // 3. FIXED: Cari lokasi_id baru jika dusun berubah
      final lokasiId = await _updateLocationIdByDusun(siswa.dusun);

      // 4. Update siswa data
      final siswaJson = {
        'nisn': siswa.nisn,
        'nama_lengkap': siswa.namaLengkap,
        'jenis_kelamin': siswa.jenisKelamin,
        'agama': siswa.agama,
        'tempat_lahir': siswa.tempatLahir,
        'tanggal_lahir': siswa.tanggalLahir.toIso8601String(),
        'no_telp': siswa.noTelp,
        'nik': siswa.nik,
        'jalan': siswa.jalan,
        'rt_rw': siswa.rtRw,
        'lokasi_id': lokasiId,
      };

      await _supabase
          .from('siswa')
          .update(siswaJson)
          .eq('id', siswa.id);
      
      print('Siswa berhasil diupdate: ${siswa.namaLengkap}');  // Debug
    } catch (e) {
      print('Update error: $e');  // Debug
      throw _createError('update siswa', e);
    }
  }

  // Delete siswa - Dengan cascade untuk related records
  Future<void> deleteSiswa(String id) async {
    if (!await _isConnected()) {
      throw Exception('Tidak ada koneksi internet untuk hapus');
    }

    try {
      print('Deleting siswa: $id');  // Debug
      
      await _supabase
          .from('siswa')
          .delete()
          .eq('id', id);
      
      print('Siswa berhasil dihapus: $id');  // Debug
    } catch (e) {
      print('Delete error: $e');  // Debug
      throw _createError('hapus siswa', e);
    }
  }

  // Get single siswa dengan detail lengkap
  Future<Siswa?> getSiswaById(String id) async {
    try {
      if (!await _isConnected()) {
        return null;
      }
      
      print('Getting siswa by ID: $id');  // Debug
      
      final response = await _supabase
          .from('siswa')
          .select('*, lokasi: lokasi_id(*), orang_tua: orang_tua_id(*), wali: wali_id(*)')
          .eq('id', id)
          .single();
      
      final siswa = Siswa.fromJson(response);
      print('Siswa found: ${siswa.namaLengkap}');  // Debug
      
      return siswa;
    } catch (e) {
      print('Get by ID error: $e');  // Debug
      throw _createError('mengambil siswa by id', e);
    }
  }

  // Search siswa by name or NISN
  Future<List<Siswa>> searchSiswa(String query) async {
    try {
      if (!await _isConnected()) {
        return [];
      }
      
      print('Searching siswa: $query');  // Debug
      
      final response = await _supabase
          .from('siswa')
          .select('*, lokasi: lokasi_id(*), orang_tua: orang_tua_id(nama_ayah, nama_ibu), wali: wali_id(nama_wali)')
          .or('nama_lengkap.ilike.%$query%,nisn.eq.$query')
          .limit(20)
          .order('nama_lengkap');
      
      final results = response.map<Siswa>((json) => Siswa.fromJson(json)).toList();
      print('Search found ${results.length} siswa');  // Debug
      
      return results;
    } catch (e) {
      print('Search siswa error: $e');  // Debug
      throw _createError('mencari siswa', e);
    }
  }

  // Get statistik siswa - SIMPLIFIED VERSION
  Future<Map<String, dynamic>> getSiswaStats() async {
    try {
      if (!await _isConnected()) {
        return {'total': 0, 'laki_laki': 0, 'perempuan': 0};
      }
      
      final allSiswa = await getAllSiswa();
      
      final total = allSiswa.length;
      final lakiLaki = allSiswa.where((s) => s.jenisKelamin == 'Laki-laki').length;
      final perempuan = allSiswa.where((s) => s.jenisKelamin == 'Perempuan').length;
      
      return {
        'total': total,
        'laki_laki': lakiLaki,
        'perempuan': perempuan,
      };
    } catch (e) {
      print('Stats error: $e');
      return {'total': 0, 'laki_laki': 0, 'perempuan': 0};
    }
  }

  // BONUS: Clean up duplicate locations (run once)
  Future<void> cleanupDuplicateLocations() async {
    try {
      print('Cleaning up duplicate locations...');
      
      // Get all locations grouped by dusun
      final response = await _supabase
          .from('lokasi')
          .select('dusun, count(*)')
          .group('dusun')
          .having('count(*),gt.1');
      
      for (var row in response) {
        final dusun = row['dusun'] as String;
        final count = row['count'] as int;
        print('Found $count duplicates for dusun: $dusun');
        
        // Keep the first one, delete others
        final keepResponse = await _supabase
            .from('lokasi')
            .select('id')
            .eq('dusun', dusun)
            .order('created_at')
            .limit(1)
            .single();
        
        final keepId = keepResponse['id'] as String;
        
        await _supabase
            .from('lokasi')
            .delete()
            .eq('dusun', dusun)
            .neq('id', keepId);
        
        print('Kept ID: $keepId for dusun: $dusun');
      }
      
      print('Cleanup completed!');
    } catch (e) {
      print('Cleanup error: $e');
    }
  }
}

extension on PostgrestFilterBuilder<PostgrestList> {
  group(String s) {}
}