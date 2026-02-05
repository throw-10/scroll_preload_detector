import 'dart:math';

class MockApi {
  static const int _pageSize = 10;
  static const int _maxItems = 1000;

  /// Simulates fetching items from a network source.
  ///
  /// [currentCount] is the current number of items loaded.
  /// Returns a [MockResponse] containing new items and whether there are more items.
  Future<MockResponse> fetchItems(int currentCount) async {
    // Simulate network delay: 50ms to 600ms
    final random = Random();
    final delay = random.nextInt(550) + 50;
    await Future.delayed(Duration(milliseconds: delay));

    // Generate more items
    final newItems = List.generate(
      _pageSize,
      (index) => 'Item ${currentCount + index}',
    );

    final bool hasMore = (currentCount + newItems.length) < _maxItems;

    return MockResponse(items: newItems, hasMore: hasMore);
  }
}

class MockResponse {
  final List<String> items;
  final bool hasMore;

  MockResponse({required this.items, required this.hasMore});
}
