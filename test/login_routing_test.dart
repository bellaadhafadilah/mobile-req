// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/dashboard/dashboard_komplain.dart';
import 'package:req_rsab/auth/login.dart';
import 'package:req_rsab/screens/home_page.dart';

Future<void> _submitLogin(
  WidgetTester tester, {
  required String username,
  required String password,
}) async {
  await tester.pumpWidget(const MaterialApp(home: LoginPage()));
  await tester.enterText(find.byType(TextFormField).at(0), username);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Masuk ke Akun'));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('admin credentials open admin dashboard', (tester) async {
    await _submitLogin(tester, username: 'test', password: '123456789');

    expect(find.byType(AdminDashboardPage), findsOneWidget);
  });

  testWidgets('other credentials continue to HomePage', (tester) async {
    await _submitLogin(
      tester,
      username: 'unit lain',
      password: 'password-lain',
    );

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets(
    'login adapts to mobile and keeps password visibility interactive',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      final passwordFinder = find.byType(TextFormField).at(1);
      final editablePassword = find.descendant(
        of: passwordFinder,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(editablePassword).obscureText, isTrue);

      await tester.tap(find.byTooltip('Tampilkan password'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(editablePassword).obscureText,
        isFalse,
      );
    },
  );

  testWidgets('wide login layout renders without overflow', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(tester.takeException(), isNull);
  });
}
