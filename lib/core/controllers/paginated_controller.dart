import 'package:dcpl_shared/core/api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Base for list controllers backed by a cursor-paginated endpoint.
///
/// Owns the loading/error/cursor state and the `fetch`/`loadMore` flow — including a
/// generation guard so a refresh (or filter change) supersedes an in-flight `loadMore`.
/// Subclasses provide [items] (their named reactive list) and [fetchPage] (which reads
/// the subclass's current filters); a filter change just calls [fetch] again.
abstract class PaginatedController<T> extends GetxController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();

  final _nextCursor = RxnString();
  bool get hasMore => _nextCursor.value != null;

  /// Bumped on every [fetch] (first page). A [loadMore] captures the current value and
  /// discards its result if a fetch superseded it meanwhile.
  int _generation = 0;

  /// The reactive list this controller fills — the subclass's named `.obs` list.
  RxList<T> get items;

  /// Loads one page, continuing after [cursor] (null = first page), applying whatever
  /// filters the subclass currently holds.
  Future<Page<T>> fetchPage({String? cursor});

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  /// Loads the first page, replacing the list.
  Future<void> fetch() async {
    final gen = ++_generation;
    isLoading.value = true;
    error.value = null;
    try {
      final page = await fetchPage();
      if (gen != _generation) return; // superseded by a newer fetch
      // assignAll (not `.value =`) so the RxList keeps its own growable backing list —
      // subclasses then insert/removeAt freely regardless of the page list's mutability.
      items.assignAll(page.items);
      _nextCursor.value = page.nextCursor;
    } on ApiException catch (e) {
      if (gen == _generation) error.value = e.message;
    } finally {
      if (gen == _generation) isLoading.value = false;
    }
  }

  /// Appends the next page. No-op if already loading or there's nothing more.
  Future<void> loadMore() async {
    if (isLoadingMore.value || _nextCursor.value == null) return;
    final gen = _generation; // a fetch() would bump this and invalidate us
    isLoadingMore.value = true;
    try {
      final page = await fetchPage(cursor: _nextCursor.value);
      if (gen != _generation) return; // a refresh superseded this load
      items.addAll(page.items);
      _nextCursor.value = page.nextCursor;
    } on ApiException catch (e) {
      if (gen == _generation) error.value = e.message;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Invalidates any in-flight [fetch]/[loadMore] so a late response can't clobber a local
  /// optimistic mutation (e.g. inserting a just-submitted item, or removing a cancelled one).
  /// Call this right before applying the mutation. Also clears [isLoading] — the superseded
  /// fetch's `finally` is generation-guarded and won't reset it.
  @protected
  void invalidateInFlightLoads() {
    _generation++;
    isLoading.value = false;
  }
}
