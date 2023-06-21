import 'dart:async';
// import 'package:flutter/widgets.dart';
import 'package:check_box/screen/resumen_ibm.dart';
import 'package:check_box/screen/resumen_page.dart';
import 'package:check_box/screen/resumen_trazabilidad.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormularioPage extends StatefulWidget {
  final List<Map<String, String>> dataList;
  FormularioPage({
    Key? key,
    required this.dataList,
    required this.tapaController,
    required this.placaController,
  }) : super(key: key);

  late final TextEditingController tapaController;
  late final TextEditingController placaController;
  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class SharedPreferenceHelper {
  static Future<List<String>> getSummaryList() async {
    final prefs = await SharedPreferences.getInstance();
    final summaryList = prefs.getStringList('summaryList');
    return summaryList ?? [];
  }

  static Future<void> saveSummaryList(List<String> summaryList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('summaryList', summaryList);
  }
}

//Clase de excel
class FileSaveHelper {
  static Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  static Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  static Future<void> saveAndLaunchFile(
      List<int> bytes, String fileName) async {
    final file = await _localFile(fileName);
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }
}

class _FormularioPageState extends State<FormularioPage> {
  final List<Item> _datas = generateItems(1);
  final TextEditingController trazabilidadController = TextEditingController();
  final TextEditingController tapaController = TextEditingController();
  final TextEditingController placaController = TextEditingController();
  List<String> trazabilidades = [];
  List<Map<String, String>> savedDataList = [];
  int contadorBotonGuardar = 1;
  String placaValue = '';
  String _currentCode = '';
  int _ibmCounter = 0;
  String? selectedOption = '';
  // bool _isFirstCodeEntered = false;
  bool _autoBarcodeInput = false;
  late var _focusNode = FocusNode();
  Timer? _focusTimer;

  //List<String> _savedSummaryList = [];
  //Datos para exportar excel y funciones
  final List<String> _dataList = [];
  final List<String> _summaryList =
      []; //Entrada de datos final para exportar a excel
  final FocusNode focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  void _addDataToList(String code) async {
    final text = code.trim();
    if (text.isNotEmpty) {
      // _dataList.add(text);
      _textEditingController.clear();
      if (text == "IBM") {
        _ibmCounter++;
      }
      _dataList.insert(0, text);

      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('dataList', _dataList);
      await Future.delayed(Duration.zero);
      prefs.setInt('ibmCounter', _ibmCounter);
      setState(() {});
    }
  }

  void _removeDataFromList(int index) async {
    _dataList.removeAt(index);
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('dataList', _dataList);
  }

  void _clearDataList() async {
    _dataList.clear();
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('dataList', _dataList);
  }

  void _loadSummaryList() async {
    final prefs = await SharedPreferences.getInstance();
    final summaryList = prefs.getStringList('summaryList');
    if (summaryList != null) {
      setState(() {
        _summaryList.addAll(summaryList);
        contadorBotonGuardar = 1;
      });
    }
  }

