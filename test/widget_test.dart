import 'package:flutter_test/flutter_test.dart';
import 'package:realvibecodingapp/main.dart';

void main() {
  testWidgets('초대코드 로그인 화면 노출', (tester) async {
    await tester.pumpWidget(const CoupleMemoryApp());

    expect(find.text('우리의 다이어리'), findsOneWidget);
    expect(find.text('입장하기'), findsOneWidget);
  });
}
