import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Debug ClampingScrollPhysics edge case', (WidgetTester tester) async {
    bool triggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 500,
          child: CustomScrollView(
            cacheExtent: 0, // Force strict visibility
            physics: const ClampingScrollPhysics(), // Boundary hard stop
            slivers: [
              // List takes exactly 5000px (Far away)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const SizedBox(height: 5000),
                  childCount: 1,
                ),
              ),
              // Zero-size detector at 5000px
            ],
          ),
        ),
      ),
    );

    // Initial: Viewport [0, 500]. Detector at 1000. Hidden.
    expect(triggered, isFalse);

    // Scroll to EXACTLY the end: 5000 - 500 = 4500 offset.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4500));
    await tester.pump();

    // Viewport [500, 1000]. Detector at 1000.
    // Boundary condition: Is 1000 included?
    // Usually indices are [start, end). So 1000 is excluded.
    // So remainingPaintExtent might be 0.

    // if (!triggered) {
    //   print("Failed to trigger at exact boundary with ClampingPhysics");
    // }
  });
}
