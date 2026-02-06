import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A zero-size sliver that triggers preloading when approaching the scroll end.
///
/// Place this widget as the last sliver in a [CustomScrollView] to implement
/// infinite scroll / load-more functionality.
///
/// Example:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverList(...),
///     SliverPreloadTrigger(
///       preload: () => postViewModel.loadMore(),
///       hasMore: () => postViewModel.hasMore,
///     ),
///     SliverList(...),
///     SliverPreloadTrigger(
///       preload: () => commentViewModel.loadMore(),
///       hasMore: () => commentViewModel.hasMore,
///     ),
///   ],
/// )
/// ```
class SliverPreloadTrigger extends LeafRenderObjectWidget {
  /// Creates a [SliverPreloadTrigger].
  ///
  /// The [preload] and [hasMore] arguments must not be null.
  const SliverPreloadTrigger({
    super.key,
    required this.preload,
    required this.hasMore,
    this.preloadDistance = 600.0,
    this.enabled = true,
  }) : assert(preloadDistance >= 0, 'preloadDistance must be non-negative');

  /// The distance from the end of the scrollable area at which to trigger
  /// the [preload] callback.
  ///
  /// Defaults to 600.0 logical pixels.
  final double preloadDistance;

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
  final bool Function() hasMore;

  /// Whether preloading is enabled.
  ///
  /// If `false`, the [preload] callback will not be automatically triggered.
  /// Defaults to `true`.
  final bool enabled;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverPreload(
      preload: preload,
      preloadDistance: preloadDistance,
      hasMore: hasMore,
      enabled: enabled,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSliverPreload renderObject,
  ) {
    renderObject
      ..preload = preload
      ..preloadDistance = preloadDistance
      ..hasMore = hasMore
      ..enabled = enabled;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('preloadDistance', preloadDistance));
  }
}

/// The render object for [SliverPreloadTrigger].
class RenderSliverPreload extends RenderSliver {
  /// Creates a [RenderSliverPreload].
  RenderSliverPreload({
    required Future<void> Function() preload,
    required double preloadDistance,
    required bool Function() hasMore,
    required bool enabled,
  })  : _preload = preload,
        _preloadDistance = preloadDistance,
        _hasMore = hasMore,
        _enabled = enabled;

  Future<void> Function() _preload;

  /// A callback expression that is called when the scroll position approaches
  /// the end of the scrollable area.
  ///
  /// Changing this does not trigger a layout since it only affects behavior,
  /// not geometry.
  Future<void> Function() get preload => _preload;
  set preload(Future<void> Function() value) {
    if (_preload == value) return;
    _preload = value;
  }

  double _preloadDistance;

  /// The distance from the end of the scrollable area at which to trigger
  /// the [preload] callback.
  double get preloadDistance => _preloadDistance;
  set preloadDistance(double value) {
    if (_preloadDistance == value) return;
    _preloadDistance = value;
    markNeedsLayout();
  }

  bool Function() _hasMore;

  /// A callback that returns `true` if there is more data to load.
  bool Function() get hasMore => _hasMore;
  set hasMore(bool Function() value) {
    if (_hasMore == value) return;
    _hasMore = value;
    markNeedsLayout();
  }

  bool _enabled;

  /// Whether preloading is enabled.
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    markNeedsLayout();
  }

  RenderViewport? _viewport;
  bool _isLoading = false;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _findViewport();
  }

  @override
  void detach() {
    _viewport = null;
    super.detach();
  }

  void _findViewport() {
    RenderObject? node = parent;
    while (node != null) {
      if (node is RenderViewport) {
        _viewport = node;
        return;
      }
      node = node.parent;
    }
  }

  @override
  void performLayout() {
    geometry = SliverGeometry.zero;

    if (!_enabled) return;
    if (!_hasMore()) return;

    if (_viewport == null) {
      _findViewport();
    }
    if (_viewport == null) return;

    final double globalOffset = _viewport!.offset.pixels;
    final double preceding = constraints.precedingScrollExtent;
    final double viewportHeight = constraints.viewportMainAxisExtent;

    // Distance from this sliver to the viewport bottom.
    // Positive = below screen, Negative = on screen.
    final double distanceToBottom = preceding - globalOffset - viewportHeight;

    if (distanceToBottom <= _preloadDistance) {
      _maybePreload();
    }
  }

  void _maybePreload() {
    if (_isLoading) return;

    _isLoading = true;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        await _preload();
      } finally {
        _isLoading = false;
      }
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('preloadDistance', preloadDistance));
    properties.add(FlagProperty('isLoading', value: _isLoading, ifTrue: 'loading'));
  }
}
