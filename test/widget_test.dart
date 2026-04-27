import 'package:flutter_test/flutter_test.dart';
import 'package:glut/main.dart';

void main() {
  testWidgets('Glut app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GlutApp(onboardingComplete: true));
  });
}
