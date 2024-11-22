import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ErrorChartScreen extends StatefulWidget {
  @override
  _ErrorChartScreenState createState() => _ErrorChartScreenState();
}

class _ErrorChartScreenState extends State<ErrorChartScreen> {
  // 상태 관리
  DateTime startDate = DateTime.now().subtract(Duration(days: 7)); // 기본: 지난 7일
  DateTime endDate = DateTime.now();
  String selectedPeriod = "Weekly"; // "Weekly", "Monthly", "Custom"
  int selectedGraph = -1; // -1: 전체 보기, 1: 1번 그래프, 2: 2번 그래프, 3: 3번 그래프

  Map<int, List<FlSpot>> graphData = {}; // 그래프 데이터 저장
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    fetchData(); // 초기 데이터 로드
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      // Firestore 데이터 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('errors2')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate.add(Duration(days: 1))))
          .get();

      Map<int, List<FlSpot>> tempData = {1: [], 2: [], 3: []};
      Map<int, Map<String, int>> groupedData = {1: {}, 2: {}, 3: {}}; // 카메라별 데이터

      for (var doc in snapshot.docs) {
        final data = doc.data();
        int? cameraNum = data['cameraNum'];
        Timestamp? timestamp = data['date'];

        if (cameraNum != null && timestamp != null && tempData.containsKey(cameraNum)) {
          String date = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
          groupedData[cameraNum] ??= {}; // null이면 빈 맵으로 초기화
          groupedData[cameraNum]![date] = (groupedData[cameraNum]![date] ?? 0) + 1;
        }
      }

      // FlSpot 데이터로 변환
      groupedData.forEach((cameraNum, dateCounts) {
        List<String> sortedDates = dateCounts.keys.toList()..sort();
        for (int i = 0; i < sortedDates.length; i++) {
          tempData[cameraNum]?.add(FlSpot(
            i.toDouble(),
            dateCounts[sortedDates[i]]?.toDouble() ?? 0,
          ));
        }
      });

      setState(() {
        graphData = tempData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  void updatePeriod(String period) {
    setState(() {
      selectedPeriod = period;
      if (period == "Weekly") {
        startDate = DateTime.now().subtract(Duration(days: 7));
        endDate = DateTime.now();
      } else if (period == "Monthly") {
        startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
        endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
      }
    });
    fetchData();
  }

  void selectCustomPeriod(DateTime start, DateTime end) {
    setState(() {
      startDate = start;
      endDate = end;
      selectedPeriod = "Custom";
    });
    fetchData();
  }

  Widget buildGraph(int graphNumber) {
    if (graphData[graphNumber] == null || graphData[graphNumber]!.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: graphData[graphNumber]??[],
            isCurved: true,
            color: [Colors.blue, Colors.green, Colors.red][graphNumber - 1],
            barWidth: 4,
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < graphData[graphNumber]!.length) {
                  return Text(
                    DateFormat('MM-dd').format(startDate.add(Duration(days: value.toInt()))),
                    style: TextStyle(fontSize: 10),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error Chart Screen"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => updatePeriod("Weekly"),
                child: Text("Weekly"),
              ),
              ElevatedButton(
                onPressed: () => updatePeriod("Monthly"),
                child: Text("Monthly"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // 사용자 정의 기간 설정
                  final start = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (start != null) {
                    final end = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: start,
                      lastDate: DateTime.now(),
                    );
                    if (end != null) selectCustomPeriod(start, end);
                  }
                },
                child: Text("Custom"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => selectedGraph = 1),
                child: Text("Graph 1"),
              ),
              ElevatedButton(
                onPressed: () => setState(() => selectedGraph = 2),
                child: Text("Graph 2"),
              ),
              ElevatedButton(
                onPressed: () => setState(() => selectedGraph = 3),
                child: Text("Graph 3"),
              ),
              ElevatedButton(
                onPressed: () => setState(() => selectedGraph = -1),
                child: Text("All Graphs"),
              ),
            ],
          ),
          Expanded(
            child: selectedGraph == -1
                ? Column(
              children: [
                Expanded(child: buildGraph(1)),
                Expanded(child: buildGraph(2)),
                Expanded(child: buildGraph(3)),
              ],
            )
                : buildGraph(selectedGraph),
          ),
        ],
      ),
    );
  }
}
