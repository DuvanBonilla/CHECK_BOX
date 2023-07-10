import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:check_box/screen/formulario_page.dart';

class ResumenGeneral extends StatefulWidget {
  const ResumenGeneral({Key? key}) : super(key: key);

  @override
  State<ResumenGeneral> createState() => _ResumenGeneralState();
}

class _ResumenGeneralState extends State<ResumenGeneral> {
  List<String> _summaryList = [];

  @override
  void initState() {
    super.initState();
    _loadSummaryList();
  }

  void _loadSummaryList() async {
    final prefs = await SharedPreferences.getInstance();
    final summaryList = prefs.getStringList('summaryList') ?? [];
    setState(() {
      _summaryList = summaryList;
    });
  }

  void _refreshPage() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('contadorBotonGuardar', 1);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => FormularioPage(
          dataList: [], // Reemplaza con la lista de datos adecuada
          tapaController: TextEditingController(),
          placaController: TextEditingController(),
        ),
      ),
    );
  }

  void _clearSummaryList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Atención',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  '¿Está seguro de eliminar el resumen?',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 10.0),
                    TextButton(
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('summaryList');
                        await prefs.setInt('contadorBotonGuardar', 0);
                        setState(() {
                          _summaryList.clear();
                          //contadorBotonGuardar = 1;
                        });
                        _refreshPage();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Resumen General',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Times New Roman',
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          backgroundColor: HexColor('1f2352'),
          shadowColor: Colors.black,
          elevation: 10,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset('lib/image/LogoBlanco.png'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (_summaryList.isEmpty)
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Text(
                    'No hay datos disponibles.',
                    style: TextStyle(
                      fontFamily: "Times New Roman",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _summaryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Center(
                        child: Text(_summaryList[index]),
                      ),
                    );
                  },
                ),
              IconButton(
                onPressed: _clearSummaryList,
                icon: const Icon(Icons.delete_forever),
                iconSize: 40,
                color: HexColor('1f2352'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}