  void _clearSummaryList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atención'),
          content: const Text('¿Está Seguro de Elimiar el Resumen?'),
          actions: [
            TextButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('SÍ'),
              onPressed: () async {
                Navigator.of(context).pop();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('summaryList');
                setState(() {
                  _summaryList.clear();
                  contadorBotonGuardar = 1;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Map<String, int> _getDataCount() {
    final countMap = <String, int>{};
    for (final data in _dataList) {
      if (countMap.containsKey(data)) {
        countMap[data] = countMap[data]! + 1;
      } else {
        countMap[data] = 1;
      }
    }
    return countMap;
  }

  void _exportToExcel() async {
    final dateTime = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final formattedDateTime = dateFormat.format(dateTime);
    final weekNumber = '${dateTime.weekOfYear}';
    final dateFormatDay = DateFormat.EEEE();
    final formattedDay = dateFormatDay.format(dateTime);

    //   Crear un nuevo libro de Excel
    var excel = Excel.createExcel();

    //   Crear una hoja de cálculo en el libro de Excel
    Sheet sheetObject = excel['Sheet1'];

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = 'FECHA Y HORA';

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = 'SEMANA';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = 'DIA';

    //   Agregar encabezados a la hoja de cálculo
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
        .value = 'IBM';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
        .value = 'TOTAL/IBM';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
        .value = 'TOTAL/CAJAS';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
        .value = 'TRAZABILIDAD';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
        .value = 'TAPAS';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0))
        .value = 'PLACA';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0))
        .value = 'CONSECUTIVO';

    //   Agregar los datos a la hoja de cálculo

    var RowIndex = 1;
    for (final summary in _summaryList) {
      final summaryValues = summary.split(':');
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: RowIndex))
          .value = formattedDateTime;

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: RowIndex))
          .value = weekNumber;

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: RowIndex))
          .value = formattedDay;

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: RowIndex))
          .value = summaryValues[0].trim();
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: RowIndex))
          .value = summaryValues[1].trim();
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: RowIndex))
          .value = summaryValues[2].trim();
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: RowIndex))
          .value = summaryValues[3].trim();
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: RowIndex))
          .value = summaryValues[4].trim();
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: RowIndex))
          .value = summaryValues[5].trim();
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: RowIndex))
          .value = summaryValues[6].trim();

      RowIndex++;
    }

    var bytes = await excel.encode();
    if (bytes != null) {
      await FileSaveHelper.saveAndLaunchFile(
          bytes, 'Resumen De Operación.xlsx');
    } else {
      //     manejar el caso en que bytes es null
    }
  }

  //Finaliza funciones

  @override
  void initState() {
    super.initState();

    // Crear el objeto FocusNode
    _focusNode = FocusNode();

    // Resto del código del initState
    _loadDataList();
    _loadSummaryList();
    _initSharedPreferences().then((_) {
      _loadData();
    });
    _loadSavedValues();

    // _focusTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
    //   _focusNode.requestFocus(); // Mantiene el enfoque en el campo de texto
    // });

    _textEditingController.addListener(addCodeAutomatically);
  }

  void addCodeAutomatically() {
    final enteredCode = _textEditingController.text;
    if (enteredCode.length == 4) {
      if (!_autoBarcodeInput) {
        _addDataToList(enteredCode);
        _textEditingController.clear();
      } else {
        _autoBarcodeInput = false;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.removeListener(addCodeAutomatically);
    _textEditingController.dispose();
    _focusTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveValues() async {
    await _prefs.setString('trazabilidad', trazabilidadController.text);
    await _prefs.setString('tapa', tapaController.text);
    await _prefs.setString('placa', placaController.text);
  }

  Future<void> _loadSavedValues() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      trazabilidadController.text = _prefs.getString('trazabilidad') ?? '';
      tapaController.text = _prefs.getString('tapa') ?? '';
      placaController.text = _prefs.getString('placa') ?? '';
    });
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _saveData(String key, String value) async {
    await _prefs.setString(key, value);
  }

  void _loadData() {
    final trazabilidad = _prefs.getString('trazabilidad');
    final placa = _prefs.getString('placa');

    trazabilidadController.text = trazabilidad ?? '';
    tapaController.text = _getTapaForTrazabilidad(trazabilidad ?? '') ?? '';
    placaController.text = placa ?? '';
  }

  void _saveSummaryList(List<String> summaryList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('summaryList', summaryList);
  }

  void _loadDataList() async {
    final prefs = await SharedPreferences.getInstance();
    final dataList = prefs.getStringList('dataList');
    if (dataList != null) {
      setState(() {
        _dataList.addAll(dataList);
      });
    }
  }

  String? _getTapaForTrazabilidad(String trazabilidad) {
    for (var data in widget.dataList) {
      if (data['trazabilidad'] == trazabilidad) {
        return data['tapa'];
      }
    }
    return null;
  }

  void _mostrarMiniPantalla(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccione un resumen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResumenPage(),
                    ),
                  );
                },
                child: const Text('Placa'),
              ),
              const SizedBox(width: 16, height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResumenTrz(),
                    ),
                  );
                },
                child: const Text('Trazabilidad'),
              ),
              const SizedBox(width: 16, height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResumenIbm(),
                    ),
                  );
                },
                child: const Text('IBM'),
              ),
            ],
          ),
        );
      },
    );
  }

  late SharedPreferences _prefs;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text(
            'Formulario',
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionPanelList(
                // key: UniqueKey(),
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _datas[index].isExpanded = !isExpanded;
                  });
                },
                children: _datas.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                    backgroundColor: Colors.grey.shade300,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(item.headerValue),
                      );
                    },
                    body: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.expandedValue,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField(
                                  value: selectedOption,
                                  items: const [
                                    DropdownMenuItem(
                                      value: '',
                                      child: Text(''),
                                    ),
                                    DropdownMenuItem(
                                      value: 'BURRO',
                                      child: Text('BURRO'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'PLATANO 20LB',
                                      child: Text('PLATANO 20LB'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'PLATANO EUROPEO UK',
                                      child: Text('PLATANO EUROPEO UK'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'PLATANO USA',
                                      child: Text('PLATANO USA'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MANZANO',
                                      child: Text('MANZANO'),
                                    ),
                                  ],
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedOption = value ?? '';
                                      if (trazabilidadController.text.isEmpty) {
                                        tapaController.text = selectedOption!;
                                      }
                                      if (selectedOption!.isNotEmpty &&
                                          trazabilidadController.text.isEmpty) {
                                        trazabilidadController.text = 'mocho';
                                      }
                                    });
                                  },
                                  decoration:
                                      const InputDecoration(labelText: 'Fruta'),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: trazabilidadController,
                                  decoration: const InputDecoration(
                                    labelText: 'Trazabilidad',
                                  ),
                                  onChanged: (value) {
                                    final String trazabilidad = value;
                                    if (trazabilidad.isEmpty) {
                                      tapaController.text = item.expandedValue;
                                    } else {
                                      final String? tapa =
                                          _getTapaForTrazabilidad(trazabilidad);
                                      tapaController.text = tapa ?? '';
                                    }
                                    if (selectedOption!.isNotEmpty &&
                                        trazabilidad.isEmpty) {
                                      trazabilidadController.text = 'mocho';
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: tapaController,
                                  decoration:
                                      const InputDecoration(labelText: 'Tapa'),
                                  readOnly: true,
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    controller: placaController,
                                    decoration: const InputDecoration(
                                        labelText: 'Placa'),
                                    onTap: () {
                                      // Coloca aquí la lógica para generar el valor de Tapa
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        // placaValue = value;
                                        // placaController.text = value;
                                      });
                                      _saveValues();
                                    }),
                              ],
                            ),
                            trailing: const Icon(Icons.check_circle_outline),
                            onTap: () {
                              setState(() {
                                item.isExpanded = !item.isExpanded;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      trazabilidadController.clear();
                                      tapaController.clear();
                                      placaController.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: item.isExpanded,
                  );
                }).toList(),
              ),
              const SizedBox(width: 10, height: 10),

              // Podemos iniciar acá el ingreso de datos para el excel

              Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      autofocus: true,
                      focusNode: _focusNode,
                      controller: _textEditingController,
                      keyboardType: TextInputType.number,
                      onChanged: (enteredCode) {
                        setState(() {
                          _currentCode = enteredCode;
                          if (enteredCode.length == 4) {
                            _addDataToList(_currentCode);
                            _currentCode = '';
                            _textEditingController.clear();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!_autoBarcodeInput) {
                                FocusScope.of(context).requestFocus(_focusNode);
                              } else {
                                _autoBarcodeInput = false;
                              }
                            });
                          }
                        });

                        // Mantener el enfoque en el campo de texto
                        Timer(const Duration(milliseconds: 200), () {
                          _focusNode.requestFocus();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Ingrese IBM',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            focusNode.requestFocus();
                            // _addDataToList();
                            _addDataToList(_currentCode);
                            _currentCode = '';
                          },
                          child: const Text('Agregar'),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _exportToExcel,
                          child: const Text('Exportar a Excel'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_dataList[index] == "IBM") {
                          _ibmCounter++;
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${index + 1}. ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _dataList[index] == "IBM"
                                      ? _ibmCounter.toString()
                                      : '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text('  '),
                                Text(_dataList[index]),
                              ],
                            ),
                            // Text(_dataList[index]),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeDataFromList(index),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _clearDataList,
                    child: const Text('Borrar Todo'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final countMap = _getDataCount();
                      final summaryList = <String>[];
                      for (final key in countMap.keys) {
                        summaryList.add(
                            '$key :  ${countMap[key]} : ${_dataList.length} : ${trazabilidadController.text} : ${tapaController.text} : ${placaController.text} : ${contadorBotonGuardar.toInt()}');
                      }
                      // summaryList.add('Total cajas : ${_dataList.length}');
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Información de Cajas'),
                            content: SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: summaryList
                                      .map((summary) => Text(summary))
                                      .toList(),
                                ),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cerrar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    contadorBotonGuardar++;
                                    _summaryList.addAll(summaryList);
                                    _saveSummaryList(_summaryList);
                                    _clearDataList();
                                    trazabilidadController.clear();
                                    tapaController.clear();
                                    _textEditingController.clear();
                                    // placaController.clear();
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Guardar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Resumen'),
                  ),
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _clearSummaryList,
                    icon: const Icon(Icons.delete_forever),
                    iconSize: 40,
                    color: Colors.blue.shade400,
                  ),
                  //Eliminar resumen
                  IconButton(
                      onPressed: () {
                        _mostrarMiniPantalla(context);
                      },
                      icon: const Icon(Icons.list_alt_rounded),
                      iconSize: 40,
                      color: Colors.blue.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  bool isExpanded;
  String headerValue;
  String expandedValue;

  Item({
    required this.isExpanded,
    required this.headerValue,
    required this.expandedValue,
  });
}

List<Item> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return Item(
      isExpanded: false,
      headerValue: 'Valores',
      expandedValue: 'Ingrese la Información',
    );
  });
}
