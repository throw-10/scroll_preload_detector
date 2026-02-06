# Scroll Preload Detector

A lightweight Flutter widget that listens to scroll notifications and triggers a preload callback when the user scrolls near the end of the content. Essential for implementing smooth infinite scrolling or lazy loading patterns in your Flutter applications.

## Features

*   🚀 **Performance First**: Built on `NotificationListener`, avoiding expensive build cycles.
*   🎯 **Precise Control**: Configure `preloadDistance` to trigger loading exactly when needed.
*   🔄 **Smart Debouncing**: Prevents multiple load triggers while a request is already in progress.
*   🎛 **Flexible Configuration**: Supports custom scroll directions (`scrollDirection`) and specific axes (`axisDirection`).
*   🧩 **Sliver Support**: Dedicated `SliverPreloadTrigger` for complex `CustomScrollView` layouts.
*   🛡 **Control Flags**: Easily enable/disable detection or check `hasMore` data condition.

## Preview

| Enable Preload | Disable Preload |
| :---: | :---: |
| ![Enable Preload](resources/assets/enable_preload.webp) | ![Disable Preload](resources/assets/disable_preload.webp) |

### Sliver Preload

![Sliver Preload](resources/assets/sliver_preload.webp)

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  scroll_preload_detector: ^0.1.0
```

## Usage

### ScrollPreloadDetector

Simply wrap your scrollable widget (e.g., `ListView`, `GridView`) with `ScrollPreloadDetector`.

```dart
import 'package:scroll_preload_detector/scroll_preload_detector.dart';

ScrollPreloadDetector(
  // Trigger loading when 600 pixels from the end
  preloadDistance: 600.0,
  
  // Your data loading logic
  preload: () async {
    await fetchMoreData();
  },
  
  // Check if there is more data to load to prevent unnecessary callbacks
  hasMore: () => hasMoreData,
  
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return ListTile(title: Text('Item $index'));
    },
  ),
)
```

### SliverPreloadTrigger

Use `SliverPreloadTrigger` within a `CustomScrollView` to define independent preload zones for specific sliver sections.


```dart
CustomScrollView(
  slivers: [
    // ... other slivers
    
    // Horizontal list section with internal preload support
    SliverToBoxAdapter(
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
           SliverList(
             delegate: SliverChildBuilderDelegate(
               (context, index) => ItemCard(index),
               childCount: items.length,
             ),
           ),
           // Trigger preloading for this horizontal list
           SliverPreloadTrigger(
             preloadDistance: 150,
             preload: _loadRecommend,
             hasMore: () => _hasMoreRecommend,
           ),
        ],
      ),
    ),
    
    // Vertical list section
    SliverList.builder(
       // ...
    ),
    
    // Trigger preloading for the main vertical scroll
    SliverPreloadTrigger(
      preloadDistance: 500,
      preload: _loadMoreVertical,
      hasMore: () => _hasMoreVertical,
    ),
  ],
)
```

## Additional information

This package is designed to be lightweight and non-intrusive. It doesn't modify your ScrollView's physics or controller, making it compatible with other scroll libraries.
