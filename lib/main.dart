import 'package:flutter/material.dart';
import 'counter_test.dart'; // 연결할 페이지 import
import 'sunflower_test.dart';
import 'login_test.dart';
import 'register_page.dart';
import 'package:firebase_core/firebase_core.dart'; // firebase 관련 import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
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
class HomeScreen extends StatefulWidget {
  // 동적 UI
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

  // 현재 표시할 위젯을 저장하는 변수
  Widget currentContent = MyHomePage(title: 'Counter App'); // default: button1
  // 화면 표시 업데이트 함수
  void updateContent(Widget newContent) {
    setState(() {
      currentContent = newContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // header 영역
        title: Text("My Practice App",style: TextStyle(color: Colors.deepPurple),),
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: // body 영역
        Column( // 세로정렬
            children: [
              // 컨텐츠 영역
              Expanded(
                  child: Container(
                    child: currentContent,  // 현재 선택된 컨텐츠 위젯 표시
                  ),
                  flex: 5 // column 내에서 차지하는 비율 5
              ),
              // 버튼 영역
              Expanded(
                  child: Container(
                    color: Colors.lime,
                    child: Row( // 가로정렬
                      mainAxisAlignment: MainAxisAlignment.spaceAround, // 균등 배치
                      children: <Widget>[
                        // button 1
                        ElevatedButton(
                          onPressed: () { // 누르면
                          updateContent(MyHomePage(title: 'Counter App'));  // countApp으로 이동
                        },
                        child: Text('Count'), // button text
                        ),
                        // button2
                        ElevatedButton(
                          onPressed: () { // 누르면
                          updateContent(Sunflower()); // Sunflower으로 이동
                        },
                        child: Text('Sunflower'),
                        ),
                        // button3
                        ElevatedButton(
                        onPressed: () { // 누르면
                        updateContent(LoginPage()); // LoginPage으로 이동
                        },
                        child: Text('Login'),
                        ),
                        ElevatedButton(
                          onPressed: () { // 누르면
                            updateContent(RegisterPage()); // LoginPage으로 이동
                          },
                          child: Text('sign up'),
                        ),
                      ],
                    ),
                  ),
                  flex: 1,  // column 내에서 차지하는 비율
              ),
            ],
        ),
    );
  }
}

