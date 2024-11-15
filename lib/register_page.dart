import 'package:flutter/material.dart';
import 'main.dart'; // 회원가입 후 메인으로 이동
import 'package:firebase_auth/firebase_auth.dart'; // firebase에서 회원 정보 등록 하기 위해 import

class RegisterPage extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // TextEditingController: 입력값을 가져오기 위한 컨트롤러
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterPage({Key? key}) : super(key: key);

  // Firebase 회원가입 함수
  Future<void> _register(BuildContext context) async {
    try {
      // Firebase Auth의 createUserWithEmailAndPassword 메서드를 사용하여 회원가입
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), // 입력된 이메일에서 공백 제거
        password: passwordController.text.trim(), // 입력된 비밀번호에서 공백 제거
      );
      
      // 회원가입에 성공하면 스낵바로 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입이 완료되었습니다.")),
      );

      // 회원가입에 성공하면 HomeScreen으로 화면 전환
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // 회원가입 성공 후 HomeScreen으로 이동
      );
      
    } on FirebaseAuthException catch (e) {
      // Firebase Auth에서 발생한 오류 메시지   출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "회원가입에 실패했습니다.")),  // exception에 없는 오류일 경우 작성한 문구 출력
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
                  "Register",
                  style: TextStyle(color: Colors.black45, fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40), // 제목과 폼 사이의 여백
                Form( // 회원가입 폼
                  key: formKey, // 폼의 유효성 검증 키
                  child: Column(  // 세로 정렬
                    children: [
                      // 이메일 입력 필드
                      TextFormField(
                        controller: emailController,
                        validator: (value) =>
                        value!.isEmpty ? "이메일을 입력하세요." : null,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: "이메일을 입력해주세요.",
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
                        value!.isEmpty ? "비밀번호를 입력하세요." : null,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: "비밀번호를 입력해주세요.",
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
                      // 회원가입 버튼
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) { // 폼 유효성 검사
                            _register(context); // 회원가입 함수 호출
                          }
                        },
                        child: Text('Register'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 15.0),  // 버튼 패딩
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
}
