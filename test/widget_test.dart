
import 'package:flutter_test/flutter_test.dart';
import 'package:linkvault/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LinkVault app starts', (WidgetTester tester) async {
    // This test still requires Firebase dependencies to be mocked
    // or injected before LinkVaultApp can be built successfully.
    await tester.pumpWidget(const LinkVaultApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
