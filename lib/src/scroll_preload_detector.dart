import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A widget that detects scroll events and triggers a preload callback when the
/// scroll position reaches a certain distance from the end of the scrollable area.
///
/// This widget is useful for implementing infinite scrolling or lazy loading
/// of lists. It listens to [ScrollUpdateNotification]s bubbling up from its
/// child (e.g., a [ListView] or [CustomScrollView]) and calls the [preload]
/// function when the remaining scroll extent is less than [preloadDistance].
///
/// Example usage:
/// ```dart
/// ScrollPreloadDetector(
///   preload: () async {
///     await fetchMoreData();
///   },
///   hasMore: () => hasMoreData,
///   child: ListView.builder(
///     itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
///   ),
/// )
/// ```
class ScrollPreloadDetector extends StatefulWidget {
  /// Creates a [ScrollPreloadDetector].
  ///
  /// The [child] and [preload] arguments must not be null.
  const ScrollPreloadDetector({
    super.key,
    required this.child,
    required this.preload,
    this.preloadDistance = 600.0,
    this.scrollDirection,
    this.axisDirection,
    this.hasMore,
    this.enabled = true,
  });

  /// The widget below this widget in the tree.
  ///
  /// This is typically a [ScrollView] like [ListView] or [GridView], or a
  /// widget that contains a [ScrollView].
  final Widget child;

  /// A callback expression that is called when the scroll position approaches
  /// the end of the scrollable area.
  ///
  /// This function should return a [Future] that completes when the data
  /// loading logic is finished. Multiple calls to [preload] are prevented
  /// while a previous call is still pending.
  final Future<void> Function() preload;

  /// A callback that returns `true` if there is more data to load.
  ///
  /// If this returns `false`, the [preload] callback will not be called.
  /// If this is not provided (null), it defaults to behaving as if there is
  /// more data, and [preload] will be called when threshold is reached.
  final bool Function()? hasMore;

  /// The distance from the end of the scrollable area at which to trigger
  /// the [preload] callback.
  ///
  /// Defaults to 600.0 logical pixels.
  final double preloadDistance;

  /// The axis along which the scroll view scrolls.
  ///
  /// If non-null, this widget will separate notifications from other scroll
  /// views in the hierarchy by matching the axis.
  final Axis? scrollDirection;

  /// The direction in which the scroll view scrolls.
  ///
  /// If non-null, this widget will separate notifications from other scroll
  /// views in the hierarchy by matching the axis direction.
  final AxisDirection? axisDirection;

  /// Whether preloading is enabled.
  ///
  /// If `false`, the [preload] callback will not be automatically triggered
  /// by scroll events. Defaults to `true`.
  final bool enabled;

  @override
  State<ScrollPreloadDetector> createState() => _ScrollPreloadDetectorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('preloadDistance', preloadDistance));
    properties.add(EnumProperty<Axis?>('scrollDirection', scrollDirection));
    properties.add(EnumProperty<AxisDirection?>('axisDirection', axisDirection));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
  }
}

class _ScrollPreloadDetectorState extends State<ScrollPreloadDetector> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!widget.enabled) {
          return false;
        }

        // Filter by scroll direction if specified
        if (widget.scrollDirection != null && notification.metrics.axis != widget.scrollDirection) {
          return false;
        }
        // Filter by axis direction if specified
        if (widget.axisDirection != null && notification.metrics.axisDirection != widget.axisDirection) {
          return false;
        }

        // Check if we are close enough to the end to preload
        if (notification.metrics.extentAfter <= widget.preloadDistance) {
          // Verify if we have more data to load
          // If [hasMore] is null, we assume there is more data to be safe.
          if (widget.hasMore?.call() == false) return false;

          _maybeLoadMore();
        }
        return false;
      },
      child: widget.child,
    );
  }

  Future<void> _maybeLoadMore() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      await widget.preload();
    } finally {
      _isLoading = false;
    }
  }
}
