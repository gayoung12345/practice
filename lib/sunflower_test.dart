import 'package:flutter/material.dart';
import 'dart:math' as math;

const int maxSeeds = 250; // seed의 최대 갯수

class Sunflower extends StatefulWidget {
  const Sunflower({super.key}); // 생성자

  @override
  State<StatefulWidget> createState() {
    // 상태 관리 클래스 생성
    return _SunflowerState();
  }
}

// 상태 관리 클래스
class _SunflowerState extends State<Sunflower> {

  int seeds = maxSeeds ~/ 2;  // 화면에 표시될 씨앗의 초기 개수

  @override
  Widget build(BuildContext context) {  // 화면 구성
    return Scaffold(
      // header 영역
      appBar: AppBar(
        title: Text("Sunflower",style: TextStyle(color: Colors.black45),),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      // body 영역
      body: Container(
        color: Colors.white,
        child: Center(  // 가운데 정렬
          child: Column( // 세로 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 가운데 정렬
            children: [
              // 남은 공간을 채우는 위젯
              Expanded(
                child: SunflowerWidget(seeds), // SunflowerWidget class 호출
              ),
              const SizedBox(height: 20), // 간격 추가
              Text('Showing ${seeds.round()} seeds'), // 현재 seeds 수 표시
              // 슬라이더
              Slider(
                min: 1, // 최소값
                max: maxSeeds.toDouble(), // 최대값
                value: seeds.toDouble(), // 현재값
                // 슬라이더가 변경될 때 마다 호출
                onChanged: (val) {
                  setState(() => seeds = val.round()); // 씨앗 개수를 슬라이더 값으로 변경
                },
              ),
              const SizedBox(height: 20), // 간격 추가
            ],
          ),
      ),
      )
    );
  }
}

// 위젯 정의
class SunflowerWidget extends StatelessWidget {
  static const tau = math.pi * 2; // 한 바퀴(360도)를 나타내는 상수 정의
  static const scaleFactor = 1 / 40;  // 씨앗이 배치되는 거리 비율
  static const size = 600.0;  // sunflower의 전체 크기
  static final phi = (math.sqrt(5) + 1) / 2;  // 황금비율 값
  static final rng = math.Random(); // 애니메이션 시간에 사용할 난수 생성

  final int seeds;  // 현재 씨앗의 갯수

  const SunflowerWidget(this.seeds, {super.key}); // 현재 씨앗의 갯수를 매개변수로 받음

  @override
  Widget build(BuildContext context) {
    final seedWidgets = <Widget>[]; // 씨앗을 저장할 리스트

    // 표시할 씨앗 개수에 따라 씨앗을 배치
    for (var i = 0; i < seeds; i++) {
      final theta = i * tau / phi; // 회전각 계산 (i++ 할 수록 회전)
      final r = math.sqrt(i) * scaleFactor; // 씨앗이 중심에서 얼마나 떨어질지 계산

      seedWidgets.add(AnimatedAlign(
        key: ValueKey(i), // 애니메이션을 위한 키 설정
        duration: Duration(milliseconds: rng.nextInt(500) + 250), // 애니메이션 시간 설정 (250ms~750ms)
        curve: Curves.easeInOut,  // 부드럽게 시작하고 끝나는 애니메이션 곡률 적용
        alignment: Alignment(r * math.cos(theta), -1 * r * math.sin(theta)), // 좌표에 따른 씨앗 위치 설정
        child: const Dot(true), // Dot 위젯 생성(씨앗 그림) lit 상태 O
      ));
    }

    // 남은 씨앗을 화면 주변에 무작위로 배치
    for (var j = seeds; j < maxSeeds; j++) {
      final x = math.cos(tau * j / (maxSeeds - 1)) * 0.9; // 원을 따라 배치할 x 좌표
      final y = math.sin(tau * j / (maxSeeds - 1)) * 0.9; // y 좌표

      seedWidgets.add(AnimatedAlign(
        key: ValueKey(j), // 애니메이션을 위한 키 설정
        duration: Duration(milliseconds: rng.nextInt(500) + 250), // 애니메이션 시간 설정 (250ms~750ms)
        curve: Curves.easeInOut,  // 부드럽게 시작하고 끝나는 애니메이션 곡률 적용
        alignment: Alignment(x, y), // 원에 따른 좌표로 씨앗 위치 설정
        child: const Dot(false), // Dot 위젯 생성(씨앗 그림) lit 상태 X
      ));
    }

    return FittedBox(
      fit: BoxFit.contain,  // 주어진 영역에 맞춰 위젯 크기 축소 또는 확대
      child: SizedBox(
        height: size, // sunflower 높이
        width: size, // 폭
        child: Stack(children: seedWidgets), // 씨앗을 겹쳐서 배치
      ),
    );
  }
}

class Dot extends StatelessWidget {
  static const size = 5.0;  // dot의 크기
  static const radius = 3.0;  // dot의 모서리 둥글기 정도

  final bool lit; // Dot 활성화 상태 여부

  const Dot(this.lit, {super.key}); // Dot의 생성자와 lit 상태를 매개변수로 받음

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: lit ? Colors.orange : Colors.grey.shade700,  // 활성화된 상태에 따라 색상 변경
        borderRadius: BorderRadius.circular(radius),  // 둥근 모서리 설정
      ),
      child: const SizedBox(
        height: size, // Dot의 높이
        width: size,  // Dot의 너비
      ),
    );
  }
}
