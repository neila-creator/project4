// lib/screens/home_screen.dart - UPDATED with Enhanced Design
import 'package:data/models/siswa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/siswa_bloc.dart';
import 'form_screen.dart';
import 'detail_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SiswaBloc>().add(LoadSiswa());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB6C1), // Soft peach gradient start
              Color(0xFFFFDAB9), // Soft orange gradient end
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar with custom styling
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Siswa',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513), // Darker orange for contrast
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF8B4513)),
                      onPressed: () => context.read<SiswaBloc>().add(LoadSiswa()),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<SiswaBloc, SiswaState>(
                  builder: (context, state) {
                    if (state is SiswaLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF9F55), // Soft orange
                        ),
                      );
                    }

                    if (state is SiswaLoaded) {
                      if (state.siswas.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.school, size: 80, color: Color(0xFFFF9F55)),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada data siswa',
                                style: TextStyle(fontSize: 20, color: Color(0xFF8B4513)),
                              ),
                              const Text('Tekan tombol + untuk menambah'),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FormScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('Tambah Siswa', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9F55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<SiswaBloc>().add(LoadSiswa());
                        },
                        color: const Color(0xFFFF9F55),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: state.siswas.length,
                          itemBuilder: (context, index) {
                            final siswa = state.siswas[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white.withOpacity(0.9),
                              child: InkWell(
                                onTap: () => _navigateToDetail(context, siswa),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: const Color(0xFFFF9F55),
                                        child: Text(
                                          siswa.namaLengkap.isNotEmpty
                                              ? siswa.namaLengkap[0].toUpperCase()
                                              : 'S',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        siswa.namaLengkap,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF8B4513),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'NISN: ${siswa.nisn}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${siswa.jenisKelamin} - ${siswa.agama}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, color: Color(0xFFFF9F55)),
                                            onPressed: () => _navigateToDetail(context, siswa),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Color(0xFFFF9F55)),
                                            onPressed: () => _navigateToEdit(context, siswa),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _confirmDelete(context, siswa.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    if (state is SiswaError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Color(0xFFFF9F55)),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(fontSize: 16, color: Color(0xFF8B4513)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.read<SiswaBloc>().add(LoadSiswa()),
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9F55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Tekan tombol + untuk mulai',
                            style: TextStyle(fontSize: 16, color: Color(0xFF8B4513)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FormScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Tambah Siswa', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9F55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          ).then((_) => context.read<SiswaBloc>().add(LoadSiswa()));
        },
        backgroundColor: const Color(0xFFFF9F55),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToDetail(BuildContext context, Siswa siswa) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(siswa: siswa)),
    ).then((_) => context.read<SiswaBloc>().add(LoadSiswa()));
  }

  void _navigateToEdit(BuildContext context, Siswa siswa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(siswa: siswa, isEdit: true),
      ),
    ).then((_) => context.read<SiswaBloc>().add(LoadSiswa()));
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFFF9F55)),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yakin ingin menghapus data siswa ini?'),
            Text('Aksi ini tidak dapat dibatalkan.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF8B4513))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SiswaBloc>().add(DeleteSiswa(id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Data berhasil dihapus!'),
                    ],
                  ),
                  backgroundColor: Color(0xFFFF9F55),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9F55),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}