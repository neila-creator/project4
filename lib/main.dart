import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/siswa_bloc.dart';
import 'screens/splash_screen.dart'; // Impor SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://fhuqkqvgfuuayxxezsno.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZodXFrcXZnZnV1YXl4eGV6c25vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjk1MzYsImV4cCI6MjA3MzY0NTUzNn0.XpfmheRvP0hp1LYVZ2NzCDeMHnPSBp6OHD3vY_sGRU8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SiswaBloc()..add(LoadSiswa()), // Mulai dengan event LoadSiswa
        ),
      ],
      child: MaterialApp(
        title: 'Student Registration',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        home: const SplashScreen(), // Gunakan SplashScreen sebagai halaman awal
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
