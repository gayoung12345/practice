import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // 형식 변환 라이브러리

// 카메라에 오류가 나타난 횟수를 보여주는 그래프
class CameraErrorChart extends StatefulWidget {
  final int selectedCamera; // 선택한 카메라 번호 (-1은 모든 카메라)

  CameraErrorChart({required this.selectedCamera});

  @override
  _CameraErrorChartState createState() => _CameraErrorChartState();
}

// 상태 클래스
class _CameraErrorChartState extends State<CameraErrorChart> {
  Map<int, Map<String, int>> groupedData = {};  // 데이터 저장을 위한 변수: 카메라별 날짜별 에러 발생 횟수를 저장(mapping)
  bool isLoading = true; // 로딩인지 아닌지 상태를 나타냄
  DateTime currentReferenceDate = DateTime.now(); // 현재 기준 날짜

  @override
  void didUpdateWidget(CameraErrorChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCamera != widget.selectedCamera) {
      // 새로운 카메라 값이 전달되었을 때 처리
      setState(() {
        isLoading = true;
      });
      fetchWeeklyData(currentReferenceDate);
    }
  }

  @override
  void initState() {
    super.initState();  // 생성자
    fetchWeeklyData(currentReferenceDate);  // 초기 기준 날짜 데이터 로드
  }

  List<DateTime> getWeekRange(DateTime referenceDate) {
    // 기준 날짜의 시간을 제거하고, 주의 월요일 계산
    DateTime monday = DateTime(referenceDate.year, referenceDate.month, referenceDate.day)
        .subtract(Duration(days: referenceDate.weekday - 1));

    // 월요일부터 일요일까지의 날짜 리스트 생성
    return List.generate(7, (index) =>
        DateTime(monday.year, monday.month, monday.day).add(Duration(days: index)));
  }

  Future<void> fetchWeeklyData(DateTime referenceDate) async {
    try {
      List<DateTime> weekRange = getWeekRange(referenceDate);
      List<String> weekStrings = weekRange.map((date) => DateFormat('yyyy-MM-dd').format(date)).toList();


      final snapshot = await FirebaseFirestore.instance
          .collection('errors2')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(weekRange.first.year, weekRange.first.month, weekRange.first.day)))
          .where('date', isLessThan: Timestamp.fromDate(DateTime(weekRange.last.year, weekRange.last.month, weekRange.last.day).add(Duration(days: 1))))
          .get();

      Map<int, Map<String, int>> tempData = {};
      for (int cameraNum in [1, 2, 3]) {
        tempData[cameraNum] = {for (String date in weekStrings) date: 0};
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        int? cameraNum = data['cameraNum'];
        Timestamp? timestamp = data['date'];

        if (cameraNum != null && timestamp != null) {
          String date = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
          if (tempData[cameraNum] != null && tempData[cameraNum]!.containsKey(date)) {
            tempData[cameraNum]![date] = (tempData[cameraNum]![date] ?? 0) + 1;
          }
        }
      }

      if (mounted) {
        setState(() {
          groupedData = tempData;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching weekly data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
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
      body: isLoading // 로딩 중이면 로딩 인디케이터 표시
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이동 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentReferenceDate = currentReferenceDate.subtract(Duration(days: 7));  // 날짜 감소
                    isLoading = true; // 로딩 상태 활성화
                  });
                  fetchWeeklyData(currentReferenceDate);  // 데이터 가져오기
                },
                child: Text('◀'),
              ),
              SizedBox(width: 10),  // 버튼 사이 간격
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentReferenceDate = DateTime.now();  // 현재 날짜 설정
                    isLoading = true; // 로딩 상태 활성화
                  });
                  fetchWeeklyData(currentReferenceDate);  // 데이터 가져오기
                },
                child: Text('Reset'),
              ),
              SizedBox(width: 10),  // 버튼 사이 간격
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentReferenceDate = currentReferenceDate.add(Duration(days: 7)); // 날짜 증가
                    isLoading = true; // 로딩 상태 활성화
                  });
                  fetchWeeklyData(currentReferenceDate);  // 데이터 가져오기
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

class CameraErrorLineChart extends StatefulWidget {
  final Map<int, Map<String, int>> data;  // 카메라 번호별 데이터
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
        // 그래프 컨테이너
        Container(
          width: MediaQuery.of(context).size.width * 0.8, // 화면 너비의 80%
          height: MediaQuery.of(context).size.width * 0.8,
          child: LineChart(
            LineChartData(
              minY: 0, // Y축 최소값 설정
              maxY: 6, // Y축 최대값 설정
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, // 왼쪽 축 값 표시
                    getTitlesWidget: (value, meta) {
                      // 세로 축 값이 0부터 6까지로 고정되도록 설정
                      if (value >= 0 && value <= 6) {
                        return Text(value.toInt().toString()); // 0~6까지 정수 값 출력
                      }
                      return Text('');
                    },
                    interval: 1, // Y축 간격을 1로 설정
                    reservedSize: 28, // 공간 확보
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, // 아래 축 값 표시
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      final dateList = widget.selectedCamera == -1
                          ? widget.data.values.expand((cameraData) => cameraData.keys).toSet().toList() // 중복 제거 및 병합
                          : widget.data[widget.selectedCamera]?.keys.toList() ?? [];
                      if (index < dateList.length) {
                        final date = dateList[index];
                        return Text(
                          DateFormat('MM-dd').format(DateTime.parse(date)), // MM-dd 형식의 날짜 출력
                          style: TextStyle(fontSize: 10), // 작은 폰트
                        );
                      }
                      return Text('');
                    },
                    reservedSize: 22, // 제목 영역 크기
                  ),
                ),
                rightTitles: AxisTitles( // 오른쪽 축 텍스트 제거
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              borderData: FlBorderData(show: true), // 테두리 표시
              gridData: FlGridData(
                show: false,
              ),
              lineBarsData: generateLineBars(), // 그래프 데이터 생성
            ),
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> generateLineBars() {
    List<LineChartBarData> bars = [];

    final selectedCamera = widget.selectedCamera;

    if (selectedCamera == -1) {  // "모든 카메라" 선택 시 모든 카메라 데이터 표시
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
    } else {  // 선택된 카메라에 대해서만 그래프를 표시
      final cameraNum = selectedCamera;  // 선택된 카메라 번호
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

    return bars; // 반환
  }


  Color cameraColor(int cameraNum) {
    switch (cameraNum) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}