import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // 모달 내부에서 임시로 사용할 변수들
  int _pendingPeriod = 0; // 임시 기간
  int _pendingCamera = -1; // 임시 카메라
  DateTime? _pendingStartDate; // 임시 시작 날짜
  DateTime? _pendingEndDate; // 임시 종료 날짜

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
        setState(() {
          _pendingStartDate = pickedStartDate; // 임시 시작 날짜 저장
          _pendingEndDate = pickedEndDate; // 임시 종료 날짜 저장
          print("Selected Pending Date Range: $_pendingStartDate ~ $_pendingEndDate");
        });
      }
    }
  }

  // 필터 모달
  void _showFilterModal() {
    // 현재 값을 임시 변수로 복사
    _pendingPeriod = _selectedPeriod;
    _pendingCamera = _selectedCamera;
    _pendingStartDate = _startDate;
    _pendingEndDate = _endDate;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
                        value: _pendingPeriod,
                        items: [
                          DropdownMenuItem(value: 0, child: Text('주간')),
                          DropdownMenuItem(value: 1, child: Text('월간')),
                          DropdownMenuItem(value: 2, child: Text('사용자 선택')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _pendingPeriod = value!;
                            // 사용자 선택일 경우에만 기간 선택
                            if (value != 2) {
                              _pendingStartDate = null;
                              _pendingEndDate = null;
                            } else {
                              _showDateRangePicker(); // 사용자 기간 선택
                            }
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
                        value: _pendingCamera,
                        items: [
                          DropdownMenuItem(value: -1, child: Text('모든 카메라')),
                          DropdownMenuItem(value: 1, child: Text('카메라 1')),
                          DropdownMenuItem(value: 2, child: Text('카메라 2')),
                          DropdownMenuItem(value: 3, child: Text('카메라 3')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _pendingCamera = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // 확인 버튼
                  ElevatedButton(
                    onPressed: () {

                      print("Before setState:");
                      print("Period: $_selectedPeriod, Camera: $_selectedCamera");
                      print("Start Date: $_startDate, End Date: $_endDate");
                      print("~~~~~~~~~~~~~~~~~~~~");

                      // 필터를 적용한 후 Navigator.pop()을 호출하여 모달을 닫고 상태를 갱신합니다.
                      Navigator.pop(context);

                      // 필터 적용 후 상태 갱신
                      setState(() {
                        _selectedPeriod = _pendingPeriod;
                        _selectedCamera = _pendingCamera;
                        _startDate = _pendingStartDate;
                        _endDate = _pendingEndDate;
                      });

                      print("After setState:");
                      print("Period: $_selectedPeriod, Camera: $_selectedCamera");
                      print("Start Date: $_startDate, End Date: $_endDate");

                    },
                    child:
                    Text("적용"),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGraph() {
    print('Selected Period2: $_selectedPeriod');
    print('Selected Camera2: $_selectedCamera');
    print('Start Date2: $_startDate');
    print('End Date2: $_endDate');

    // 주간, 월간 그래프에서는 날짜가 필요하지 않으므로 현재 날짜를 기본값으로 설정
    if (_selectedPeriod == 0 || _selectedPeriod == 1) {
      _startDate = DateTime.now();
      _endDate = DateTime.now();
    }

    // 주간, 월간, 사용자 선택 그래프에 대해 동적으로 key 값을 설정하여 리빌드 유도
    if (_selectedPeriod == 0) {  // 주간 그래프
      DateTime startDate = DateTime.now().subtract(Duration(days: 7));  // 1주일 전
      DateTime endDate = DateTime.now();  // 현재 날짜
      return CameraErrorChart(
        key: ValueKey('week_graph_${_selectedCamera}_${_selectedPeriod}'),
        selectedCamera: _selectedCamera,
        startDate: startDate,
        endDate: endDate,
      );
    } else if (_selectedPeriod == 1) {  // 월간 그래프
      DateTime startDate = DateTime.now().subtract(Duration(days: 30));  // 1달 전
      DateTime endDate = DateTime.now();  // 현재 날짜
      return CameraErrorChart2(
        key: ValueKey('month_graph_${_selectedCamera}_${_selectedPeriod}'),
        selectedCamera: _selectedCamera,
        startDate: startDate,
        endDate: endDate,
      );
    } else {  // 사용자 선택 그래프
      DateTime startDate = _startDate ?? DateTime.now().subtract(Duration(days: 7));  // 기본값: 1주일 전
      DateTime endDate = _endDate ?? DateTime.now();  // 기본값: 현재 날짜
      return CameraErrorChart4(
        key: ValueKey('custom_graph_${_selectedCamera}_${startDate.toIso8601String()}_${endDate.toIso8601String()}'),
        selectedCamera: _selectedCamera,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    print("Building MainScreen with Period: $_selectedPeriod, Camera: $_selectedCamera");

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
