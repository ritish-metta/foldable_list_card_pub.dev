import 'package:flutter_test/flutter_test.dart';
import 'package:foldable_list_card/foldable_list_card.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('FoldableListCard expands and collapses', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FoldableListCard(
        header: const Text("Header"),
        expandedChild: const Text("Body"),
      ),
    ));

    // Check header is visible
    expect(find.text("Header"), findsOneWidget);

    // Initially, body should be hidden
    expect(find.text("Body"), findsNothing);

    // Tap to expand
    await tester.tap(find.text("Header"));
    await tester.pumpAndSettle();

    // Body should now be visible
    expect(find.text("Body"), findsOneWidget);

    // Tap cross icon to collapse
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Body hidden again
    expect(find.text("Body"), findsNothing);
  });
}
