import 'package:flutter/material.dart';
import 'package:check_box/screen/formulario_page.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ResumenTrz extends StatefulWidget {
  const ResumenTrz({Key? key}) : super(key: key);

  @override
  State<ResumenTrz> createState() => _ResumenTrzState();
}

class _ResumenTrzState extends State<ResumenTrz> {
  List<String> _summaryList = [];
  Map<String, int> _sumMap = {};
  List<String> _filteredSummaryList = [];
  late Map<String, bool> _isCheckedMap = {};

  final TextEditingController _searchController = TextEditingController();

  void _loadSummaryList() async {
    final summaryList = await SharedPreferenceHelper.getSummaryList();
    setState(() {
      _summaryList = summaryList;
      _filteredSummaryList = summaryList;
      _sumMap = _getSumMap(summaryList);
    });
  }

  // void _removeData(String traza) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Atención'),
  //         content: const Text('¿Estás Seguro de Eliminar Esta Trazabilidad?'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Cerrar el diálogo
  //             },
  //             child: const Text('NO'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               _confirmRemoveData(
  //                   traza); // Confirmar la eliminación de la información
  //               Navigator.of(context).pop(); // Cerrar el diálogo
  //             },
  //             child: const Text('SÍ'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  void _removeData(String traza) {
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
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '¿Estás seguro de eliminar la información?',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el diálogo
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _confirmRemoveData(
                            traza); // Confirmar la eliminación de la información
                        Navigator.of(context).pop(); // Cerrar el diálogo
                      },
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0,
                        ),
                      ),
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

  void _confirmRemoveData(String traza) {
    setState(() {
      _summaryList.removeWhere((summary) => summary.contains(' : $traza : '));
      _filteredSummaryList
          .removeWhere((summary) => summary.contains(' : $traza : '));
      _sumMap = _getSumMap(_filteredSummaryList);

      // Actualizar el estado del checkbox y guardar en Shared Preferences
      _isCheckedMap.remove(traza);
      _saveCheckedStateMap();

      // Guarda _summaryList en Shared Preferences nuevamente
      SharedPreferenceHelper.saveSummaryList(_summaryList);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSummaryList();
    _loadCheckedStateMap(); // Cargar el estado del checkbox al inicio
  }

  Future<void> _loadCheckedStateMap() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final checkedStateMapJson = prefs.getString('checkedStateMap');
      if (checkedStateMapJson != null) {
        final checkedStateMap =
            Map<String, dynamic>.from(jsonDecode(checkedStateMapJson));
        _isCheckedMap =
            checkedStateMap.map((key, value) => MapEntry(key, value as bool));
      }
    });
  }

  Future<void> _saveCheckedStateMap() async {
    final prefs = await SharedPreferences.getInstance();
    final checkedStateMapJson = jsonEncode(_isCheckedMap);
    await prefs.setString('checkedStateMap', checkedStateMapJson);
  }

  Map<String, int> _getSumMap(List<String> summaryList) {
    final sumMap = <String, int>{};

    for (final summary in summaryList) {
      final parts = summary.split(' : ');
      final traza = parts[3];
      final tapa = parts[4];
      final key = '$traza:$tapa';

      final value = int.tryParse(parts[1]) ?? 0;
      sumMap[key] = (sumMap[key] ?? 0) + value;
    }

    return sumMap;
  }

  int getSumByIbm(String traza) {
    int sum = 0;

    for (final summary in _summaryList) {
      final parts = summary.split(' : ');
      if (parts[3] == traza) {
        final value = int.tryParse(parts[1]) ?? 0;
        sum += value;
      }
    }

    return sum;
  }

  List<String> getDataByIbmAndTapa(String traza, String tapa) {
    final data = _summaryList
        .where((summary) =>
            summary.contains(' : $traza : ') && summary.contains(' : $tapa : '))
        .toList();

    return data;
  }

  void _editData(String traza, String tapa, String primerdato, int newValue) {
    setState(() {
      final newData = '$newValue';
      for (var i = 0; i < _summaryList.length; i++) {
        final summary = _summaryList[i];
        final parts = summary.split(' : ');
        final firstData = parts[0];
        final summaryTraza = parts[3];
        final summaryTapa = parts[4];

        if (summaryTraza == traza &&
            summaryTapa == tapa &&
            firstData == primerdato) {
          parts[1] = newData;
          _summaryList[i] = parts.join(' : ');
          break;
        }
      }

      _sumMap = _getSumMap(_summaryList);

      // Guarda _summaryList en Shared Preferences nuevamente
      SharedPreferenceHelper.saveSummaryList(_summaryList);
    });
  }

  void _filterSummaryList(String searchQuery) {
    setState(() {
      if (searchQuery.isNotEmpty) {
        _filteredSummaryList = _summaryList
            .where((summary) =>
                summary.contains(searchQuery.toLowerCase()) ||
                summary.contains(searchQuery.toUpperCase()))
            .toList();
      } else {
        _filteredSummaryList = _summaryList;
      }
      _sumMap = _getSumMap(_filteredSummaryList);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> expansionTiles = [];
    if (_filteredSummaryList.isNotEmpty) {
      final ibmsSet = _filteredSummaryList.map((summary) {
        final parts = summary.split(' : ');
        return parts[3];
      }).toSet();

      final List<String> ibmList = ibmsSet.toList();

      ibmList.forEach((traza) {
        final List<Widget> tapasColumns = [];

        final tapasSet = _filteredSummaryList.map((summary) {
          final parts = summary.split(' : ');
          return parts[4];
        }).toSet();

        final List<String> tapasList = tapasSet.toList();

        tapasList.forEach((tapa) {
          final List<String> data = getDataByIbmAndTapa(traza, tapa);
          final List<Widget> dataList = data.map((entry) {
            final parts = entry.split(' : ');
            final firstData = parts[0];
            final secondData = parts[1];

            return Row(
              children: [
                Text('$firstData : '),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: secondData,
                    keyboardType: TextInputType.number,
                    onChanged: (newValue) {
                      _editData(
                          traza, tapa, firstData, int.tryParse(newValue) ?? 0);
                    },
                  ),
                ),
              ],
            );
          }).toList();

          final int total = _sumMap['$traza:$tapa'] ?? 0;

          final Widget tapaColumn = Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$tapa  : $total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ...dataList,
              ],
            ),
          );

          tapasColumns.add(tapaColumn);
        });

        final int totalSum = getSumByIbm(traza);

        final Widget expansionTile = ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: _isCheckedMap[traza] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _isCheckedMap[traza] =
                          value ?? false; // Actualiza el estado de selección
                      _saveCheckedStateMap();
                    });
                  },
                ),
                Expanded(
                child: Container(
                  color: _isCheckedMap[traza] ?? false ? Colors.green : null,
                  child: Text(
                    '$traza  :  $totalSum',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _removeData(traza);
                  },
                ),
              ],
            ),
          ),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tapasColumns,
              ),
            ),
          ],
        );

        expansionTiles.add(expansionTile);
      });
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Informe Trazabilidad',
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSummaryList,
                  decoration: InputDecoration(
                    labelText: 'Buscar traza',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterSummaryList('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
              if (_filteredSummaryList.isNotEmpty)
                Column(
                  children: expansionTiles,
                )
              else
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}