import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 카메라에 오류가 나타난 횟수를 보여주는 그래프
class CameraErrorChart4 extends StatefulWidget {
  final int selectedCamera; // 선택한 카메라 번호 (-1은 모든 카메라)
  final DateTime startDate;
  final DateTime endDate;

  CameraErrorChart4({required this.selectedCamera, required this.startDate, required this.endDate });

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
    fetchUserData(widget.startDate, widget.endDate); // 사용자 기간 데이터 로드
  }
  @override
  void didUpdateWidget(CameraErrorChart4 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.startDate != oldWidget.startDate || widget.endDate != oldWidget.endDate) {
      // 날짜 범위가 변경되었으면 데이터 다시 로드
      fetchUserData(widget.startDate, widget.endDate);
    }
  }

  // Firestore에서 사용자가 선택한기간의 데이터를 가져옴
  Future<void> fetchUserData(DateTime startDate, DateTime endDate) async {
    try {
      // 사용자가 선택한 날짜 범위의 모든 날짜를 생성
      List<String> dateStrings = List.generate(
        endDate.difference(startDate).inDays + 1,
            (index) => DateFormat('yyyy-MM-dd').format(startDate.add(Duration(days: index))),
      );

      // Firestore에서 데이터 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('errors2')  // Firestore 컬렉션 이름
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate.add(Duration(days: 1))))
          .get();

      // 초기화된 데이터 구조
      Map<int, Map<String, int>> tempData = {};
      for (int cameraNum in [1, 2, 3]) {
        tempData[cameraNum] = {
          for (String date in dateStrings) date: 0, // 모든 날짜에 대해 초기값 0 설정
        };
      }

      // Firestore에서 가져온 데이터를 처리하여 tempData에 저장
      for (var doc in snapshot.docs) {
        final data = doc.data();
        int? cameraNum = data['cameraNum']; // 카메라 번호
        Timestamp? timestamp = data['date']; // Firestore의 날짜 필드

        if (cameraNum != null && timestamp != null) {
          String date = DateFormat('yyyy-MM-dd').format(timestamp.toDate()); // 날짜를 문자열로 변환
          if (tempData[cameraNum]?.containsKey(date) == true) {
            tempData[cameraNum]![date] = (tempData[cameraNum]![date] ?? 0) + 1; // 해당 날짜에 에러 횟수 누적
          }
        }
      }

      // 상태 업데이트
      if (mounted) {
        setState(() {
          groupedData = tempData; // 정리된 데이터를 상태에 저장
          isLoading = false; // 로딩 상태 해제
        });
      }
    } catch (e) {
      // 오류 발생 시 처리
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          isLoading = false; // 로딩 상태 해제
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    // groupedData가 null이거나 비어 있을 때 로딩 인디케이터 표시
    if (isLoading || groupedData.isEmpty) {
      return Center(child: CircularProgressIndicator()); // 데이터가 없을 때 로딩 표시
    }

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
                  fetchUserData(
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
                  fetchUserData(
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
                  fetchUserData(
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
                      final dateList = widget.selectedCamera == -1
                          ? widget.data.values.expand((cameraData) => cameraData.keys).toSet().toList() // 중복 제거 및 병합
                          : widget.data[widget.selectedCamera]?.keys.toList() ?? [];

                      // index가 dateList 길이를 초과하지 않도록 확인
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
                    showTitles: false,
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
