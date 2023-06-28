import 'package:flutter/material.dart';
import 'package:check_box/screen/formulario_page.dart';

class ResumenPage extends StatefulWidget {
  const ResumenPage({Key? key}) : super(key: key);

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  List<String> _summaryList = [];
  Map<String, int> _sumMap = {};
  List<Widget> additionalExpansionTiles = [];

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

  Map<String, int> _getSumMap(List<String> summaryList) {
    final sumMap = <String, int>{};

    for (final summary in summaryList) {
      final placa = summary.split(' : ')[5];
      final tapa = summary.split(' : ')[4];
      final key = '$placa:$tapa';

      final value = int.tryParse(summary.split(' : ')[1]) ?? 0;
      sumMap[key] = (sumMap[key] ?? 0) + value;
    }

    return sumMap;
  }

  int getSumByPlaca(String placa) {
    int sum = 0;

    for (final summary in _summaryList) {
      final parts = summary.split(' : ');
      if (parts[5] == placa) {
        final value = int.tryParse(parts[1]) ?? 0;
        sum += value;
      }
    }

    return sum;
  }

  List<String> getDataByPlacaAndTapa(String placa, String tapa) {
    final data = _summaryList
        .where((summary) =>
            summary.contains(' : $placa : ') && summary.contains(' : $tapa : '))
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

        final tapasSet = _summaryList.map((summary) {
          final parts = summary.split(' : ');
          return parts[4];
        }).toSet();

        final List<String> tapasList = tapasSet.toList();

        tapasList.forEach((tapa) {
          final List<String> data = getDataByPlacaAndTapa(placa, tapa);
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
          final posiciontapa = parts[4];

          if (posiciontapa == tapa) {
            final association = '${parts[0]}:$tapa';
            final secondData = int.tryParse(parts[1]) ?? 0;

            if (secondDataMap.containsKey(association)) {
              secondDataMap[association] =
                  secondDataMap[association]! + secondData;
            } else {
              secondDataMap[association] = secondData;
              dataList.add(Text('${parts[0]} : $secondData'));
            }
          }
        }

        final int total =
            secondDataMap.values.fold(0, (sum, repetidos) => sum + repetidos);

        final List<Widget> sumsegundoDataList =
            secondDataMap.entries.map((entry) {
          final parts = entry.key.split(':');
          final firstData = parts[0];
          final sumasecondData = entry.value;
          return Text('$firstData : $sumasecondData');
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
            ...sumsegundoDataList,
          ],
        );
      }).toList();

      final int totalSum = _summaryList.length > 0
          ? _summaryList
              .map((summary) => int.tryParse(summary.split(' : ')[1]) ?? 0)
              .reduce((value, element) => value + element)
          : 0;
      final Widget additionalExpansionTile = ExpansionTile(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${totalSum.toString()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: additionalDataList.map((widget) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: widget,
                );
              }).toList(),
            ),
          ),
        ],
      );

      expansionTiles.add(additionalExpansionTile);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Informe de Operación',
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