import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadCounter(); // 초기 카운트 값을 Firestore에서 로드
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCounter(); // 페이지 이동 시 Firestore에서 카운트 값을 다시 불러오기
  }

  // Firestore에서 카운트 값 로드
  Future<void> _loadCounter() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc['counter'] != null) {
        setState(() {
          _counter = userDoc['counter'];
        });
      }
    }
  }
  // 카운트 상승 메소드 선언
  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set(
        {'counter': _counter},
        SetOptions(merge: true), // 기존 데이터에 카운트 값만 업데이트
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // header 영역
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.black54)), // 매개변수로 받은 title을 사용
        backgroundColor: Colors.white,
        centerTitle: true,
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
                style: TextStyle(fontSize: 30), // 텍스트 크기 지정
              ),
              Text(
                '$_counter', // 숫자 변수 출력
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
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
        backgroundColor: Colors.limeAccent,  // 버튼의 배경색
        foregroundColor: Colors.deepPurple, // 아이콘 색상
        elevation: 5.0,  // 버튼의 그림자 깊이
        shape: RoundedRectangleBorder(  // 버튼 모양 변경 (사각형 모서리 둥글게)
          borderRadius: BorderRadius.circular(20),
        ),
        splashColor: Colors.deepOrange, // 버튼을 누를 때 효과 색상
      ),
    );
  }
}
