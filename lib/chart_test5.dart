import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 카메라에 오류가 나타난 횟수를 보여주는 그래프
class CameraErrorChart4 extends StatefulWidget {
  final int selectedCamera; // 선택한 카메라 번호 (-1은 모든 카메라)
  final DateTime startDate;
  final DateTime endDate;

  CameraErrorChart4({required this.selectedCamera, required this.startDate, required this.endDate, Key? key});

  @override
  _CameraErrorChartState createState() => _CameraErrorChartState();
}

class _CameraErrorChartState extends State<CameraErrorChart4> {
  Map<int, Map<String, int>> groupedData = {};  // 데이터 저장을 위한 변수: 카메라별 날짜별 에러 발생 횟수를 저장(mapping)
  bool isLoading = true;// 로딩인지 아닌지 상태를 나타냄

  DateTime currentReferenceDate = DateTime.now(); // 기준 날짜

  @override
  void initState() {
    super.initState();
    // 초기에는 기본 값으로 이번 달 데이터를 가져옴
    final now = DateTime.now();
    fetchMonthlyData(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    );
  }

  // Firestore에서 선택한 기간의 데이터를 가져옴
  Future<void> fetchMonthlyData(DateTime startDate, DateTime endDate) async {
    try {
      List<String> dateStrings = List.generate(
        endDate.difference(startDate).inDays + 1,
            (index) => DateFormat('yyyy-MM-dd').format(startDate.add(Duration(days: index))),
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('errors2')  // 가지고 올 컬렉션 이름
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate.add(Duration(days: 1))))
          .get();

      Map<int, Map<String, int>> tempData = {}; // 카메라별 날짜 데이터 초기화
      for (int cameraNum in [1, 2, 3]) {
        tempData[cameraNum] = {
          for (String date in dateStrings) date: 0, // 날짜 별 초기값 0
        };
      }

      for (var doc in snapshot.docs) {  // Firestore에서 가져온 데이터를 카메라별로 정리
        final data = doc.data();  // 문서 데이터를 가져옴
        int? cameraNum = data['cameraNum']; // 카메라 번호
        Timestamp? timestamp = data['date']; // 에러 발생 일 (시간X)

        if (cameraNum != null && timestamp != null) {
          String date = DateFormat('yyyy-MM-dd').format(timestamp.toDate());  // 날짜를 문자열로 변환
          if (tempData[cameraNum] != null && tempData[cameraNum]!.containsKey(date)) { // 해당 날짜에 에러 횟수를 누적
            tempData[cameraNum]![date] = (tempData[cameraNum]![date] ?? 0) + 1;
          }
        }
      }

      if (mounted) {  // 데이터 상태 업데이트
        setState(() {
          groupedData = tempData; // 가져온 데이터 설정
          isLoading = false;  // 로딩 상태 해제
        });
      }
    } catch (e) { // 오류 발생 시
      print('Error fetching data: $e'); // 오류 메세지 출력
      if (mounted) {
        setState(() {
          isLoading = false;  // 로딩 상태 해제
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    final filteredData = widget.selectedCamera == -1
        ? groupedData // 모든 카메라의 데이터를 보여줌
        : {widget.selectedCamera: groupedData[widget.selectedCamera]!}; // 선택된 카메라만 표시


    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [  // 버튼 사이 간격
              ElevatedButton(
                onPressed: () {
                  setState(() { // 버튼을 누르면 해당 상태 전달
                    currentReferenceDate = DateTime(
                        currentReferenceDate.year, currentReferenceDate.month - 1);
                    isLoading = true;
                  });
                  fetchMonthlyData(
                    DateTime(currentReferenceDate.year, currentReferenceDate.month, 1),
                    DateTime(currentReferenceDate.year, currentReferenceDate.month + 1, 0),
                  );
                },
                child: Text('◀'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentReferenceDate = DateTime.now();
                    isLoading = true;
                  });
                  fetchMonthlyData(
                    DateTime(currentReferenceDate.year, currentReferenceDate.month, 1),
                    DateTime(currentReferenceDate.year, currentReferenceDate.month + 1, 0),
                  );
                },
                child: Text('Reset'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentReferenceDate = DateTime(
                        currentReferenceDate.year, currentReferenceDate.month + 1);
                    isLoading = true;
                  });
                  fetchMonthlyData(
                    DateTime(currentReferenceDate.year, currentReferenceDate.month, 1),
                    DateTime(currentReferenceDate.year, currentReferenceDate.month + 1, 0),
                  );
                },
                child: Text('▶'),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: CameraErrorLineChart(data: filteredData, selectedCamera: widget.selectedCamera), // 필터링된 데이터와 선택된 카메라 번호 전달
            ),
          ),
        ],
      ),
    );
  }
}

