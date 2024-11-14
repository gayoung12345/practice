import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입이 완료되었습니다.")),
      );
    } on FirebaseAuthException catch (e) {
      // Firebase Auth에서 발생한 오류 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "회원가입에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register", style: TextStyle(color: Colors.purpleAccent)),
        backgroundColor: Colors.greenAccent,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            SizedBox(height: 100),
            Column(
              children: [
                Text(
                  "Register",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // 이메일 입력 필드
                      TextFormField(
                        controller: emailController,
                        validator: (value) =>
                        value!.isEmpty ? "이메일을 입력하세요." : null,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: "이메일을 입력해주세요.",
                          filled: true,
                          fillColor: Colors.black12,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // 비밀번호 입력 필드
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (value) =>
                        value!.isEmpty ? "비밀번호를 입력하세요." : null,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: "비밀번호를 입력해주세요.",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),

                      // 회원가입 버튼
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _register(context); // 회원가입 함수 호출
                          }
                        },
                        child: Text('Register'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 15.0),
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
