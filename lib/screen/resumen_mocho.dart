// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:check_box/screen/formulario_page.dart';
import 'package:hexcolor/hexcolor.dart';

class ResumenMxP extends StatefulWidget {
  const ResumenMxP({Key? key}) : super(key: key);

  @override
  State<ResumenMxP> createState() => _ResumenMxPState();
}

// trae la información principal
class _ResumenMxPState extends State<ResumenMxP> {
  List<String> _summaryList = [];
  Map<String, int> _sumMap = {};

  @override
  void initState() {
    super.initState();
    _loadSummaryList();
  }

  void _loadSummaryList() async {
    final summaryList = await SharedPreferenceHelper.getSummaryList();
    setState(() {
      _summaryList = summaryList;
      _sumMap = _getSumMap(summaryList);
    });
  }

  // trae solo las que tengan como trazabilidad mocho
  Map<String, int> _getSumMap(List<String> summaryList) {
    final sumMap = <String, int>{};
    for (final summary in summaryList) {
      final parts = summary.split(' : ');
      if (parts[3] == 'mocho') {
        final placa = parts[5];
        final tapa = parts[4];
        final key = '$placa:$tapa';
        final value = int.tryParse(parts[1]) ?? 0;
        sumMap[key] = (sumMap[key] ?? 0) + value;
      }
    }

    return sumMap;
  }

  // SUMA LAS CAJAS POR PLACA y traza = mocho
  int getSumByPlaca(String placa) {
    int sum = 0;

    for (final summary in _summaryList) {
      final parts = summary.split(' : ');
      if (parts[5].trim() == placa && parts[3].trim() == 'mocho') {
        final value = int.tryParse(parts[1].trim()) ?? 0;
        sum += value;
      }
    }
    return sum;
  }

  List<String> getDataByPlacaAndTapa(String placa, String tapa, String traza) {
    final data = _summaryList
        .where((summary) {
          final parts = summary.split(' : ');
          return parts[5] == placa && parts[4] == tapa && parts[3] == traza;
        })
        .toList();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> expansionTiles = [];

    if (_summaryList.isNotEmpty) {
      final placasSet = _summaryList.map((summary) {
        final parts = summary.split(' : ');
        return parts[5];
      }).toSet();

      final List<String> placasList = placasSet.toList();

      placasList.forEach((placa) {
        final List<Widget> tapasColumns = [];

        final tapasSet = _summaryList.where((summary) {
          final parts = summary.split(' : ');
          return parts[3] == 'mocho';
        })
        .map((summary) {
          final parts = summary.split(' : ');
          return parts[4];
        })
        .toSet();

        final List<String> tapasList = tapasSet.toList();

        tapasList.forEach((tapa) {
          final List<String> data = getDataByPlacaAndTapa(placa, tapa, 'mocho');
          final Map<String, int> secondDataMap = {};

          data.forEach((entry) {
            final parts = entry.split(' : ');
            final firstData = parts[0];
            final secondData = int.tryParse(parts[1]) ?? 0;

            final association = '$firstData:$tapa';

            if (secondDataMap.containsKey(association)) {
              secondDataMap[association] = secondDataMap[association]! + secondData;
            } else {
              secondDataMap[association] = secondData;
            }
          });

          final List<Widget> dataList = secondDataMap.entries.map((entry) {
            final parts = entry.key.split(':');
            final firstData = parts[0];
            final combinedSecondData = entry.value;

            return Text('$firstData : $combinedSecondData');
          }).toList();

          final int total = _sumMap['$placa:$tapa'] ?? 0;

          final Widget tapaColumn = Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$tapa  : $total',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                ...dataList,
              ],
            ),
          );

          tapasColumns.add(tapaColumn);
        });

        final int totalSum = getSumByPlaca(placa);

        final Widget expansionTile = ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$placa  :  $totalSum',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
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

      // Agregar desplegable adicional al final
      final List<String> tapasSet = _summaryList
          .where((summary) {
            final parts = summary.split(' : ');
            return parts[3] == 'mocho';
          })
          .map((summary) {
            final parts = summary.split(' : ');
            return parts[4];
          })
          .toSet()
          .toList();

      final List<Widget> additionalDataList = tapasSet.map((tapa) {
        final List<Widget> dataList = [];
        final Map<String, int> secondDataMap = {};

        for (final summary in _summaryList) {
          final parts = summary.split(' : ');
          if (parts[3] == 'mocho') {
            final posicionTapa = parts[4];
            if (posicionTapa == tapa) {
              final association = '${parts[0]}:$tapa';
              final secondData = int.tryParse(parts[1]) ?? 0;

              if (secondDataMap.containsKey(association)) {
                secondDataMap[association] = secondDataMap[association]! + secondData;
              } else {
                secondDataMap[association] = secondData;
                dataList.add(Text('${parts[0]} : $secondData'));
              }
            }
          }
        }

        final int total = secondDataMap.values.fold(0, (sum, repetidos) => sum + repetidos);

        final List<Widget> sumSecondDataList = secondDataMap.entries.map((entry) {
          final parts = entry.key.split(':');
          final firstData = parts[0];
          final sumSecondData = entry.value;
          return Text('$firstData : $sumSecondData');
        }).toList(); // Asociado a la tapa en general

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$tapa : $total',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            ...sumSecondDataList,
          ],
        );
      }).toList();

      //   
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Informe de Operación',
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
              if (_summaryList.isNotEmpty)
                Column(
                  children: expansionTiles,
                )
              else
                Container(
                  height: 200, // Ajusta la altura según tus necesidades
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
