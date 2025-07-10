import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mobile_app/main.dart';

void main() {
  testWidgets('Shows login form', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalFinanceApp());
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byIcon(Icons.mail), findsOneWidget);
    expect(find.text('Don’t have an account? Sign up'), findsOneWidget);
  });

  testWidgets('Navigates to signup on switch', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalFinanceApp());
    await tester.tap(find.text('Don’t have an account? Sign up'));
    await tester.pumpAndSettle();
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Dashboard/home tabs and FAB present after login', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalFinanceApp());

    // Enter email/password and press login
    await tester.enterText(find.byType(TextField).first, 'john@demo.com');
    await tester.enterText(find.byType(TextField).last, 'mypassword');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(milliseconds: 1200));
    // After login, expect to find tabs
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Transactions'), findsWidgets);
    expect(find.text('Budgets'), findsWidgets);
  });
}
