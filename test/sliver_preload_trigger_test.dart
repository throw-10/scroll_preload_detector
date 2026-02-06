import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_preload_detector/scroll_preload_detector.dart';

void main() {
  group('SliverPreloadTrigger', () {
    testWidgets('renders in CustomScrollView without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Text('Item $index'),
                  childCount: 10,
                ),
              ),
              SliverPreloadTrigger(
                preload: () async {},
                hasMore: () => true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('calls preload when scrolled within distance', (tester) async {
      bool preloadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 400,
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(
                      height: 50,
                      child: Text('Item $index'),
                    ),
                    childCount: 50,
                  ),
                ),
                SliverPreloadTrigger(
                  preload: () async {
                    preloadCalled = true;
                  },
                  hasMore: () => true,
                  preloadDistance: 100.0,
                ),
              ],
            ),
          ),
        ),
      );

      expect(preloadCalled, isFalse);

      // Scroll to the bottom
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(preloadCalled, isTrue);
    });

    testWidgets('does not call preload if hasMore returns false', (tester) async {
      bool preloadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 400,
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(
                      height: 50,
                      child: Text('Item $index'),
                    ),
                    childCount: 50,
                  ),
                ),
                SliverPreloadTrigger(
                  preload: () async {
                    preloadCalled = true;
                  },
                  hasMore: () => false,
                  preloadDistance: 500.0,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(preloadCalled, isFalse);
    });

    testWidgets('does not call preload if enabled is false', (tester) async {
      bool preloadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 400,
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(
                      height: 50,
                      child: Text('Item $index'),
                    ),
                    childCount: 50,
                  ),
                ),
                SliverPreloadTrigger(
                  preload: () async {
                    preloadCalled = true;
                  },
                  hasMore: () => true,
                  enabled: false,
                  preloadDistance: 500.0,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(preloadCalled, isFalse);
    });

    testWidgets('prevents multiple concurrent preload calls', (tester) async {
      int callCount = 0;
      bool isCurrentlyLoading = false;
      bool concurrentCallDetected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 400,
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(
                      height: 50,
                      child: Text('Item $index'),
                    ),
                    childCount: 20,
                  ),
                ),
                SliverPreloadTrigger(
                  preload: () async {
                    if (isCurrentlyLoading) {
                      concurrentCallDetected = true;
                    }
                    isCurrentlyLoading = true;
                    callCount++;
                    await Future.delayed(const Duration(milliseconds: 100));
                    isCurrentlyLoading = false;
                  },
                  hasMore: () => true,
                  preloadDistance: 800.0,
                ),
              ],
            ),
          ),
        ),
      );

      // First scroll triggers preload
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Multiple scrolls while loading should not trigger concurrent calls
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -10));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 200));

      expect(concurrentCallDetected, isFalse);
      expect(callCount, greaterThanOrEqualTo(1));
    });

    testWidgets('works with multiple triggers in same CustomScrollView', (tester) async {
      bool firstPreloadCalled = false;
      bool secondPreloadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 400,
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(
                      height: 50,
                      child: Text('Section 1 Item $index'),
                    ),
                    childCount: 5,
                  ),
                ),
                SliverPreloadTrigger(
                  preload: () async {
                    firstPreloadCalled = true;
                  },
                  hasMore: () => true,
                  preloadDistance: 100.0,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(
                      height: 50,
                      child: Text('Section 2 Item $index'),
                    ),
                    childCount: 50,
                  ),
                ),
                SliverPreloadTrigger(
                  preload: () async {
                    secondPreloadCalled = true;
                  },
                  hasMore: () => true,
                  preloadDistance: 100.0,
                ),
              ],
            ),
          ),
        ),
      );

      // First trigger should be called immediately (within viewport)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(firstPreloadCalled, isTrue);

      // Scroll to the end to trigger second
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(secondPreloadCalled, isTrue);
    });
  });
}
