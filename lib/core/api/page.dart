/// A cursor-paginated response: a slice of [items] plus the [nextCursor] to request the next
/// page (`null` on the last page). Mirrors the backend `{ items, nextCursor }` envelope.
class Page<T> {
  const Page({required this.items, this.nextCursor});

  factory Page.fromJson(dynamic json, T Function(Map<String, dynamic>) parse) {
    final map = json as Map<String, dynamic>;
    return Page(
      // An immutable snapshot — list controllers copy it into their own RxList via
      // assignAll, so the page itself never needs to be mutable.
      items: (map['items'] as List)
          .map((e) => parse(e as Map<String, dynamic>))
          .toList(growable: false),
      nextCursor: map['nextCursor'] as String?,
    );
  }

  final List<T> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}
