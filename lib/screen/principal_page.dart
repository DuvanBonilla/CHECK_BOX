import 'package:flutter/material.dart';
import 'package:check_box/screen/tapas_page.dart';

class PrincipalPage extends StatelessWidget {
  const PrincipalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Inicio',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Times New Roman',
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade200,
          shadowColor: Colors.black,
          elevation: 10,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset('lib/image/LogoAppBar.png'),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Caja a Caja',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 100,
                height: 100,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TapasPage()),
                    );
                  },
                  iconSize: 48,
                  color: Colors.blue.shade300,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Empezar proceso',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Times New Roman',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
