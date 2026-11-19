import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/cek_status/form.dart';
import 'package:req_rsab/req_komplain/form.dart';
import 'package:req_rsab/req_permintaan/form.dart';
import 'package:req_rsab/dashboard_req/index.dart';
import 'package:req_rsab/auth/login.dart';
import 'package:req_rsab/services/api_service.dart';

void main() {
  test('FormOptions extracts unit names from API objects', () {
    final options = FormOptions(
      raw: {
        'units': [
          {'name': 'Instalasi Farmasi'},
          {'name': ' Komite Mutu '},
          {'name': null},
        ],
      },
    );

    expect(options.units, ['Instalasi Farmasi', 'Komite Mutu']);
  });

  testWidgets('CekStatusPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CekStatusPage()));

    expect(find.text('Cek Status Tiket'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('Kembali'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('KomplainFormPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: KomplainFormPage()));

    expect(find.text('Form Komplain IT'), findsOneWidget);
    expect(find.text('Hardware'), findsOneWidget);
    expect(find.text('Jaringan'), findsOneWidget);
    expect(find.text('Software'), findsOneWidget);
    expect(find.text('Sistem Aplikasi'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
  });

  testWidgets('KomplainFormPage shows fields for selected reporter type', (
    WidgetTester tester,
  ) async {
    Finder label(String text) => find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().contains(text),
    );

    await tester.pumpWidget(const MaterialApp(home: KomplainFormPage()));

    expect(label('Unit Kerja'), findsOneWidget);
    expect(label('Ruangan'), findsOneWidget);
    expect(label('Nama Pelapor'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is Radio<String> && widget.value == 'External',
      ),
    );
    await tester.pumpAndSettle();

    expect(label('Unit Kerja'), findsNothing);
    expect(label('Ruangan'), findsOneWidget);
    expect(label('Nama Pelapor'), findsOneWidget);
    expect(label('Kategori Komplain'), findsOneWidget);
    expect(label('No Telepon'), findsOneWidget);
    expect(label('Extension'), findsOneWidget);
  });

  testWidgets('Komplain phone number input is limited to 13 digits', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: KomplainFormPage()));

    final phoneField = find.byKey(const ValueKey('complaint-phone'));
    await tester.ensureVisible(phoneField);
    await tester.enterText(phoneField, '123456789012345');
    await tester.pump();

    expect(
      tester.widget<TextFormField>(phoneField).controller!.text,
      '1234567890123',
    );
  });

  testWidgets('RequestFormPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RequestFormPage()));

    expect(find.text('Form Permintaan Layanan IT'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('Captcha'), findsOneWidget);
    expect(find.text('Masukkan captcha'), findsOneWidget);
    expect(find.text('Kirim Permintaan'), findsOneWidget);
  });

  testWidgets('DashboardReqPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardReqPage()));

    expect(find.text('Daftar Komplain IT'), findsWidgets);
    expect(find.byType(Image), findsWidgets);
    expect(find.text('Nama Pengusul'), findsWidgets);
    expect(find.text('Tanggal Awal'), findsOneWidget);
    expect(find.text('Tanggal Akhir'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
    expect(find.text('+ Buat Baru'), findsOneWidget);
    expect(find.text('Nomor Tiket'), findsOneWidget);
  });

  testWidgets('LoginPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Masuk ke Sistem'), findsOneWidget);
    expect(find.text('Nama Unit'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });
}
