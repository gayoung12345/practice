import 'package:flutter/material.dart';
import 'chart_test2.dart'; // 주간 그래프 코드
import 'chart_test3.dart'; // 월간 그래프 코드
import 'chart_test5.dart'; // 사용자 그래프 코드

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPeriod = 0; // 최종 선택된 기간 (0: 주간, 1: 월간, 2: 사용자 선택)
  int _selectedCamera = -1; // 최종 선택된 카메라 번호 (-1: 모든 카메라, 1, 2, 3)
  DateTime? _startDate; // 최종 선택된 시작 날짜
  DateTime? _endDate; // 최종 선택된 종료 날짜

  // 사용자 기간 선택
  void _showDateRangePicker() async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "시작 날짜 선택",
    );
    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: pickedStartDate.add(Duration(days: 1)),
        firstDate: pickedStartDate,
        lastDate: DateTime(2100),
        helpText: "종료 날짜 선택",
      );
      if (pickedEndDate != null) {
        // 선택한 날짜를 상태 변수에 저장
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
        });
      }
    }
  }
  // 필터 모달
  void _showFilterModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        int tempPeriod = _selectedPeriod;
        int tempCamera = _selectedCamera;

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "필터 설정",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  // 기간 선택
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("기간 선택", style: TextStyle(fontSize: 16)),
                      DropdownButton<int>(
                        value: tempPeriod,
                        items: [
                          DropdownMenuItem(value: 0, child: Text('주간')),
                          DropdownMenuItem(value: 1, child: Text('월간')),
                          DropdownMenuItem(value: 2, child: Text('사용자 선택')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            tempPeriod = value!;
                            if (value == 2) {_showDateRangePicker();}
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // 카메라 선택
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("카메라 선택", style: TextStyle(fontSize: 16)),
                      DropdownButton<int>(
                        value: tempCamera,
                        items: [
                          DropdownMenuItem(value: -1, child: Text('모든 카메라')),
                          DropdownMenuItem(value: 1, child: Text('카메라 1')),
                          DropdownMenuItem(value: 2, child: Text('카메라 2')),
                          DropdownMenuItem(value: 3, child: Text('카메라 3')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            tempCamera = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // 확인 버튼
                  ElevatedButton(
                    onPressed: () {
                      // 변경된 값을 반환하고 모달 닫기
                      Navigator.pop(context, {
                        'selectedPeriod': tempPeriod,
                        'selectedCamera': tempCamera,
                        'startDate': _startDate,
                        'endDate': _endDate,
                      });
                    },
                    child: Text("적용"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      // 상위 상태 업데이트
      setState(() {
        _selectedPeriod = result['selectedPeriod'];
        _selectedCamera = result['selectedCamera'];
        _startDate = result['startDate'];
        _endDate = result['endDate'];
      });
    }
  }


  Widget _buildGraph() {

    print('buildGraph : $_selectedPeriod / $_selectedCamera / $_startDate / $_endDate');

    // 주간, 월간, 사용자 선택 그래프에 대해 동적으로 key 값을 설정하여 리빌드 유도
    if (_selectedPeriod == 0) {  // 주간 그래프
      return CameraErrorChart(selectedCamera: _selectedCamera);
    } else if (_selectedPeriod == 1) {  // 월간 그래프
      return CameraErrorChart2(selectedCamera: _selectedCamera);
    } else {  // 사용자 선택 그래프
      return CameraErrorChart4(selectedCamera: _selectedCamera,startDate:_startDate!, endDate: _endDate!,);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build : $_selectedPeriod / $_selectedCamera / $_startDate / $_endDate');

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt), // 필터 아이콘
            onPressed: _showFilterModal, // 모달창 열기
          ),
        ],
      ),
      body: _buildGraph(),
    );
  }
}
