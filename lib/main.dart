// import 'package:app_check_box/screen/tapas_page.dart';
// import 'package:app_check_box/screen/principal_page.dart';
import 'package:check_box/screen/principal_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CajasApp());

class CajasApp extends StatelessWidget {
  const CajasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App Check Box',
      home: PrincipalPage(),
    );
  }
}
