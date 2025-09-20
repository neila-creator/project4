// lib/screens/detail_screen.dart - UPDATED with Modern UI and Soft Orange Theme
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/siswa.dart';
import 'form_screen.dart';


class DetailScreen extends StatelessWidget {
  final Siswa siswa;

  const DetailScreen({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFDAB9), // Soft peach gradient start
              Color(0xFFFFE4E1), // Lighter peach gradient end
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with gradient
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      siswa.namaLengkap,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF8B4513)),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormScreen(siswa: siswa, isEdit: true),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9F55), Color(0xFFFFA07A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9F55).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'avatar_${siswa.id}',
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: Text(
                                  siswa.namaLengkap.isNotEmpty ? siswa.namaLengkap[0].toUpperCase() : 'S',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: Color(0xFFFF9F55),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    siswa.namaLengkap,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'NISN: ${siswa.nisn}',
                                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${siswa.jenisKelamin} • ${siswa.agama}',
                                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Detail Cards with enhanced design
                      _buildDetailCard(
                        title: 'Informasi Pribadi',
                        icon: Icons.person,
                        color: const Color(0xFFFF9F55),
                        children: [
                          _buildDetailItem('TTL', '${siswa.tempatLahir}, ${DateFormat('dd/MM/yyyy').format(siswa.tanggalLahir)}', Icons.calendar_today),
                          _buildDetailItem('No. Telp', siswa.noTelp, Icons.phone),
                          _buildDetailItem('NIK', siswa.nik, Icons.credit_card),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailCard(
                        title: 'Alamat',
                        icon: Icons.home,
                        color: const Color(0xFFFFA07A),
                        children: [
                          _buildDetailItem('Jalan & RT/RW', '${siswa.jalan} RT/RW ${siswa.rtRw}', Icons.home_filled),
                          _buildDetailItem('Dusun', siswa.dusun, Icons.home),
                          _buildDetailItem('Desa/Kecamatan', '${siswa.desa}, ${siswa.kecamatan}', Icons.location_city),
                          _buildDetailItem('Kabupaten', '${siswa.kabupaten}, ${siswa.provinsi} ${siswa.kodePos}', Icons.map),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailCard(
                        title: 'Orang Tua/Wali',
                        icon: Icons.family_restroom,
                        color: const Color(0xFFFFDAB9),
                        children: [
                          _buildParentDetail('Ayah', siswa.namaAyah, siswa.alamatAyah, Icons.man),
                          _buildParentDetail('Ibu', siswa.namaIbu, siswa.alamatIbu, Icons.woman),
                          if (siswa.namaWali != null)
                            _buildParentDetail('Wali', siswa.namaWali!, siswa.alamatWali!, Icons.family_restroom),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF8B4513)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentDetail(String title, String nama, String alamat, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF9F55).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9F55).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFFF9F55), size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title: $nama',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Alamat: $alamat',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}