import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scroll_preload_detector/scroll_preload_detector.dart';

import '../viewmodel/sliver_example_viewmodel.dart';
import '../widget/grid_item_card.dart';
import '../widget/horizontal_item_card.dart';
import '../widget/list_footer.dart';
import '../widget/list_item_tile.dart';
import '../widget/scroll_debug_overlay.dart';
import '../widget/section_header.dart';

/// A complex example page demonstrating SliverPreloadTrigger with multiple
/// independent data sources in a single CustomScrollView.
class SliverExamplePage extends StatefulWidget {
  const SliverExamplePage({super.key});

  @override
  State<SliverExamplePage> createState() => _SliverExamplePageState();
}

class _SliverExamplePageState extends State<SliverExamplePage> {
  final RecommendViewModel _recommendVM = RecommendViewModel();
  final HotViewModel _hotVM = HotViewModel();
  final AllViewModel _allVM = AllViewModel();

  @override
  void initState() {
    super.initState();
    _recommendVM.addListener(_onViewModelChanged);
    _hotVM.addListener(_onViewModelChanged);
    _allVM.addListener(_onViewModelChanged);

    // Initial load
    _recommendVM.loadMore();
    _hotVM.loadMore();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _recommendVM.removeListener(_onViewModelChanged);
    _hotVM.removeListener(_onViewModelChanged);
    _allVM.removeListener(_onViewModelChanged);
    _recommendVM.dispose();
    _hotVM.dispose();
    _allVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sliver Preload Trigger'),
      ),
      body: ScrollDebugOverlay(
        loadingStates: {
          'Recommend': _recommendVM.isLoading,
          'Hot': _hotVM.isLoading,
          'All': _allVM.isLoading,
        },
        child: CustomScrollView(
          slivers: [
            // ===== Recommend Section (Horizontal List) =====
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Recommend'),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: _buildRecommendList(),
              ),
            ),

            // ===== Hot Section (Grid) =====
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Hot'),
            ),
            _buildHotGrid(),
            if (_hotVM.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CupertinoActivityIndicator()),
                ),
              ),
            SliverPreloadTrigger(
              preload: _hotVM.loadMore,
              hasMore: () => _hotVM.hasMore,
              preloadDistance: 300,
            ),
            // ===== All Section (Vertical List) - Only shown when Hot is complete =====
            if (!_hotVM.hasMore) ...[
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'All'),
              ),
              _buildAllList(),
              SliverPreloadTrigger(
                preload: _allVM.loadMore,
                hasMore: () => _allVM.hasMore,
                preloadDistance: 600,
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: ListFooter(
                    isLoading: _allVM.isLoading,
                    hasMore: _allVM.hasMore,
                    onLoadMore: _allVM.loadMore,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendList() {
    return CustomScrollView(
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: _recommendVM.items.length + (_recommendVM.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _recommendVM.items.length) {
                return const SizedBox(
                  width: 60,
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }
              return HorizontalItemCard(title: _recommendVM.items[index]);
            },
          ),
        ),
        SliverPreloadTrigger(
          preload: _recommendVM.loadMore,
          hasMore: () => _recommendVM.hasMore,
          preloadDistance: 300,
        ),
      ],
    );
  }

  Widget _buildHotGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return GridItemCard(
              title: _hotVM.items[index],
              index: index,
            );
          },
          childCount: _hotVM.items.length,
        ),
      ),
    );
  }

  Widget _buildAllList() {
    return SliverList.separated(
      itemCount: _allVM.items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListItemTile(
          title: _allVM.items[index],
          index: index,
        );
      },
    );
  }
}
