import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A reusable footer widget for lists showing loading/no-more states.
class ListFooter extends StatelessWidget {
  const ListFooter({
    super.key,
    required this.isLoading,
    required this.hasMore,
    this.onLoadMore,
  });

  /// Whether a load operation is in progress.
  final bool isLoading;

  /// Whether more items are available.
  final bool hasMore;

  /// Callback to manually trigger loading more items.
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CupertinoActivityIndicator();
    }
    if (!hasMore) {
      return const Text('No more data');
    }
    if (onLoadMore != null) {
      return ElevatedButton(
        onPressed: onLoadMore,
        child: const Text('Load More'),
      );
    }
    return const SizedBox.shrink();
  }
}
