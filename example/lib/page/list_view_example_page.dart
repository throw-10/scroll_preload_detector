import 'package:flutter/material.dart';
import 'package:scroll_preload_detector/scroll_preload_detector.dart';

import '../api/mock_api.dart';
import '../widget/list_footer.dart';
import '../widget/scroll_debug_overlay.dart';

class ListViewExamplePage extends StatefulWidget {
  const ListViewExamplePage({super.key});

  @override
  State<ListViewExamplePage> createState() => _ListViewExamplePageState();
}

class _ListViewExamplePageState extends State<ListViewExamplePage> {
  final MockApi _api = MockApi();
  final List<String> _items = List.generate(20, (index) => 'Item $index');

  bool _isLoading = false;
  bool _hasMore = true;
  bool _enablePreload = true;

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _api.fetchItems(_items.length);

      if (mounted) {
        setState(() {
          _items.addAll(response.items);
          _hasMore = response.hasMore;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scroll Preload'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Preload'),
              Checkbox(
                value: _enablePreload,
                onChanged: (value) {
                  setState(() {
                    _enablePreload = value ?? false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: ScrollDebugOverlay(
        loadingStates: {'List': _isLoading},
        child: ScrollPreloadDetector(
          enabled: _enablePreload,
          preload: _loadMore,
          hasMore: () => _hasMore,
          preloadDistance: 600.0,
          child: CustomScrollView(
            slivers: [
              SliverList.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) => ListTile(
                  title: Text(_items[index]),
                  subtitle: Text('Index $index'),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: ListFooter(
                    isLoading: _isLoading,
                    hasMore: _hasMore,
                    onLoadMore: _loadMore,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
