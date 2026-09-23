import 'package:flutter_test/flutter_test.dart';
import 'package:grillpoint/app/app.dart';

void main() {
  testWidgets('GrillPoint app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GrillPointApp());

    expect(find.text('GrillPoint'), findsOneWidget);
  });
}
