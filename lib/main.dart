import 'package:flutter/material.dart';
void main() {
runApp(const SiLogApp());
}
class SiLogApp extends StatelessWidget {
const SiLogApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'SiLog',
debugShowCheckedModeBanner: false,
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 161, 225, 10)),
useMaterial3: true,
),
home: const BerandaPage(),
);
}
}
class BerandaPage extends StatelessWidget {
const BerandaPage({super.key});
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('SiLog - Modul 1')),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: const [
Icon(Icons.local_shipping, size: 72),
SizedBox(height: 16),
Text(
'Muhammad Bagus Tri Atmaja',
style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
SizedBox(height: 16),
Text(
'NIM: 714240060',
style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
SizedBox(height: 8),
Text('Lingkungan pengembangan siap digunakan'),
],
),
),
);
}
}