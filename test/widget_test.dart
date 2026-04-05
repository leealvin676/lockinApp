import 'package:flutter_test/flutter_test.dart';
import 'package:lockinapp/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    
    expect(find.text('LockIn Admin'), findsOneWidget);
  });
}