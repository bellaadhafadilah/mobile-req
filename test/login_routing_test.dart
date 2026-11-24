// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/dashboard/dashboard_komplain.dart';
import 'package:req_rsab/auth/login.dart';
import 'package:req_rsab/screens/home_page.dart';
import 'package:req_rsab/services/api_service.dart';

Future<void> _submitLogin(
  WidgetTester tester, {
  required String username,
  required String password,
  required bool isTechnician,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: LoginPage(loginAction: (_, _) async => isTechnician)),
  );
  await tester.enterText(find.byType(TextFormField).at(0), username);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Masuk ke Akun'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('admin credentials open admin dashboard', (tester) async {
    await _submitLogin(
      tester,
      username: 'admin-user',
      password: 'password',
      isTechnician: true,
    );

    expect(find.byType(AdminDashboardPage), findsOneWidget);
  });

  testWidgets('debug test account opens admin without calling the API', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.enterText(find.byType(TextFormField).at(0), 'test');
    await tester.enterText(find.byType(TextFormField).at(1), '123456789');
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminDashboardPage), findsOneWidget);
  });

  testWidgets('other debug credentials open HomePage without the API', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.enterText(find.byType(TextFormField).at(0), 'other-user');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('other credentials continue to HomePage', (tester) async {
    await _submitLogin(
      tester,
      username: 'regular-user',
      password: 'password',
      isTechnician: false,
    );

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('failed backend login stays on LoginPage', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          loginAction: (_, _) async =>
              throw const ApiException(401, 'Username atau password salah.'),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'unknown');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    expect(find.text('Username atau password salah.'), findsOneWidget);
    expect(find.byType(AdminDashboardPage), findsNothing);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('users can continue without an internal account', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    final continueButton = find.byKey(const ValueKey('continue-as-user'));
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

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