// 그래프를 그리는 위젯
class CameraErrorLineChart extends StatefulWidget {
  final Map<int, Map<String, int>> data;  // 카메라별 에러 데이터
  final int selectedCamera;  // 선택된 카메라 번호

  CameraErrorLineChart({required this.data, required this.selectedCamera});

  @override
  _CameraErrorLineChartState createState() => _CameraErrorLineChartState();
}

class _CameraErrorLineChartState extends State<CameraErrorLineChart> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(  // 그래프 컨테이너
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.width * 0.8,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 6,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value <= 6) {
                        return Text(value.toInt().toString());
                      }
                      return Text('');
                    },
                    interval: 1,
                    reservedSize: 28,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      final dateList = widget.data[1]?.keys.toList() ?? [];
                      if (index < dateList.length) {
                        final date = dateList[index];
                        return Text(
                          DateFormat('MM-dd').format(DateTime.parse(date)),
                          style: TextStyle(fontSize: 10),
                        );
                      }
                      return Text('');
                    },
                    reservedSize: 22,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      final dateList = widget.data[1]?.keys.toList() ?? [];
                      if (index == (dateList.length ~/ 2)) {
                        return Text(
                          DateFormat('yyyy-MM').format(DateTime.parse(dateList[index])),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(
                show: false,
              ),
              lineBarsData: generateLineBars(),
            ),
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> generateLineBars() { // 카메라별 그래프 데이터 생성
    List<LineChartBarData> bars = [];

    final selectedCamera = widget.selectedCamera;

    if (selectedCamera == -1) {  // "All" 선택 시 모든 카메라 데이터 표시
      widget.data.forEach((cameraNum, dateCounts) {
        final spots = <FlSpot>[]; // 플롯 데이터
        List<String> sortedDates = dateCounts.keys.toList()..sort();  // 날짜 정렬

        int index = 0;
        for (String date in sortedDates) {
          spots.add(FlSpot(index.toDouble(), dateCounts[date]?.toDouble() ?? 0)); // 각 날짜에 대해 데이터 추가
          index++;
        }

        bars.add( // 그래프 데이터 추가
          LineChartBarData(
            spots: spots, // 플롯 데이터 설정
            color: cameraColor(cameraNum),  // 카메라별 색상
            barWidth: 4,  // 선 굵기
          ),
        );
      });
    } else if (selectedCamera != null) {  // 선택된 카메라에 대해서만 그래프를 표시
      final cameraNum = selectedCamera!;
      final dateCounts = widget.data[cameraNum]!;

      final spots = <FlSpot>[]; // 플롯 데이터
      List<String> sortedDates = dateCounts.keys.toList()..sort();  // 날짜 정렬

      int index = 0;
      for (String date in sortedDates) {
        spots.add(FlSpot(index.toDouble(), dateCounts[date]?.toDouble() ?? 0)); // 각 날짜에 대해 데이터 추가
        index++;
      }

      bars.add( // 그래프 데이터 추가
        LineChartBarData(
          spots: spots, // 플롯 데이터 설정
          color: cameraColor(cameraNum),  // 카메라별 색상
          barWidth: 4,  // 선 굵기
        ),
      );
    }
    return bars;
  }

  Color cameraColor(int cameraNum) {
    switch (cameraNum) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
