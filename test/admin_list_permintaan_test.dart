// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/dashboard/list_permintaan.dart';
import 'package:req_rsab/services/api_service.dart';

void main() {
  testWidgets('ticket list filters tabs and shows requested table columns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final loadedTypes = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: ListPermintaanPage(
          loadTickets:
              ({required isComplaint, tanggalAwal, tanggalAkhir}) async {
                loadedTypes.add(isComplaint);
                return [
                  {
                    'ticket_no': 'TIK-001',
                    'pic_internal': 'Test User',
                    'unit_kerja_internal': 'Instalasi IT',
                    'permintaan': 'Hardware',
                    'kerusakan': 'Monitor',
                    'extension': '123',
                    'teknisi': 'Teknisi 1',
                    'keterangan': 'Layar tidak menyala',
                    'status': 'Dibuat',
                    'created_at': '2026-11-20T08:30:00',
                  },
                  {'ticket_no': 'TIK-002', 'status': 'Proses'},
                  {'ticket_no': 'TIK-003', 'status': 'Selesai'},
                ];
              },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadedTypes, [true]);
    expect(find.text('List Permintaan'), findsOneWidget);
    expect(find.text('Komplain'), findsOneWidget);
    expect(find.text('Permintaan'), findsNWidgets(2));
    expect(find.text('Nomor Tiket'), findsOneWidget);
    expect(find.text('Nama Pengusul'), findsOneWidget);
    expect(find.text('Tanggal dan Waktu Dibuat'), findsOneWidget);
    expect(find.text('TIK-001'), findsOneWidget);

    await tester.tap(find.text('Proses'));
    await tester.pumpAndSettle();
    expect(find.text('TIK-002'), findsOneWidget);
    expect(find.text('TIK-001'), findsNothing);

    await tester.tap(find.text('Permintaan').first);
    await tester.pumpAndSettle();
    expect(loadedTypes, [true, false]);
    expect(find.text('TIK-002'), findsOneWidget);
    expect(find.text('Unit Kerja'), findsOneWidget);
    expect(find.text('Ruangan'), findsNothing);
    expect(find.text('Kerusakan'), findsNothing);
    expect(find.text('Tanggal'), findsOneWidget);
    expect(find.text('Tanggal Awal'), findsNothing);
    expect(find.text('Tanggal Akhir'), findsNothing);
  });

  testWidgets('request table headers remain visible when endpoint fails', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ListPermintaanPage(
          loadTickets: ({required isComplaint, tanggalAwal, tanggalAkhir}) {
            if (!isComplaint) {
              return Future.error(
                const ApiException(405, 'Method not allowed for endpoint'),
              );
            }
            return Future.value(const []);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Permintaan').first);
    await tester.pumpAndSettle();

    expect(find.text('Nomor Tiket'), findsOneWidget);
    expect(find.text('Nama Pengusul'), findsOneWidget);
    expect(find.text('Unit Kerja'), findsOneWidget);
    expect(find.text('Tanggal dan Waktu Dibuat'), findsOneWidget);
    expect(
      find.text('Endpoint daftar permintaan belum tersedia di server.'),
      findsOneWidget,
    );
    expect(find.text('Method not allowed for endpoint'), findsNothing);

    await tester.tap(find.text('Detail error server'));
    await tester.pumpAndSettle();
    expect(find.text('Method not allowed for endpoint'), findsOneWidget);
  });
}
