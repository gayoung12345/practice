import 'package:flutter/material.dart';
import 'counter_test.dart'; // 연결할 페이지 import
import 'sunflower_test.dart';
import 'login_test.dart';
import 'register_page.dart';
import 'chart_test.dart';
import 'chart_test2.dart';
import 'chart_test3.dart';
import 'chart_test4.dart';
import 'chart_test5.dart';
import 'chartscreen.dart';
import 'package:firebase_core/firebase_core.dart'; // firebase 관련 import
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Widget currentContent = LoginPage(); // 비로그인 상태에서 LoginPage로 기본 설정

  // 화면 표시 업데이트 함수
  void updateContent(Widget newContent) {
    setState(() {
      currentContent = newContent;
    });
  }

  User? currentUser;  // 현재 접속한 유저

  // 로그인 확인 함수
  @override
  void initState() {
    super.initState();
    // FirebaseAuth의 사용자 상태 변경을 수신하여 로그인 여부 확인
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user; // 로그인된 사용자 업데이트
        // 로그인 상태에 따라 첫 화면 설정
        if (currentUser != null) {
          currentContent = MyHomePage(title: 'Counter App'); // 로그인된 경우
        } else {
          currentContent = LoginPage(); // 비로그인 상태인 경우
        }
      });
    });
  }

  // 로그아웃 함수
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      currentUser = null; // 로그아웃 후 로그인 상태를 null로 설정
      currentContent = LoginPage(); // 로그인 페이지로 변경
    });
  }

  // 버튼 영역 표시 함수
  List<Widget> _getButtonWidgets() {
    if (currentUser != null) {
      // 로그인된 상태에서 보이는 버튼
      return [
        ElevatedButton(
          onPressed: () {
            updateContent(MainScreen()); // countApp으로 이동
          },
          child: Text('chart'),
        ),
        ElevatedButton(
          onPressed: () {
            updateContent(CameraErrorChart3()); // countApp으로 이동
          },
          child: Text('chart'),
        ),
      ];
    } else {
      // 비로그인 상태에서 보이는 버튼
      return [
        ElevatedButton(
          onPressed: () {
            updateContent(LoginPage()); // LoginPage으로 이동
          },
          child: Text('Login'),
        ),
        ElevatedButton(
          onPressed: () {
            updateContent(RegisterPage()); // RegisterPage으로 이동
          },
          child: Text('Sign Up'),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 로그인 여부에 따라 Tab 수 설정
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Practice App",
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.limeAccent,
          actions: [
            if (currentUser != null)
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _logout,
              ),
          ],
          bottom: TabBar(
            tabs: currentUser != null
                ? [
              Tab(text: 'Chart'),
              Tab(text: 'Chart2'),
            ]
                : [
              Tab(text: 'Login'), // 비로그인 상태일 때의 탭
              Tab(text: 'Sign Up'),
            ],
          ),
        ),
        body: TabBarView(
          children: currentUser != null
              ? [
            MainScreen(),
            CameraErrorChart3(),
          ]
              : [
            LoginPage(), // Login 탭의 컨텐츠
            RegisterPage(), // Sign Up 탭의 컨텐츠
          ],
        ),
      ),
    );
  }
}
