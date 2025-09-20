// lib/bloc/siswa_bloc.dart
// BLoC untuk manage state CRUD siswa - upgraded versi dengan logging & validasi ringan

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/siswa.dart';
import '../services/supabase_services.dart';

class SiswaBloc extends Bloc<SiswaEvent, SiswaState> {
  final SupabaseService _service = SupabaseService();

  SiswaBloc() : super(SiswaInitial()) {
    on<LoadSiswa>(_onLoadSiswa);
    on<CreateSiswa>(_onCreateSiswa);
    on<UpdateSiswa>(_onUpdateSiswa);
    on<DeleteSiswa>(_onDeleteSiswa);
  }

  Future<void> _onLoadSiswa(LoadSiswa event, Emitter<SiswaState> emit) async {
    emit(SiswaLoading());
    try {
      final siswas = await _service.getAllSiswa();
      emit(SiswaLoaded(siswas));
      print("Loaded ${siswas.length} siswa");
    } catch (e) {
      emit(SiswaError(e.toString()));
      print("Error loading siswa: $e");
    }
  }

  Future<void> _onCreateSiswa(CreateSiswa event, Emitter<SiswaState> emit) async {
    emit(SiswaLoading());
    try {
      if (!_validateSiswa(event.siswa)) {
        emit(SiswaError("Data siswa tidak valid"));
        return;
      }

      await _service.insertSiswa(event.siswa);
      final siswas = await _service.getAllSiswa();
      emit(SiswaLoaded(siswas));
      print("Siswa created: ${event.siswa.nisn}");
    } catch (e) {
      emit(SiswaError(e.toString()));
      print("Error creating siswa: $e");
    }
  }

  Future<void> _onUpdateSiswa(UpdateSiswa event, Emitter<SiswaState> emit) async {
    emit(SiswaLoading());
    try {
      if (!_validateSiswa(event.siswa)) {
        emit(SiswaError("Data siswa tidak valid"));
        return;
      }

      await _service.updateSiswa(event.siswa);
      final siswas = await _service.getAllSiswa();
      emit(SiswaLoaded(siswas));
      print("Siswa updated: ${event.siswa.nisn}");
    } catch (e) {
      emit(SiswaError(e.toString()));
      print("Error updating siswa: $e");
    }
  }

  Future<void> _onDeleteSiswa(DeleteSiswa event, Emitter<SiswaState> emit) async {
    emit(SiswaLoading());
    try {
      await _service.deleteSiswa(event.id);
      final siswas = await _service.getAllSiswa();
      emit(SiswaLoaded(siswas));
      print("Siswa deleted: ${event.id}");
    } catch (e) {
      emit(SiswaError(e.toString()));
      print("Error deleting siswa: $e");
    }
  }

  bool _validateSiswa(Siswa siswa) {
    // Validasi sederhana, bisa dikembangkan lebih lanjut
    if (siswa.nisn.length != 10) return false;
    if (siswa.noTelp.length < 12 || siswa.noTelp.length > 15) return false;
    if (siswa.namaLengkap.isEmpty || siswa.tempatLahir.isEmpty) return false;
    if (siswa.tanggalLahir == null) return false;
    if (siswa.jenisKelamin.isEmpty || siswa.agama.isEmpty) return false;
    return true;
  }
}

// Events
abstract class SiswaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSiswa extends SiswaEvent {}

class CreateSiswa extends SiswaEvent {
  final Siswa siswa;
  CreateSiswa(this.siswa);
  @override
  List<Object?> get props => [siswa];
}

class UpdateSiswa extends SiswaEvent {
  final Siswa siswa;
  UpdateSiswa(this.siswa);
  @override
  List<Object?> get props => [siswa];
}

class DeleteSiswa extends SiswaEvent {
  final String id;
  DeleteSiswa(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class SiswaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SiswaInitial extends SiswaState {}

class SiswaLoading extends SiswaState {}

class SiswaLoaded extends SiswaState {
  final List<Siswa> siswas;
  SiswaLoaded(this.siswas);
  @override
  List<Object?> get props => [siswas];
}

class SiswaError extends SiswaState {
  final String message;
  SiswaError(this.message);
  @override
  List<Object?> get props => [message];
}
