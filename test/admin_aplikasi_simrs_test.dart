// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/master/aplikasi_simrs.dart';
import 'package:req_rsab/admin/sidebar.dart';

void main() {
  testWidgets('Aplikasi SIMRS shows its columns on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AplikasiSimrsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Aplikasi SIMRS'), findsOneWidget);
    expect(find.text('Tambah'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Nama'),
      240,
      scrollable: find.byType(Scrollable).first,
    );

    for (final header in [
      'Nama',
      'Url',
      'Keterangan',
      'gambar',
      'Juknis',
      '#',
    ]) {
      expect(find.text(header), findsOneWidget);
    }
    expect(find.text('Belum ada data aplikasi'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    expect(
      find.text('Fitur Tambah belum terhubung ke layanan SIMRS.'),
      findsOneWidget,
    );
  });

  testWidgets('Aplikasi SIMRS opens from its sidebar item', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: const AdminSidebar(),
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Aplikasi SIMRS'),
      180,
      scrollable: find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Aplikasi SIMRS'));
    await tester.pumpAndSettle();

    expect(find.byType(AplikasiSimrsPage), findsOneWidget);
    expect(find.text('Daftar Aplikasi'), findsOneWidget);
  });
}
