// lib/screens/form_screen.dart - FULLY WORKING VERSION WITH ADD/EDIT SUPPORT + Modern UI
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/siswa_bloc.dart';
import '../models/siswa.dart';
import '../models/lokasi.dart';
import '../services/supabase_services.dart';  // FIXED import

class FormScreen extends StatefulWidget {
  final Siswa? siswa;  // OPTIONAL for edit mode
  final bool isEdit;

  const FormScreen({super.key, this.siswa, this.isEdit = false});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = SupabaseService();
  
  // Controllers
  final _nisnController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _nikController = TextEditingController();
  final _jalanController = TextEditingController();
  final _rtRwController = TextEditingController();
  final _dusunController = TextEditingController();
  
  // Orang Tua Controllers - SIMPLIFIED
  final _namaAyahController = TextEditingController();
  final _alamatAyahController = TextEditingController(text: 'Sama dengan alamat siswa');
  final _namaIbuController = TextEditingController();
  final _alamatIbuController = TextEditingController(text: 'Sama dengan alamat siswa');
  final _namaWaliController = TextEditingController();
  final _alamatWaliController = TextEditingController(text: 'Sama dengan alamat siswa');

  // State variables - SIMPLIFIED
  String? _jenisKelamin;
  String? _agama;
  DateTime? _tanggalLahir;
  Lokasi? _selectedLokasi;
  List<Lokasi> _suggestions = [];
  bool _isLoading = false;
  bool _showWaliSection = false;
  bool _isSearching = false;  // For autocomplete loading

  // Animations - Canggih UI
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Preload lokasi untuk autocomplete
    _preloadLokasi();
    
