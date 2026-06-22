import 'package:dcpl_shared/dcpl_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _items = [
  DcplNavItem(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Overview',
    section: 'Workspace',
  ),
  DcplNavItem(
    icon: Icons.inbox_outlined,
    selectedIcon: Icons.inbox,
    label: 'Requests',
    section: 'Inbox',
    badgeCount: 5,
  ),
];

Widget _host(Widget child, {Size size = const Size(1200, 800)}) => MediaQuery(
  data: MediaQueryData(size: size),
  child: MaterialApp(theme: AppTheme.dark, home: child),
);

void main() {
  testWidgets(
    'rail (expanded) shows labels, section headers, badge; taps select',
    (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => DcplNavScaffold(
              items: _items,
              selectedIndex: selected,
              onDestinationSelected: (i) => setState(() => selected = i),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('WORKSPACE'), findsOneWidget);
      expect(find.text('INBOX'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // badge

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    },
  );

  testWidgets('compact renders a bottom bar and routes selection', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      _host(
        size: const Size(400, 800),
        StatefulBuilder(
          builder: (context, setState) => DcplNavScaffold(
            items: _items,
            selectedIndex: selected,
            onDestinationSelected: (i) => setState(() => selected = i),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(find.byType(DcplBottomBar), findsOneWidget);
    expect(find.byType(DcplNavRail), findsNothing);
    expect(find.text('Requests'), findsOneWidget);

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(selected, 1);
  });

  testWidgets('ProfileAvatar shows initials and an edit badge when editable', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        Scaffold(
          body: Center(
            child: ProfileAvatar(initials: 'RB', onEdit: () => tapped = true),
          ),
        ),
      ),
    );

    expect(find.text('RB'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.photo_camera_rounded));
    expect(tapped, isTrue);
  });
}
