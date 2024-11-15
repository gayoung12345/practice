import 'package:flutter/material.dart';
import 'main.dart'; // 로그인 후 메인으로 이동
import 'package:firebase_auth/firebase_auth.dart';  // firebase에서 회원 정보 가지고 오기 위해 import

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState(); // 로그인 페이지 상태 가지고 옴
}

// login page의 상태 클래스
class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();  // 폼 유효성 검사를 위한 키
  // 이메일과 비밀번호 입력을 위한 컨트롤러 선언
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firebase 로그인 함수
  Future<void> _login(BuildContext context) async {
    try {
      // firebase Auth의 로그인 메소드 호출
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), // 입력된 이메일에서 공백 제거  .trim()
        password: passwordController.text.trim(), // 입력된 비밀번호에서 공백 제거
      );

      // 로그인에 성공하면 스낵바로 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 성공")),
      );

      // 로그인에 성공하면 HomeScreen으로 화면 전환
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // 로그인 성공 후 HomeScreen으로 이동
      );
    } on FirebaseAuthException catch (e) {
      // Firebase Auth 오류 메시지 사용자 정의
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "로그인에 실패했습니다.")),  // exception에 없는 오류일 경우 작성한 문구 출력
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,  // 배경색
        child: ListView(  // 자동으로 스크롤이 생기는 ListView 사용
          padding: EdgeInsets.all(50.0),  // 좌우 여백
          children: [
            SizedBox(height: 100),  // 상단 여백
            Column(
              children: [
                Text( // 제목
                  "Login",
                  style: TextStyle(color: Colors.black45, fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40), // 제목과 폼 사이의 여백
                Form( // 로그인 폼
                  key: formKey, // 폼의 유효성 검증 키
                  child: Column(  // 세로 정렬
                    children: [
                      // 이메일 입력 필드
                      TextFormField(
                        controller: emailController,  // 이메일 컨트롤러
                        validator: (value) =>
                        value!.isEmpty ? "이메일을 적지 않았습니다." : null,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: "이메일을 적어주세요.",
                          filled: true, // 입력 영역 배경
                          fillColor: Colors.black12,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),  // 기본 상태
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),  // 포커스 시
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),  // 오류 발생 시
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),  // 오류 발생 시 포커스
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // 이메일과 비밀번호 필드 사이 간격
                      // 비밀번호 입력 필드
                      TextFormField(
                        controller: passwordController, // 비밀번호 컨트롤러
                        obscureText: true,  // 비밀번호 숨김
                        validator: (value) =>
                        value!.isEmpty ? "비밀번호를 적지 않았습니다." : null,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: "비밀번호를 적어주세요.",
                          filled: true,
                          fillColor: Colors.black12,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),  // 기본 상태
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),  // 포커스 시
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),  // 오류 발생 시
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),  // 오류 발생 시 포커스
                          ),
                        ),
                      ),
                      SizedBox(height: 40), // 비밀번호 필드와 로그인 버튼 사이 간격
                      // 로그인 버튼
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) { // 폼 유효성 검사
                            _login(context);  // 로그인 함수 호출
                          }
                        },
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 15.0), // 버튼 패딩
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 컨트롤러 해제
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