    // If edit mode, prefill data
    if (widget.isEdit && widget.siswa != null) {
      final s = widget.siswa!;
      _nisnController.text = s.nisn;
      _namaLengkapController.text = s.namaLengkap;
      _jenisKelamin = s.jenisKelamin;
      _agama = s.agama;
      _tempatLahirController.text = s.tempatLahir;
      _tanggalLahir = s.tanggalLahir;
      _noTelpController.text = s.noTelp;
      _nikController.text = s.nik;
      _jalanController.text = s.jalan;
      _rtRwController.text = s.rtRw;
      _dusunController.text = s.dusun;
      _selectedLokasi = Lokasi(
        id: '',  // ID not needed for display
        dusun: s.dusun,
        desa: s.desa,
        kecamatan: s.kecamatan,
        kabupaten: s.kabupaten,
        provinsi: s.provinsi,
        kodePos: s.kodePos,
      );
      _namaAyahController.text = s.namaAyah;
      _alamatAyahController.text = s.alamatAyah;
      _namaIbuController.text = s.namaIbu;
      _alamatIbuController.text = s.alamatIbu;
      if (s.namaWali != null) {
        _namaWaliController.text = s.namaWali!;
        _alamatWaliController.text = s.alamatWali ?? 'Sama dengan alamat siswa';
        _showWaliSection = true;
      }
    }
  }

  Future<void> _preloadLokasi() async {
    try {
      await _service.getLokasi();
    } catch (e) {
      print('Preload error: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Dispose controllers
    _nisnController.dispose();
    _namaLengkapController.dispose();
    _tempatLahirController.dispose();
    _noTelpController.dispose();
    _nikController.dispose();
    _jalanController.dispose();
    _rtRwController.dispose();
    _dusunController.dispose();
    _namaAyahController.dispose();
    _alamatAyahController.dispose();
    _namaIbuController.dispose();
    _alamatIbuController.dispose();
    _namaWaliController.dispose();
    _alamatWaliController.dispose();
    super.dispose();
  }

  // Validation functions
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Field wajib diisi';
    return null;
  }

  String? _validateNisn(String? value) {
    if (value == null || value.length != 10) return 'NISN harus 10 digit';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.length < 12 || value.length > 15) {
      return 'No. HP 12-15 digit';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Hanya angka';
    return null;
  }

  String? _validateNik(String? value) {
    if (value == null || value.length != 16) return 'NIK harus 16 digit';
    return null;
  }

  String? _validateRtRw(String? value) {
    if (value == null || !RegExp(r'^\d+/\d+$').hasMatch(value)) {
      return 'Format RT/RW (contoh: 01/02)';
    }
    return null;
  }

  // FIXED AUTOCOMPLETE - Working implementation
  Future<void> _searchDusun(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    try {
      // Delay untuk smooth UX
      await Future.delayed(const Duration(milliseconds: 300));
      
      final suggestions = await _service.searchDusun(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Gagal mencari: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectLokasi(Lokasi lokasi) {
    setState(() {
      _selectedLokasi = lokasi;
      _dusunController.text = lokasi.dusun;
      _suggestions = [];
    });
    
    // Auto-fill alamat lengkap
    final fullAddress = '${_jalanController.text.isEmpty ? 'Jalan' : _jalanController.text} RT/RW ${_rtRwController.text}, ${lokasi.dusun}, ${lokasi.desa}, ${lokasi.kecamatan}, ${lokasi.kabupaten}, ${lokasi.provinsi} ${lokasi.kodePos}';
    
    _alamatAyahController.text = fullAddress;
    _alamatIbuController.text = fullAddress;
    _alamatWaliController.text = fullAddress;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Alamat otomatis terisi!')),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleWaliSection() {
    setState(() {
      _showWaliSection = !_showWaliSection;
    });
  }

  Future<void> _showDatePicker({
    required DateTime initialDate,
    required void Function(DateTime) onDateSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 158, 72, 2),
              onPrimary: Colors.white,
              onSurface: Color.fromARGB(255, 223, 97, 24),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      onDateSelected(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Periksa field yang salah!'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedLokasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_off, color: Colors.white),
              SizedBox(width: 8),
              Text('Pilih dusun terlebih dahulu!'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_jenisKelamin == null || _agama == null || _tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.person_off, color: Colors.white),
              SizedBox(width: 8),
              Text('Lengkapi data siswa terlebih dahulu!'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Konfirmasi dengan loading
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 159, 37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.isEdit ? Icons.edit : Icons.person_add, 
                color: const Color.fromARGB(255, 230, 129, 13)
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.isEdit ? 'Konfirmasi Update' : 'Konfirmasi Penyimpanan'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${_namaLengkapController.text}'),
            Text('NISN: ${_nisnController.text}'),
            Text('Alamat: ${_selectedLokasi!.desa}, ${_selectedLokasi!.kecamatan}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 180, 67, 2)),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final siswa = Siswa(
        id: widget.isEdit ? widget.siswa!.id : '',
        nisn: _nisnController.text,
        namaLengkap: _namaLengkapController.text,
        jenisKelamin: _jenisKelamin!,
        agama: _agama!,
        tempatLahir: _tempatLahirController.text,
        tanggalLahir: _tanggalLahir!,
        noTelp: _noTelpController.text,
        nik: _nikController.text,
        jalan: _jalanController.text,
        rtRw: _rtRwController.text,
        dusun: _selectedLokasi!.dusun,
        desa: _selectedLokasi!.desa,
        kecamatan: _selectedLokasi!.kecamatan,
        kabupaten: _selectedLokasi!.kabupaten,
        provinsi: _selectedLokasi!.provinsi,
        kodePos: _selectedLokasi!.kodePos,
        
        // SIMPLIFIED - Hanya nama & alamat
        namaAyah: _namaAyahController.text,
        alamatAyah: _alamatAyahController.text,
        namaIbu: _namaIbuController.text,
        alamatIbu: _alamatIbuController.text,
        
        // Wali opsional
        namaWali: _showWaliSection && _namaWaliController.text.isNotEmpty 
          ? _namaWaliController.text 
          : null,
        alamatWali: _showWaliSection ? _alamatWaliController.text : null,
      );

      // Add to BLoC
      if (widget.isEdit) {
        context.read<SiswaBloc>().add(UpdateSiswa(siswa));
      } else {
        context.read<SiswaBloc>().add(CreateSiswa(siswa));
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Data siswa ${_namaLengkapController.text} ${widget.isEdit ? 'diperbarui' : 'berhasil disimpan'}!')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Clear form setelah success (hanya untuk add mode)
        if (!widget.isEdit) _clearForm();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal menyimpan: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _nisnController.clear();
    _namaLengkapController.clear();
    _tempatLahirController.clear();
    _noTelpController.clear();
    _nikController.clear();
    _jalanController.clear();
    _rtRwController.clear();
    _dusunController.clear();
    _namaAyahController.clear();
    _alamatAyahController.text = 'Sama dengan alamat siswa';
    _namaIbuController.clear();
    _alamatIbuController.text = 'Sama dengan alamat siswa';
    _namaWaliController.clear();
    _alamatWaliController.text = 'Sama dengan alamat siswa';
    
    setState(() {
      _jenisKelamin = null;
      _agama = null;
      _tanggalLahir = null;
      _selectedLokasi = null;
      _suggestions = [];
      _showWaliSection = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Siswa' : 'Pendaftaran Siswa'),
        backgroundColor: const Color.fromARGB(255, 235, 130, 11),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submit,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: BlocListener<SiswaBloc, SiswaState>(
          listener: (context, state) {
            if (state is SiswaError && _isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Error: ${state.message}')),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              setState(() => _isLoading = false);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Student Info Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.isEdit ? Icons.edit : Icons.school, 
                                color: const Color.fromARGB(255, 240, 196, 77), 
                                size: 24
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Informasi Siswa',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _nisnController,
                            label: 'NISN *',
                            icon: Icons.badge,
                            validator: _validateNisn,
                            keyboardType: TextInputType.number,
                          ),
                          _buildInputField(
                            controller: _namaLengkapController,
                            label: 'Nama Lengkap *',
                            icon: Icons.person,
                            validator: _validateRequired,
                          ),
                          _buildDropdownField(
                            value: _jenisKelamin,
                            label: 'Jenis Kelamin *',
                            icon: Icons.person,
                            items: ['Laki-laki', 'Perempuan'],
                            onChanged: (value) => setState(() => _jenisKelamin = value),
                            validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
                          ),
                          _buildDropdownField(
                            value: _agama,
                            label: 'Agama *',
                            icon: Icons.book,
                            items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'],
                            onChanged: (value) => setState(() => _agama = value),
                            validator: (value) => value == null ? 'Pilih agama' : null,
                          ),
                          _buildDateRow(
                            controller: _tempatLahirController,
                            date: _tanggalLahir,
                            onDateSelected: (date) => setState(() => _tanggalLahir = date),
                            validator: _validateRequired,
                          ),
                          _buildInputField(
                            controller: _noTelpController,
                            label: 'No. Telp/HP *',
                            icon: Icons.phone,
                            validator: _validatePhone,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildInputField(
                            controller: _nikController,
                            label: 'NIK *',
                            icon: Icons.credit_card,
                            validator: _validateNik,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Address Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.home, color: Colors.green, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Alamat',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _jalanController,
                            label: 'Jalan *',
                            icon: Icons.home,
                            validator: _validateRequired,
                          ),
                          _buildInputField(
                            controller: _rtRwController,
                            label: 'RT/RW *',
                            icon: Icons.home,
                            validator: _validateRtRw,
                          ),
                          // FIXED AUTOCOMPLETE DUSUN - WORKING VERSION
                          _buildDusunAutocomplete(),
                          if (_selectedLokasi != null) _buildAddressPreview(_selectedLokasi!),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Parents Card - SIMPLIFIED (tanpa tanggal lahir)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.family_restroom, color: Colors.purple, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Orang Tua/Wali',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Ayah Section - SIMPLIFIED
                          _buildParentSection(
                            title: 'Ayah',
                            icon: Icons.man,
                            namaController: _namaAyahController,
                            alamatController: _alamatAyahController,
                            isRequired: true,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Ibu Section - SIMPLIFIED
                          _buildParentSection(
                            title: 'Ibu',
                            icon: Icons.woman,
                            namaController: _namaIbuController,
                            alamatController: _alamatIbuController,
                            isRequired: true,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Wali Toggle
                          _buildWaliToggle(),
                          
                          // Wali Section
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: _showWaliSection ? null : 0,
                            child: _showWaliSection
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _buildParentSection(
                                      title: 'Wali',
                                      icon: Icons.family_restroom,
                                      namaController: _namaWaliController,
                                      alamatController: _alamatWaliController,
                                      isRequired: false,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 245, 160, 104),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Menyimpan...'),
                              ],
                            )
                          : Text(
                              '${widget.isEdit ? 'Update' : 'Simpan'} Data Siswa',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // FIXED AUTOCOMPLETE DUSUN - WORKING IMPLEMENTATION
  Widget _buildDusunAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _dusunController,
          decoration: InputDecoration(
            labelText: 'Dusun *',
            prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 230, 186, 105)),
            suffixIcon: _selectedLokasi != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedLokasi = null;
                        _dusunController.clear();
                        _suggestions = [];
                        // Reset alamat ortu
                        _alamatAyahController.text = 'Sama dengan alamat siswa';
                        _alamatIbuController.text = 'Sama dengan alamat siswa';
                        _alamatWaliController.text = 'Sama dengan alamat siswa';
                      });
                    },
                  )
                : _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color.fromARGB(255, 231, 190, 113), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            _searchDusun(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'Dusun wajib diisi';
            if (_selectedLokasi == null) return 'Pilih dusun dari daftar';
            return null;
          },
        ),
        
        // Suggestions dropdown
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(4),
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final lokasi = _suggestions[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _selectLokasi(lokasi),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            child: Text(
                              lokasi.dusun.isNotEmpty ? lokasi.dusun[0].toUpperCase() : 'D',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 240, 178, 108),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lokasi.dusun,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${lokasi.desa}, ${lokasi.kecamatan}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Input field - SINGLE IMPLEMENTATION
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    VoidCallback? onTap,
    bool enabled = true,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 247, 198, 108)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color.fromARGB(255, 240, 204, 106), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
        keyboardType: keyboardType,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  // Dropdown field
  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 233, 187, 101)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color.fromARGB(255, 233, 197, 100), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  // Date row - SIMPLIFIED
  Widget _buildDateRow({
    required TextEditingController controller,
    required DateTime? date,
    required void Function(DateTime) onDateSelected,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Tempat Lahir',
                prefixIcon: const Icon(Icons.location_city, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 238, 163, 102), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: validator,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(
                initialDate: date ?? DateTime.now(),
                onDateSelected: onDateSelected,
              ),
              child: AbsorbPointer(
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir',
                    prefixIcon: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 241, 139, 5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 233, 144, 10), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  controller: TextEditingController(
                    text: date != null ? DateFormat('dd/MM/yyyy').format(date) : '',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Address preview
  Widget _buildAddressPreview(Lokasi lokasi) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 245, 247, 127), const Color.fromARGB(255, 241, 233, 120)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Alamat Terisi Otomatis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${lokasi.desa}, ${lokasi.kecamatan}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${lokasi.kabupaten}, ${lokasi.provinsi} ${lokasi.kodePos}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Parent section - SIMPLIFIED (tanpa tanggal lahir)
  Widget _buildParentSection({
    required String title,
    required IconData icon,
    required TextEditingController namaController,
    required TextEditingController alamatController,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 235, 66, 212)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Wajib',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: namaController,
            label: 'Nama $title',
            icon: Icons.person,
            validator: isRequired ? _validateRequired : null,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: alamatController,
            label: 'Alamat $title',
            icon: Icons.home,
            validator: isRequired ? _validateRequired : null,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // Wali toggle
  Widget _buildWaliToggle() {
    return GestureDetector(
      onTap: _toggleWaliSection,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _showWaliSection ? Icons.expand_less : Icons.expand_more,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Data Wali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Opsional - Isi jika ada wali',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              _showWaliSection ? Icons.check_circle : Icons.add_circle_outline,
              color: Colors.orange,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}