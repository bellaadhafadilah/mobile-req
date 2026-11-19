import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/cek_status/form.dart';
import 'package:req_rsab/req_komplain/form.dart';
import 'package:req_rsab/req_permintaan/form.dart';
import 'package:req_rsab/dashboard_req/index.dart';
import 'package:req_rsab/auth/login.dart';

void main() {
  testWidgets('CekStatusPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CekStatusPage(),
      ),
    );

    expect(find.text('Cek Status Permintaan'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('KomplainFormPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KomplainFormPage(),
      ),
    );

    expect(find.text('Form Komplain IT'), findsOneWidget);
    expect(find.text('Hardware'), findsOneWidget);
    expect(find.text('Jaringan'), findsOneWidget);
    expect(find.text('Software'), findsOneWidget);
    expect(find.text('Sistem Aplikasi'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
  });

  testWidgets('RequestFormPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RequestFormPage(),
      ),
    );

    expect(find.text('Form Permintaan Layanan IT'), findsOneWidget);
    expect(find.text('Captcha'), findsOneWidget);
    expect(find.text('Masukkan captcha'), findsOneWidget);
    expect(find.text('Kirim Permintaan'), findsOneWidget);
  });

  testWidgets('DashboardReqPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardReqPage(),
      ),
    );

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
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    expect(find.text('Masuk ke Sistem'), findsOneWidget);
    expect(find.text('Nama Unit'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });
}
