import 'base_list_viewmodel.dart';

/// ViewModel for the horizontal recommend section.
class RecommendViewModel extends BaseListViewModel<String> {
  RecommendViewModel() : super(pageSize: 9, maxItems: 18);

  @override
  List<String> convertItems(List<String> rawItems) {
    return rawItems.map((e) => 'Recommend $e').toList();
  }
}

/// ViewModel for the grid hot section.
class HotViewModel extends BaseListViewModel<String> {
  HotViewModel() : super(pageSize: 10, maxItems: 30);

  @override
  List<String> convertItems(List<String> rawItems) {
    return rawItems.map((e) => 'Hot $e').toList();
  }
}

/// ViewModel for the vertical all items section.
class AllViewModel extends BaseListViewModel<String> {
  AllViewModel() : super(pageSize: 20, maxItems: 40);

  @override
  List<String> convertItems(List<String> rawItems) {
    return rawItems.map((e) => 'All $e').toList();
  }
}
