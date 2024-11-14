import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  // 폼 상태 변수 생성
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 생성자
  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) { // 화면 구성
    return Scaffold(
      // header 영역
      appBar: AppBar(
        title: Text("Login",style: TextStyle(color: Colors.purpleAccent),),
        backgroundColor: Colors.greenAccent,
      ),
      // body 영역
      body:
        Container(
          color: Colors.white,
          child: ListView( // 화면 대응과 스크롤이 가능한 리스트로 전체 화면 구성
            padding: EdgeInsets.all(16.0), // padding 추가
            children: [
          SizedBox(height: 100), // 상단 간격 추가
          Column( // 세로 정렬
            children: [
              Text( // widget 1
                "Login",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40), // 간격 추가
              Form( // login form
                key: formKey, // 폼 상태를 추적
                child: Column(
                  children: [
                    // 이메일 입력 필드
                    TextFormField(
                      validator: (value) =>
                      // 유효성 검사 : 값이 비여있으면 오류 메세지 표시
                      value!.isEmpty ? "이메일을 적지 않았습니다." : null,
                      // 입력 영역
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: "이메일을 적어주세요.", // 입력 힌트 텍스트
                        filled: true, // 필드 배경색 활성화
                        fillColor: Colors.black12,
                        enabledBorder: OutlineInputBorder( // 기본상태
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder( // 필드에 포커스
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder( // 오류 발생 시
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedErrorBorder: OutlineInputBorder( // 오류 발생 시 포커스
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // 필드 사이에 간격

                    // 비밀번호 입력 필드
                    TextFormField(
                      obscureText: true, // 비밀번호 입력 가리기
                      validator: (value) =>
                      // 유효성 검사 : 값이 비여있으면 오류 메세지 표시
                      value!.isEmpty ? "비밀번호를 적지 않았습니다." : null,
                      // 입력 영역
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: "비밀번호를 적어주세요.",
                        enabledBorder: OutlineInputBorder( // 기본상태
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(  // 필드에 포커스
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(  // 오류 발생 시
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedErrorBorder: OutlineInputBorder( // 오류 발생 시 포커스
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 40), // 필드 사이 간격

                    // 로그인 버튼
                    ElevatedButton(
                      onPressed: () {
                        // 버튼 클릭 시 호출할 함수 정의
                        if (formKey.currentState!.validate()) {
                          // 폼 유효성 검사. 유효하면 메세지 출력
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Logging in...")),
                          );
                        }
                      },
                      child: Text('Login'), // 버튼 표시 텍스트
                      // 버튼 스타일 설정
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 15.0), // 버튼 내부 패딩
                        shape: RoundedRectangleBorder(  // 버튼 모양 설정
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
        )
    );
  }
}
