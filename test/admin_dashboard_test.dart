// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/dashboard/dashboard_komplain.dart';
import 'package:req_rsab/services/api_service.dart';

void main() {
  testWidgets('admin dashboard shows API statistics and hamburger menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AdminDashboardPage(
          loadDashboard: ({tanggalAwal, tanggalAkhir}) async {
            expect(tanggalAwal, isNotNull);
            expect(tanggalAkhir, isNotNull);
            return const DashboardData(
              raw: {
                'summary': {
                  'dibuat': 3,
                  'proses': 2,
                  'pending': 1,
                  'menunggu_ulasan': 4,
                  'selesai': 5,
                  'total': 15,
                },
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Komplain'), findsOneWidget);
    expect(find.text('Menunggu ulasan'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    expect(find.text('Nama Teknisi'), findsOneWidget);
    expect(find.text('Total Selesai'), findsOneWidget);
    expect(find.text('Rating Rata-rata'), findsOneWidget);
    expect(find.text('Jumlah Ulasan'), findsOneWidget);
    expect(find.text('Proses < 15 Menit'), findsOneWidget);
    expect(find.text('Proses ≥ 15 Menit'), findsOneWidget);
    expect(find.text('Selesai < 30 Menit'), findsOneWidget);
    expect(find.text('Selesai ≥ 30 Menit'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Ranking Teknisi Bulanan'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Rank'), findsOneWidget);
    expect(find.text('Nama Teknisi'), findsNWidgets(2));
    expect(find.text('Total Selesai'), findsNWidgets(2));
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Persentase'), findsOneWidget);
    expect(find.text('Capaian'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Dashboard Komplain'), findsNWidgets(2));
    expect(find.text('List Permintaan'), findsOneWidget);
    expect(find.text('Monitoring Smart'), findsOneWidget);
    expect(find.text('Monitoring Serenic'), findsOneWidget);
    expect(find.text('Laporan Komplain'), findsOneWidget);
    expect(find.text('Master'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
    expect(find.text('Aplikasi SIMRS'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);

    await tester.tap(find.text('Master'));
    await tester.pumpAndSettle();
    expect(find.text('User'), findsNothing);

    await tester.tap(find.text('Master'));
    await tester.pumpAndSettle();
    expect(find.text('User'), findsOneWidget);

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('List Permintaan'), findsNothing);

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('List Permintaan'), findsOneWidget);
  });
}
