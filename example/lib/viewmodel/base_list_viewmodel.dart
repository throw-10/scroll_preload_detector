import 'package:flutter/foundation.dart';

import '../api/mock_api.dart';

/// Base class for paginated list ViewModel.
///
/// Provides common loading state management and pagination logic.
abstract class BaseListViewModel<T> extends ChangeNotifier {
  BaseListViewModel({
    this.pageSize = 10,
    this.maxItems = 1000,
  });

  /// Number of items per page.
  final int pageSize;

  /// Maximum total items available.
  final int maxItems;

  /// The loaded items.
  List<T> get items => List.unmodifiable(_items);
  final List<T> _items = [];

  /// Whether a load operation is in progress.
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  /// Whether more items are available to load.
  bool get hasMore => _hasMore;
  bool _hasMore = true;

  final MockApi _api = MockApi();

  /// Loads more items from the API.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.fetchItems(
        _items.length,
        pageSize: pageSize,
        maxItems: maxItems,
      );

      _items.addAll(convertItems(response.items));
      _hasMore = response.hasMore;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Converts raw string items to the target type.
  ///
  /// Override this method to provide custom conversion logic.
  List<T> convertItems(List<String> rawItems);
}
