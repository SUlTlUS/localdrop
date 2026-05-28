import 'package:flutter_test/flutter_test.dart';
import 'package:localdrop/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LocalDropApp());
    expect(find.text('LocalDrop'), findsNothing);
  });
}
