import 'package:flutter/material.dart';
import 'counter_test.dart'; // 연결할 페이지 import
import 'sunflower_test.dart';
import 'login_test.dart';

void main() => runApp(MyApp()); // 앱 실행

class MyApp extends StatelessWidget{  // 상태 변경 없는 위젯(UI가 한번 그려지면, 상태 유지)
  @override
  Widget build(BuildContext context){ // 화면 생성
    return new MaterialApp( // MaterialApp : 구글 기본 디자인
      title: 'Flutter App Practice', // page title
      debugShowCheckedModeBanner: false, // 화면에 debug 표시 끄기
      home: const HomeScreen(), // 화면 영역
    );
  }
}

// 화면 영역
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // header 영역
        title: Text("My Practice App",style: TextStyle(color: Colors.deepPurple),),
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: // body 영역
      Container( // Container로 감싸기 (필수 아님)
        color: Colors.white, // Container 영역 배경색 변경
        child: Column(
            children: [
              // widget 1 : AppBar와 첫 번째 Row 사이의 간격 생성
              SizedBox(height: 20),
              // widget 2 : buttons
              Row( // 가로 정렬
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                // widget 2-1
                ElevatedButton(
                  onPressed: () { // 버튼을 누르면
                    Navigator.push( // 화면 전환
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const MyHomePage(title: 'Counter App'), // counter_test.dart의 MyHomePage로 이동. 매개변수로 title을 받음
                      ),
                    );
                  },
                  child: Text('button1'), // 화면에 표시 될 text
                ),
                // widget 2-2
                ElevatedButton(
                  onPressed: () { // 버튼을 누르면
                    Navigator.push( // 화면 전환 
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Sunflower(), // sunfloer_test.dart의 Sunflower로 이동. 매개변수 받지 않음
                      ),
                    );
                  },
                  child: Text('button2'), // 화면에 표시 될 text
                ),
                // widget 2-3
                ElevatedButton(
                  onPressed: () { // 버튼을 누르면
                    Navigator.push( // 화면 전환
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),  // login_test.dart의 LoginPage로 이동
                      ),
                    );
                  },
                  child: Text('button3'), // 화면에 표시 될 text
                ),
              ],
            ),
        ]
        ),
      )


    );
  }
}
