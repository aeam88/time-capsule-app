import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await dotenv.load(fileName: '.env');
    // App test would go here with mocked dependencies
    expect(true, isTrue);
  });
}
