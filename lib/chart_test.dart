import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartPage extends StatefulWidget {
  @override
  _LineChartPageState createState() => _LineChartPageState(); // 상태를 관리하는 _LineChartPageState를 반환
}

// LineChart 상태를 관리하는 클래스
class _LineChartPageState extends State<LineChartPage> {
  List<FlSpot> spots = [];  // 차트에서 점을 찍을 데이터를 저장할 리스트 (x, y 값)
  List<String> dates = [];  // X축에 표시할 날짜들을 저장할 리스트

  @override
  void initState() {
    super.initState();  // 부모 클래스의 initState 호출
    fetchData(); // Firestore에서 데이터를 가져오는 함수 호출
  }

  // Firestore에서 데이터를 가져오는 비동기 함수
  Future<void> fetchData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('errors') // 'errors' 컬렉션에서 데이터 가져오기
        .orderBy('date', descending: true) // 'date' 필드를 기준으로 내림차순 정렬 (최신 데이터 우선)
        .limit(7) // 최신 7개의 데이터만 가져오기
        .get(); // 데이터 읽기

    setState(() {  // 데이터 변경 후 화면을 새로고침
      spots = snapshot.docs.asMap().entries.map((entry) {  // Firestore에서 가져온 데이터로 차트 점 생성
        int index = entry.key;  // Firestore 데이터의 인덱스
        var doc = entry.value;  // Firestore 문서

        // 'date' 필드에서 날짜를 가져오고, 없으면 기본값 '0' 사용
        String dateStr = doc['date'] ?? '0';
        // 'errorCount' 필드에서 오류 개수를 가져오고, 없으면 기본값 0 사용
        int errorCount = doc['errorCount'] ?? 0;

        // 날짜를 'YYYY-MM-DD' 형식으로 받아오므로 이를 분리하여 사용
        List<String> dateParts = dateStr.split('-'); // 날짜를 '-'로 구분
        int year = int.tryParse(dateParts[0]) ?? 2000; // 연도 추출 (잘못된 값은 기본값 2024)
        int month = int.tryParse(dateParts[1]) ?? 1;   // 월 추출 (잘못된 값은 기본값 1)
        int day = int.tryParse(dateParts[2]) ?? 1;     // 일 추출 (잘못된 값은 기본값 1)

        // X축 값은 최신 데이터부터 0, 1, 2, ... 로 설정 (최신 데이터가 0, 그 다음이 1...)
        double x = (6 - index).toDouble(); // 최신부터 0까지 순차적으로 설정

        // Y축 값은 오류 개수
        double y = errorCount.toDouble();

        return FlSpot(x, y);  // FlSpot은 차트에서 각 점을 나타냄 (x, y 좌표)
      }).toList();  // 리스트로 변환하여 spots에 저장

      // 날짜 목록 업데이트 (X축에 표시할 날짜들)
      dates = snapshot.docs.map((doc) {
        return doc['date']?.toString() ?? '0';  // 날짜를 String으로 변환, 없으면 기본값 '0'
      }).toList();
    });
  }

  // 날짜를 'MM-dd' 형식으로 변환하는 함수
  String formatDate(int index) {
    // 최신 데이터부터 7개의 날짜를 가져왔으므로, index를 기준으로 날짜 반환
    if (index < dates.length) {
      String dateStr = dates[index];  // 날짜 문자열 가져오기
      List<String> dateParts = dateStr.split('-'); // 날짜를 '-'로 나누기
      int month = int.tryParse(dateParts[1]) ?? 1; // 월 추출 (잘못된 값은 기본값 1)
      int day = int.tryParse(dateParts[2]) ?? 1;   // 일 추출 (잘못된 값은 기본값 1)

      // MM-dd 형식으로 반환 (월, 일 자리를 두 자릿수로 맞추기)
      return '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    }
    return '';  // 날짜가 없으면 빈 문자열 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: spots.isEmpty  // 데이터가 없으면 로딩 표시
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때
          : Padding(  // 차트가 있을 때는 여백을 주기 위해 Padding 사용
        padding: const EdgeInsets.all(16.0), // 16픽셀 여백
        child: Container(
          width: double.infinity, // 화면 가로 길이에 맞추기
          height: MediaQuery.of(context).size.width, // 세로 길이를 화면 가로 길이에 맞추기
          child: LineChart(
            LineChartData(  // 차트의 데이터 설정
              lineBarsData: [
                LineChartBarData(  // 라인 차트 데이터 설정
                  spots: spots,  // 차트에 표시할 점들 (X, Y 값)
                  isCurved: true, // 선을 곡선으로 설정
                  color: Color(0xff23b6e6), // 선 색상
                  barWidth: 4, // 선 두께
                  isStrokeCapRound: true, // 끝점을 둥글게 처리
                ),
              ],
              gridData: FlGridData(
                show: false,  // 그리드 표시 안 함
                drawVerticalLine: false,  // 세로 그리드선 안 보이게
                horizontalInterval: 5,  // Y축 간격 설정
                verticalInterval: 1,  // X축 간격 설정
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Color(0x00000000), strokeWidth: 0); // 투명한 선으로 설정
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(color: Color(0x00000000), strokeWidth: 0); // 투명한 선으로 설정
                },
              ),
              titlesData: FlTitlesData(  // 축 제목 설정
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // 상단 제목은 숨김
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, // X축 제목 표시
                    interval: 1,  // X축 간격 설정 (여기서는 1)
                    reservedSize: 40,  // 제목이 겹치지 않도록 공간 확보
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();  // X축 값에 해당하는 인덱스 찾기
                      if (index >= 0 && index < dates.length) {
                        return Text(formatDate(index), style: TextStyle(fontSize: 10));  // 날짜를 MM-dd 형식으로 표시
                      }
                      return Text('');  // 날짜가 없으면 빈 텍스트 반환
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,  // Y축 제목 표시
                    interval: 5,  // Y축 간격 설정
                    reservedSize: 28,  // Y축 제목 공간 확보
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}');  // Y축 값 표시
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(  // 차트 테두리 설정
                show: true,  // 테두리 보이기
                border: Border.all(
                  color: Color(0xff37434d),  // 테두리 색상
                  width: 1,  // 테두리 두께
                ),
              ),
              minX: 0, // X축 최소값 설정
              maxX: 6, // X축 최대값 설정 (최대 7개의 데이터 표시)
              minY: 0,  // Y축 최소값 설정
              maxY: 20, // Y축 최대값 설정 (오류 개수의 최대값)
            ),
          ),
        ),
      ),
    );
  }
}

