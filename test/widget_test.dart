import 'package:flutter_test/flutter_test.dart';
import 'package:realvibecodingapp/main.dart';

void main() {
  testWidgets('초대코드 로그인 화면 렌더링', (tester) async {
    await tester.pumpWidget(const CoupleMemoryApp());

    expect(find.text('우리의 기록'), findsOneWidget);
    expect(find.text('입장하기'), findsOneWidget);
    expect(find.text('초대코드'), findsOneWidget);
  });
}
