import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final String title; // 타이틀 명

  const MyHomePage({
    super.key,
    required this.title, // title을 매개변수로 받음
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0; // _counter 변수 선언 및 초기화

  // 카운트 상승 메소드 선언
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // header 영역
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.purple),), // 매개변수로 받은 title을 사용
        backgroundColor: Colors.greenAccent,
      ),
      // body 영역
      body: Container(
        color: Colors.white,
        child: Center( // 가운데 정렬
          child: Column( // 세로 정렬
            // widget 1
            mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
            children: [
              const Text( // 문구
                '+ 버튼을 누른 횟수',
              ),
              Text(
                '$_counter', // 숫자 변수 출력
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
      ),
      ),
      // fab
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter, // 메소드 호출
        tooltip: '버튼을 누르면 숫자가 1씩 상승합니다.', // tooltip message
        child: const Icon(Icons.add), // + icon (기본 라이브러리)
        // 스타일 속성들
        backgroundColor: Colors.greenAccent,  // 버튼의 배경색
        foregroundColor: Colors.purple, // 아이콘 색상
        elevation: 5.0,  // 버튼의 그림자 깊이
        shape: RoundedRectangleBorder(  // 버튼 모양 변경 (사각형 모서리 둥글게)
          borderRadius: BorderRadius.circular(20),
        ),
        splashColor: Colors.deepOrange, // 버튼을 누를 때 효과 색상
      ),
    );
  }
}
