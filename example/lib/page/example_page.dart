import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scroll_preload_detector/scroll_preload_detector.dart';
import '../api/mock_api.dart';
import '../widget/scroll_debug_overlay.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
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
        isLoading: _isLoading,
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
                  child: _buildFooter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    if (_isLoading) {
      return const CupertinoActivityIndicator();
    }
    if (!_hasMore) {
      return const Text('No more data');
    }
    return ElevatedButton(
      onPressed: _loadMore,
      child: const Text('Load More'),
    );
  }
}
