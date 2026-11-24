// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:req_rsab/admin/dashboard/dashboard_komplain.dart';
import 'package:req_rsab/auth/login.dart';
import 'package:req_rsab/services/api_service.dart';

void main() {
  testWidgets('sidebar asks before logging out and can cancel', (tester) async {
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

    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Konfirmasi Keluar'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(AdminDashboardPage), findsOneWidget);

    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-logout')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(AdminDashboardPage), findsNothing);
  });
}
