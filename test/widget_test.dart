import 'package:flutter_test/flutter_test.dart';
import 'package:lockinapp/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    // 只检查 app 是否正常加载
    expect(find.text('LockIn Admin'), findsOneWidget);
  });
}