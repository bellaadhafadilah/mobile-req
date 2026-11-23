// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/dashboard/dashboard_komplain.dart';
import 'package:req_rsab/admin/master/user.dart';
import 'package:req_rsab/services/api_service.dart';

void main() {
  testWidgets('user list shows reference columns and adds a searchable user', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminUserPage()));
    await tester.pumpAndSettle();

    expect(find.text('List User'), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('email'), findsOneWidget);
    expect(find.text('Unit kerja'), findsOneWidget);

    await tester.tap(find.text('Tambah').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Nadia Pratama');
    await tester.enterText(find.byType(TextFormField).at(1), 'nadia.p');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'nadia@example.org',
    );
    await tester.enterText(find.byType(TextFormField).at(3), 'Instalasi IT');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Nadia Pratama'), findsOneWidget);
    expect(find.text('nadia.p'), findsOneWidget);
    expect(find.text('nadia@example.org'), findsOneWidget);
    expect(find.text('Instalasi IT'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('user-search')),
      'Instalasi IT',
    );
    await tester.pumpAndSettle();
    expect(find.text('Nadia Pratama'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('user-search')),
      'tidak ditemukan',
    );
    await tester.pumpAndSettle();
    expect(find.text('Nadia Pratama'), findsNothing);
    expect(
      find.text('Tidak ada user yang cocok dengan pencarian.'),
      findsOneWidget,
    );
  });

  testWidgets('Master User menu opens the user list page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminDashboardPage(
          loadDashboard: ({tanggalAwal, tanggalAkhir}) async =>
              const DashboardData(raw: {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('User'),
      180,
      scrollable: find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('User'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminUserPage), findsOneWidget);
    expect(find.text('List User'), findsOneWidget);
  });
}
