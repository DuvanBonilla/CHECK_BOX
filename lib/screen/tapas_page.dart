import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../class/basic_form.dart';
import 'formulario_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TapasPage extends StatefulWidget {
  const TapasPage({Key? key}) : super(key: key);

  @override
  State<TapasPage> createState() => _MyTapasPageState();
}

class _MyTapasPageState extends State<TapasPage> {
  final List<BasicForm> _arrBasicForm = [];
  String _lastSelectedValue = '';
  final bool _isLastForm = false;

  late SharedPreferences _prefs;
  final String _dataKey = 'myDataKey';

  void _checkTextFieldValue(BasicForm form) {
    if (form.name.text.length == 20) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _add();
      });
    }
  }

  //Opciones para el ComboBox
  List<String> externalOptions = [
    'MANZANO',
    'PLATANO 20LB',
    'PLATANO EUROPEO UK',
    'PLATANO USA',
    'BURRO'
  ];

  void _clearAll() {
    setState(() {
      _arrBasicForm.clear();
    });
  }

  int? currentFocusIndex;

  void _add() async {
    final focusNode = FocusNode();

    BasicForm form = BasicForm(externalOptions, _lastSelectedValue, focusNode);
    form.hasFocus = true;
    _arrBasicForm.insert(
        0, form); // Agrega el nuevo formulario al principio de la lista
    currentFocusIndex =
        0; // Establece el enfoque en el nuevo formulario agregado
    form.requestFocus();
    // _arrBasicForm.add(form);
    setState(() {});
  }

  void _send(BuildContext context) async {
    List<Map<String, String>> dataList = [];
    for (var i = 0; i < _arrBasicForm.length; i++) {
      String trazabilidad = _arrBasicForm[i].name.text;
      String fruta = _arrBasicForm[i].getSelectedValue;
      Map<String, String> data = {'trazabilidad': trazabilidad, 'tapa': fruta};
      dataList.add(data);
    }
    await _prefs.setStringList(
        _dataKey,
        dataList
            .map((data) => '${data['trazabilidad']}:${data['tapa']}')
            .toList());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioPage(
          dataList: dataList,
          placaController: TextEditingController(),
          tapaController: TextEditingController(),
        ),
      ),
    );
  }

  void _remove(int index) {
    setState(() {
      _arrBasicForm.removeAt(index);
    });
  }

  void _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    List<String> savedData = _prefs.getStringList(_dataKey) ?? [];
    setState(() {
      _arrBasicForm.clear();
      for (String data in savedData) {
        List<String> values = data.split(':');
        String trazabilidad = values[0];
        String fruta = values[1];
        final focusNode = FocusNode();
        final newForm = BasicForm(externalOptions, fruta, focusNode);
        newForm.hasFocus = true;
        newForm.name.text = trazabilidad;
        _arrBasicForm.add(newForm);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text(
            'Tapas',
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
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset('lib/image/LogoBlanco.png'),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                children: [
                  const SizedBox(height: 5.0),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 15,
                        child: Center(
                          child: Text(
                            "#",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text(
                            "Trazabilidad",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            "Tapa",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            "Eliminar",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _arrBasicForm.length,
                    itemBuilder: (context, index) {
                      final form = _arrBasicForm[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 15,
                            child: Text("${index + 1})",
                                selectionColor: Colors.red,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 4,
                            child: TextField(
                              controller: form.name,
                              keyboardType: TextInputType.number,
                              focusNode: form.focusNode,
                              autofocus:
                                  currentFocusIndex == index && form.hasFocus,
                              onChanged: (_) => _checkTextFieldValue(form),
                              decoration: InputDecoration(
                                hintText:
                                    _isLastForm ? 'Nuevo' : form.name.text,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<String>(
                              value: form.getSelectedValue,
                              items: form.getOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  form.setSelectedValue(value!);
                                  _lastSelectedValue = value;
                                });
                              },
                              isExpanded: true,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () {
                                _remove(index);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    heroTag: 'btn3',
                    backgroundColor: HexColor('1f2352'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Container(
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
                                    '¿Desea eliminar información?',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      TextButton(
                                          onPressed: () {
                                            _clearAll();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.delete,color:Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'btn1',
                    backgroundColor: HexColor('1f2352'),
                    onPressed: _add,
                    tooltip: 'Increment',
                    child: const Icon(Icons.add,color:Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'btn2',
                    backgroundColor: HexColor('1f2352'),
                    onPressed: () => _send(context),
                    child: const Icon(Icons.send,color:Colors.white),
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