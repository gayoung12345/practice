import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart'; // 다중 날짜 선택 라이브러리

// 카메라에 오류가 나타난 횟수를 보여주는 그래프
class CameraErrorChart3 extends StatefulWidget {
  @override
  _CameraErrorChartState createState() => _CameraErrorChartState();
}

class _CameraErrorChartState extends State<CameraErrorChart3> {
  Map<int, Map<String, int>> groupedData = {};  // 데이터 저장을 위한 변수: 카메라별 날짜별 에러 발생 횟수를 저장(mapping)
  bool isLoading = true;// 로딩인지 아닌지 상태를 나타냄

  DateTime? startDate; // 시작 날짜
  DateTime? endDate;   // 종료 날짜
  DateTime currentReferenceDate = DateTime.now(); // 현재 기준 날짜

  @override
  void initState() {  // 생성자
    super.initState();
    fetchMonthlyData(DateTime.now(), DateTime.now()); // 초기 기준 날짜 데이터 로드
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

  // 날짜 선택기(Dialog)를 출력
  void showDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: (args) {
                  if (args.value is PickerDateRange) {
                    PickerDateRange range = args.value;
                    setState(() {
                      startDate = range.startDate;
                      endDate = range.endDate;
                    });
                  }
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (startDate != null && endDate != null) {
                  setState(() {
                    isLoading = true;
                  });
                  fetchMonthlyData(startDate!, endDate!);
                }
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text("Apply"),
            ),
          ],
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: showDatePicker,
            child: Text("Select Date Range"),
          ),
          if (startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${DateFormat('yyyy-MM-dd').format(startDate!)} ~ ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                style: TextStyle(fontSize: 16),
              ),
            ),
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
              child: CameraErrorLineChart(data: groupedData),
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

  CameraErrorLineChart({required this.data});

  @override
  _CameraErrorLineChartState createState() => _CameraErrorLineChartState();
}

class _CameraErrorLineChartState extends State<CameraErrorLineChart> {
  Set<int> selectedCameras = {};  // 선택된 카메라를 저장하는 Set(리스트)

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
        Wrap(
          spacing: 10,
          children: [
            for (int cameraNum in widget.data.keys)
              FilterChip(
                label: Text(
                  'Camera $cameraNum',
                  style: TextStyle(
                    color: selectedCameras.contains(cameraNum) ? Colors.white : Colors.black,
                  ),
                ),
                selected: selectedCameras.contains(cameraNum),
                backgroundColor: cameraColor(cameraNum).withOpacity(0.3),
                selectedColor: cameraColor(cameraNum).withOpacity(0.7),
                onSelected: (isSelected) {
                  setState(() {
                    if (isSelected) {
                      selectedCameras.add(cameraNum);
                    } else {
                      selectedCameras.remove(cameraNum);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  List<LineChartBarData> generateLineBars() {
    List<LineChartBarData> bars = [];

    for (int cameraNum in widget.data.keys) {
      if (selectedCameras.isEmpty || selectedCameras.contains(cameraNum)) {
        final cameraData = widget.data[cameraNum]!;
        final List<FlSpot> spots = [];

        int index = 0;
        for (String date in cameraData.keys) {
          spots.add(FlSpot(index.toDouble(), cameraData[date]?.toDouble() ?? 0));
          index++;
        }

        bars.add(LineChartBarData(
          color: cameraColor(cameraNum),
          barWidth: 3,
          dotData: FlDotData(show: true), // 자동으로 y축 값 표시
          spots: spots,
        ));
      }
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
