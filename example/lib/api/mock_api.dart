import 'dart:math';

class MockApi {
  /// Simulates fetching items from a network source.
  ///
  /// [currentCount] is the current number of items loaded.
  /// [pageSize] is the number of items per page (default: 10).
  /// [maxItems] is the maximum total items available (default: 1000).
  /// Returns a [MockResponse] containing new items and whether there are more items.
  Future<MockResponse> fetchItems(
    int currentCount, {
    int pageSize = 10,
    int maxItems = 1000,
  }) async {
    // Simulate network delay: 50ms to 600ms
    final random = Random();
    final delay = random.nextInt(550) + 50;
    await Future.delayed(Duration(milliseconds: delay));

    // Generate more items
    final newItems = List.generate(
      pageSize,
      (index) => 'Item ${currentCount + index}',
    );

    final bool hasMore = (currentCount + newItems.length) < maxItems;

    return MockResponse(items: newItems, hasMore: hasMore);
  }
}

class MockResponse {
  final List<String> items;
  final bool hasMore;

  MockResponse({required this.items, required this.hasMore});
}
