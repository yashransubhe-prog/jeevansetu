import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeevansetu/enhanced_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void expectNoUnexpectedUiException(WidgetTester tester) {
    final unexpected = <Object>[];
    Object? error;
    while ((error = tester.takeException()) != null) {
      final text = error.toString();
      if (text.contains('NetworkImageLoadException') ||
          text.contains('HTTP request failed, statusCode: 400')) {
        continue;
      }
      unexpected.add(error!);
    }
    expect(
      unexpected,
      isEmpty,
      reason: 'Unexpected UI/layout exception detected: $unexpected',
    );
  }

  Future<void> verifyLaunchAtSize(
    WidgetTester tester,
    Size size,
  ) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const EnhancedJeevanSetuApp());
    await tester.pump(const Duration(milliseconds: 1900));

    expect(find.text('JeevanSetu'), findsOneWidget);
    expectNoUnexpectedUiException(tester);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.textContaining('Safer Communities'), findsOneWidget);
    expectNoUnexpectedUiException(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('हिन्दी'), findsWidgets);

    await tester.tap(find.text('हिन्दी').last);
    await tester.pumpAndSettle();
    expect(find.text('हिन्दी'), findsOneWidget);
    expectNoUnexpectedUiException(tester);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(find.text('डार्क'), findsOneWidget);
    expectNoUnexpectedUiException(tester);
  }

  testWidgets('launch controls fit compact Android phone', (tester) async {
    await verifyLaunchAtSize(tester, const Size(360, 640));
  });

  testWidgets('launch controls fit tall Android phone', (tester) async {
    await verifyLaunchAtSize(tester, const Size(412, 915));
  });
}
