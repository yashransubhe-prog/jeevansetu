import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeevansetu/enhanced_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> verifyLaunchAtSize(
    WidgetTester tester,
    Size size,
  ) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const EnhancedJeevanSetuApp());
    await tester.pump(const Duration(milliseconds: 1900));

    expect(find.text('JeevanSetu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.textContaining('Safer Communities'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('हिन्दी'), findsWidgets);

    await tester.tap(find.text('हिन्दी').last);
    await tester.pumpAndSettle();
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(find.text('डार्क'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  testWidgets('launch controls fit compact Android phone', (tester) async {
    await verifyLaunchAtSize(tester, const Size(360, 640));
  });

  testWidgets('launch controls fit tall Android phone', (tester) async {
    await verifyLaunchAtSize(tester, const Size(412, 915));
  });
}
