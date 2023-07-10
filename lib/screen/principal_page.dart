import 'package:check_box/screen/tapas_page.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class PrincipalPage extends StatelessWidget {
  const PrincipalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: HexColor('1f2352'),
        body: Stack(
          children: [
            BuildBackGroundTopCircle(context),
            BuildBackGroundBottomCircle(context),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 50,
                  bottom: 40,
                ),
                child: Column(
                  children: [
                    const Text(
                      "CAJA A CAJA",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Calibri",
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: HexColor('ffffff'),
                        borderRadius: BorderRadius.circular(75),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 4,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'lib/image/LogoAppBar.png',
                          width: 125,
                          height: 125,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 150,
                    ),
                    const Text(
                      "Iniciar Proceso",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Calibri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 70, // Ajusta el ancho deseado
                      height: 70, // Ajusta la altura deseada
                      child: FloatingActionButton(
                        heroTag: 'ButtomGo',
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(seconds: 1),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const TapasPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                final begin = 0.0;
                                final end = 1.0;
                                final curve = Curves.ease;

                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return ScaleTransition(
                                  scale: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        tooltip: 'Iniciar Proceso',
                        backgroundColor: HexColor('ffffff'),
                        elevation: 4,
                        highlightElevation: 8,
                        splashColor: Colors.grey,
                        child: Icon(
                          Icons.send,
                          color: HexColor('aecb4b'),
                          size: 42,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned BuildBackGroundBottomCircle(BuildContext context) {
    return Positioned(
      top: 0,
      child: Transform.translate(
        offset: Offset(0.0, MediaQuery.of(context).size.width / 0.54),
        child: Transform.scale(
          scale: 1.35,
          child: Container(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: HexColor('ffffff'),
              borderRadius:
                  BorderRadius.circular(MediaQuery.of(context).size.width),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 4,
                  blurRadius: 20,
                ),
              ],
            ),
            child: Align(
              alignment: const Alignment(
                0,
                -0.81,
              ),
              child: Transform.scale(
                scale: 0.5,
                child: Image.asset(
                  'lib/image/LogoColores.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned BuildBackGroundTopCircle(BuildContext context) {
    return Positioned(
      top: 0,
      child: Transform.translate(
        offset: Offset(0.0, -MediaQuery.of(context).size.width / 1.4),
        child: Transform.scale(
          scale: 1.35,
          child: Container(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: HexColor('ffffff'),
              borderRadius:
                  BorderRadius.circular(MediaQuery.of(context).size.width),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 4,
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
