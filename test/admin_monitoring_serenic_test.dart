// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/dashboard/monitoring_serenic.dart';
import 'package:req_rsab/admin/sidebar.dart';

void main() {
  testWidgets('Monitoring Serenic adapts its content to the selected tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MonitoringSerenicPage()));
    await tester.pumpAndSettle();

    expect(find.text('Monitoring Serenic'), findsOneWidget);
    expect(find.text('Kirim prerequisites'), findsOneWidget);
    expect(find.text('Tanggal awal'), findsOneWidget);
    expect(find.text('Tampilkan'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Nama Service'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    for (final header in [
      'Nama Service',
      'Tanggal Kirim',
      'Jumlah Data Dikirim',
      'Total Error',
      'Total Unknown',
      'Total Success',
      'Detail',
    ]) {
      expect(find.text(header), findsOneWidget);
    }
    expect(find.text('Belum ada data pengiriman'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encounter Belum Terkirim').first);
    await tester.pumpAndSettle();

    expect(find.text('Cek Data'), findsOneWidget);
    expect(find.text('Kirim Encounter Terpilih'), findsOneWidget);
    expect(find.text('0 registrasi dipilih'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Tanggal Registrasi'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    for (final header in [
      'Tanggal Registrasi',
      'No. Registrasi',
      'No. Rekam',
      'Kelompok Pasien',
      'No. SEP',
      'Status',
      'Aksi',
    ]) {
      expect(find.text(header), findsOneWidget);
    }

    await tester.scrollUntilVisible(
      find.text('Belum ada encounter tertunda'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Belum ada encounter tertunda'), findsOneWidget);
    expect(find.text('Kirim prerequisites'), findsNothing);
  });

  testWidgets('Monitoring Serenic can be opened from the admin sidebar', (
    tester,
  ) async {
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
    await tester.tap(find.text('Monitoring Serenic'));
    await tester.pumpAndSettle();

    expect(find.text('Monitoring Serenic'), findsOneWidget);
    expect(find.text('Aksi Pengiriman'), findsOneWidget);
    expect(find.text('Filter Periode'), findsOneWidget);
  });
}
