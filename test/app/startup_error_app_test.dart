import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/startup_error_app.dart';

void main() {
  testWidgets('explains the failure and that data is unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(StartupErrorApp(error: Exception('disk is full')));
    expect(find.text("The wardrobe couldn't be opened"), findsOneWidget);
    expect(
      find.textContaining('Your data has not been changed'),
      findsOneWidget,
    );
    expect(find.textContaining('disk is full'), findsOneWidget);
  });
}
