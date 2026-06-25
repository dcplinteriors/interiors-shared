import 'package:dcpl_shared/dcpl_shared.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the dark-mode status palette. (The full `AppTheme.light` /
/// `AppTheme.dark` ThemeData pull fonts from google_fonts, which can't load in
/// the test sandbox — theme switching itself is exercised by running the apps,
/// which wire both themes via `themeMode`.)
void main() {
  test(
    'light and dark status palettes are distinct, dark uses brighter ink',
    () {
      final light = StatusColors.standard;
      final dark = StatusColors.dark;

      // Every semantic slot differs between the two variants.
      for (final pair in <(StatusColor, StatusColor)>[
        (light.requested, dark.requested),
        (light.processing, dark.processing),
        (light.accepted, dark.accepted),
        (light.closed, dark.closed),
        (light.declined, dark.declined),
        (light.cancelled, dark.cancelled),
        (light.active, dark.active),
        (light.completed, dark.completed),
        (light.warning, dark.warning),
        (light.neutral, dark.neutral),
      ]) {
        expect(pair.$1.surface, isNot(pair.$2.surface));
        expect(pair.$1.ink, isNot(pair.$2.ink));
      }
    },
  );

  test(
    'dark status fills are dark and ink is light (rail/chip legibility)',
    () {
      // The rail/chip ink must be lighter than its fill on dark surfaces.
      for (final s in [
        StatusColors.dark.requested,
        StatusColors.dark.processing,
        StatusColors.dark.accepted,
        StatusColors.dark.closed,
        StatusColors.dark.declined,
        StatusColors.dark.cancelled,
        StatusColors.dark.warning,
        StatusColors.dark.neutral,
      ]) {
        expect(
          s.ink.computeLuminance(),
          greaterThan(s.surface.computeLuminance()),
          reason: 'dark status ink should be lighter than its fill',
        );
      }
    },
  );

  test('forRequest maps every material-request status (unknown → neutral)', () {
    final s = StatusColors.standard;
    expect(s.forRequest(MaterialRequestStatus.requested.wire), s.requested);
    expect(s.forRequest(MaterialRequestStatus.processing.wire), s.processing);
    expect(s.forRequest(MaterialRequestStatus.accepted.wire), s.accepted);
    expect(s.forRequest(MaterialRequestStatus.closed.wire), s.closed);
    expect(s.forRequest(MaterialRequestStatus.declined.wire), s.declined);
    expect(s.forRequest(MaterialRequestStatus.cancelled.wire), s.cancelled);
    expect(s.forRequest('bogus'), s.neutral);
  });

  test('forWorkOrder maps every work-order status', () {
    final s = StatusColors.standard;
    expect(s.forWorkOrder(WorkOrderStatus.pending.wire), s.warning);
    expect(s.forWorkOrder(WorkOrderStatus.active.wire), s.active);
    expect(s.forWorkOrder(WorkOrderStatus.completed.wire), s.completed);
    expect(s.forWorkOrder(WorkOrderStatus.cancelled.wire), s.cancelled);
  });

  test('status enums parse wire values and classify open/terminal', () {
    expect(
      MaterialRequestStatus.fromWire('processing'),
      MaterialRequestStatus.processing,
    );
    expect(MaterialRequestStatus.requested.isOpen, isTrue);
    expect(MaterialRequestStatus.accepted.isOpen, isTrue);
    expect(MaterialRequestStatus.closed.isTerminal, isTrue);
    expect(WorkOrderStatus.completed.isTerminal, isTrue);
    expect(WorkOrderStatus.pending.isTerminal, isFalse);
  });
}
