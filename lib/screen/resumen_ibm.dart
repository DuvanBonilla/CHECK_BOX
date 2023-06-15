import 'package:flutter/material.dart';
import 'package:check_box/screen/formulario_page.dart';

class ResumenIbm extends StatefulWidget {
  const ResumenIbm({Key? key}) : super(key: key);

  @override
  State<ResumenIbm> createState() => _ResumenIbmState();
}

class _ResumenIbmState extends State<ResumenIbm> {
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

  Map<String, int> _getSumMap(List<String> summaryList) {
    final sumMap = <String, int>{};

    for (final summary in summaryList) {
      final parts = summary.split(' : ');
      final ibm = parts[0];
      final tapa = parts[4];
      final key = '$ibm:$tapa';

      final value = int.tryParse(parts[1]) ?? 0;
      sumMap[key] = (sumMap[key] ?? 0) + value;
    }

    return sumMap;
  }

  int getSumByIbm(String ibm) {
    int sum = 0;

    for (final summary in _summaryList) {
      final parts = summary.split(' : ');
      if (parts[0] == ibm) {
        final value = int.tryParse(parts[1]) ?? 0;
        sum += value;
      }
    }

    return sum;
  }

  List<String> getDataByIbmAndTapa(String ibm, String tapa) {
    final data = _summaryList
        .where((summary) =>
            summary.contains(' : $ibm : ') && summary.contains(' : $tapa : '))
        .toList();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> expansionTiles = [];
    if (_summaryList.isNotEmpty) {
      final ibmsSet = _summaryList.map((summary) {
        final parts = summary.split(' : ');
        return parts[0];
      }).toSet();

      final List<String> ibmList = ibmsSet.toList();

      ibmList.forEach((ibm) {
        final List<Widget> tapasColumns = [];

        final tapasSet = _summaryList.map((summary) {
          final parts = summary.split(' : ');
          return parts[4];
        }).toSet();

        final List<String> tapasList = tapasSet.toList();

        tapasList.forEach((tapa) {
          final List<String> data = getDataByIbmAndTapa(ibm, tapa);
          final List<Widget> dataList = data.map((entry) {
            final parts = entry.split(' : ');
            final firstData = parts[0];
            final secondData = parts[1];

            return Text('$firstData : $secondData');
          }).toList();

          final int total = _sumMap['$ibm:$tapa'] ?? 0;

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

        final int totalSum = getSumByIbm(ibm);

        final Widget expansionTile = ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$ibm  :  $totalSum',
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
    }

    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.grey.shade200,
            appBar: AppBar(
              title: const Text(
                'Resumen IBM',
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
            )));
  }
}
