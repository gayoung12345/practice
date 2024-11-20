import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // 형식 변환 라이브러리

// 카메라에 오류가 나타난 횟수를 보여주는 그래프
class CameraErrorChart2 extends StatefulWidget {
  @override
  _CameraErrorChartState createState() => _CameraErrorChartState();
}

// 상태 클래스
class _CameraErrorChartState extends State<CameraErrorChart2> {
  Map<int, Map<String, int>> groupedData = {};  // 데이터 저장을 위한 변수: 카메라별 날짜별 에러 발생 횟수를 저장(mapping)
  bool isLoading = true; // 로딩인지 아닌지 상태를 나타냄
  DateTime currentReferenceDate = DateTime.now(); // 현재 기준 날짜

  @override
  void initState() {
    super.initState();  // 생성자
    fetchMonthlyData(currentReferenceDate);  // 초기 기준 날짜 데이터 로드
  }

  List<DateTime> getMonthRange(DateTime referenceDate) {
    // 기준 날짜의 연도, 월을 이용해 시작일(1일)을 계산
    DateTime startOfMonth = DateTime(referenceDate.year, referenceDate.month, 1);
    // 해당 월의 마지막 날 계산
    DateTime endOfMonth = DateTime(referenceDate.year, referenceDate.month + 1, 0);

    // 시작일부터 마지막 날까지의 날짜 리스트 생성
    return List.generate(
      endOfMonth.day,
          (index) => DateTime(startOfMonth.year, startOfMonth.month, index + 1),
    );
  }

  Future<void> fetchMonthlyData(DateTime referenceDate) async {
    try {
      List<DateTime> monthRange = getMonthRange(referenceDate); // 월의 날짜 목록
      List<String> monthStrings = monthRange.map((date) => DateFormat('yyyy-MM-dd').format(date)).toList();

      final snapshot = await FirebaseFirestore.instance
          .collection('errors2')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(
          DateTime(monthRange.first.year, monthRange.first.month, monthRange.first.day))) // 월 첫날
          .where('date', isLessThan: Timestamp.fromDate(
          DateTime(monthRange.last.year, monthRange.last.month, monthRange.last.day).add(Duration(days: 1)))) // 월 마지막 날 + 1
          .get();

      Map<int, Map<String, int>> tempData = {}; // 카메라별로 날짜 데이터를 초기화
      for (int cameraNum in [1, 2, 3]) {
        tempData[cameraNum] = {
          for (String date in monthStrings) date: 0, // 날짜별 초기값 0
        };
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
          groupedData = tempData; // 가져온 데이터 설정
          isLoading = false;  // 로딩 상태 해제
        });
      }
    } catch (e) {
      print('Error fetching monthly data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {  // UI 빌드 메서드
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
                    currentReferenceDate = DateTime(currentReferenceDate.year, currentReferenceDate.month - 1);  // 한 달 감소
                    isLoading = true;
                  });
                  fetchMonthlyData(currentReferenceDate);  // 데이터 가져오기
                },
                child: Text('◀'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentReferenceDate = DateTime.now();  // 현재 날짜로 리셋
                    isLoading = true;
                  });
                  fetchMonthlyData(currentReferenceDate);  // 데이터 가져오기
                },
                child: Text('Reset'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentReferenceDate = DateTime(currentReferenceDate.year, currentReferenceDate.month + 1); // 한 달 증가
                    isLoading = true;
                  });
                  fetchMonthlyData(currentReferenceDate);  // 데이터 가져오기
                },
                child: Text('▶'),
              ),
            ],
          ),
          Expanded( // 그래프 표시
            child: Center(
              child: CameraErrorLineChart(data: groupedData), // 하단의 CameraErrorLineChart 위젯 호출
            ),
          ),
        ],
      ),
    );
  }
}

// 그래프를 그리는 위젯 클래스
class CameraErrorLineChart extends StatefulWidget {
  final Map<int, Map<String, int>> data;  // 카메라별 에러 데이터

  CameraErrorLineChart({required this.data});

  @override
  _CameraErrorLineChartState createState() => _CameraErrorLineChartState();
}

// 상태 클래스
class _CameraErrorLineChartState extends State<CameraErrorLineChart> {
  Set<int> selectedCameras = {}; // 선택된 카메라를 저장하는 Set(리스트)

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(  // 그래프 컨테이너
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
                        return Text(value.toInt().toString());  // 0~6까지 정수 값 출력
                      }
                      return Text(''); // 나머지 값은 빈 문자열 반환
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
                      final dateList = widget.data[1]?.keys.toList() ?? [];
                      if (index < dateList.length) {
                        final date = dateList[index];
                        return Text(
                          DateFormat('dd').format(DateTime.parse(date)), // 날짜를 'dd' 형식으로 출력
                          style: TextStyle(fontSize: 10), // 작은 폰트로 날짜 표시
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
                    showTitles: true, // 상단에 연도 표시
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      final dateList = widget.data[1]?.keys.toList() ?? [];
                      // 그래프의 중간 인덱스에만 '2024-11' 표시
                      if (index == (dateList.length ~/ 2)) {
                        return Text(
                          DateFormat('yyyy-MM').format(DateTime.parse(dateList[index])),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),  // 폰트 크기 조절
                        );
                      }
                      return Text('');
                    }

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
        // 카메라 선택 버튼들(다중선택 가능 )
        // 다중 선택 가능한 카메라 선택 FilterChip
        Wrap(
          spacing: 10, // 칩 간격
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
                      selectedCameras.add(cameraNum); // 선택 추가
                    } else {
                      selectedCameras.remove(cameraNum); // 선택 해제
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  List<LineChartBarData> generateLineBars() { // 카메라별 그래프 데이터 생성
    List<LineChartBarData> bars = [];
    widget.data.forEach((cameraNum, dateCounts) {
      if (selectedCameras.isNotEmpty && !selectedCameras.contains(cameraNum)) return;  // 선택된 카메라만 표시

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
    return bars;
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