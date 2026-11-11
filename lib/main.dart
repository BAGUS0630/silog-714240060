import 'package:flutter/material.dart';

import 'data/preferensi.dart';
import 'tampilan/daftar_pengiriman_page.dart';

void main() => runApp(const SiLogApp());

class SiLogApp extends StatefulWidget {
  const SiLogApp({super.key});

  static SiLogAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<SiLogAppState>();

  @override
  State<SiLogApp> createState() => SiLogAppState();
}

class SiLogAppState extends State<SiLogApp> {
  final _pref = Preferensi();
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _muatModeGelap();
  }

  Future<void> _muatModeGelap() async {
    final gelap = await _pref.modeGelap();
    if (mounted) {
      setState(() {
        _themeMode = gelap ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  Future<void> ubahModeGelap(bool gelap) async {
    await _pref.setModeGelap(gelap);
    if (mounted) {
      setState(() {
        _themeMode = gelap ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiLog',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const DaftarPengirimanPage(),
    );
  }
}
