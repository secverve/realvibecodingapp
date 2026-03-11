import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realvibecodingapp/main.dart';

void main() {
  testWidgets('guest can enter app and see home actions', (tester) async {
    await tester.pumpWidget(const CoupleDiaryApp());

    expect(find.text('Continue as Guest'), findsOneWidget);

    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();

    expect(find.text('Write diary'), findsOneWidget);
    expect(find.text('Diary list'), findsOneWidget);
  });

  testWidgets('write screen shows required fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WriteDiaryScreen()));

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Save diary'), findsOneWidget);
  });
}
