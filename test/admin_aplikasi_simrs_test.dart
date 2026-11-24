// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/master/aplikasi_simrs.dart';
import 'package:req_rsab/admin/sidebar.dart';
import 'package:req_rsab/services/api_service.dart';

void main() {
  testWidgets('Aplikasi SIMRS shows its columns on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AplikasiSimrsPage(
          loadApplications: () async =>
              const AplikasiSimrsListResult(items: [], meta: {}),
        ),
      ),
    );
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
      find.text('API mobile saat ini hanya mendukung membaca daftar aplikasi.'),
      findsOneWidget,
    );
  });

  testWidgets('Aplikasi SIMRS renders records from its loader', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AplikasiSimrsPage(
          loadApplications: () async => const AplikasiSimrsListResult(
            items: [
              {
                'id': 12,
                'nama_aplikasi': 'SIMRS Pendaftaran',
                'url': 'https://simrs.example.test',
                'image_url': null,
                'file_juknis_url': null,
              },
            ],
            meta: {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('SIMRS Pendaftaran'),
      240,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('SIMRS Pendaftaran'), findsOneWidget);
    expect(find.text('https://simrs.example.test'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(3));
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
          drawer: AdminSidebar(
            loadAplikasiSimrs: () async =>
                const AplikasiSimrsListResult(items: [], meta: {}),
          ),
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
