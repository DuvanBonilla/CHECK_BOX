import 'package:flutter/material.dart';
import 'package:check_box/screen/formulario_page.dart';

class ResumenTrz extends StatefulWidget {
  const ResumenTrz({Key? key}) : super(key: key);

  @override
  State<ResumenTrz> createState() => _ResumenTrzState();
}

class _ResumenTrzState extends State<ResumenTrz> {
  List<String> _summaryList = [];
  Map<String, int> _sumMap = {};
  List<String> _filteredSummaryList = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSummaryList();
  }

  void _loadSummaryList() async {
    final summaryList = await SharedPreferenceHelper.getSummaryList();
    setState(() {
      _summaryList = summaryList;
      _filteredSummaryList = summaryList;
      _sumMap = _getSumMap(summaryList);
    });
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
        final summaryTraza = parts[3];
        final summaryTapa = parts[4];
        final firstData = parts[0];

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
                Text(
                  '$traza  :  $totalSum',
                  style: const TextStyle(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSummaryList,
                  decoration: InputDecoration(
                    labelText: 'Buscar traza',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterSummaryList('');
                      },
                      icon: Icon(Icons.clear),
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