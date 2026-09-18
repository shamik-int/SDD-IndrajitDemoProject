import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/app/routes/app_routes.dart';
import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';
import 'package:employee_transfer_project/domain/entities/login_input.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/usecases/login_employee.dart';
import 'package:employee_transfer_project/presentation/controllers/login_controller.dart';
import 'package:employee_transfer_project/presentation/pages/login_page.dart';

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

class FakeLoginInput extends Fake implements LoginInput {}

EmployeeAccount _account() {
  return EmployeeAccount(
    email: 'person@intglobal.com',
    name: 'Person One',
    currentDepartmentId: 'dept-eng',
    currentLocationId: 'loc-blr',
    currentRoleId: 'role-swe',
    registeredAt: DateTime(2026, 9, 18),
  );
}

void main() {
  late MockEmployeeAccountRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeLoginInput());
  });

  setUp(() {
    Get.testMode = true;
    repository = MockEmployeeAccountRepository();
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    Get.put<LoginController>(LoginController(loginEmployee: LoginEmployee(repository)));
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.login,
        getPages: [
          GetPage(name: AppRoutes.login, page: () => const LoginPage()),
          GetPage(name: AppRoutes.register, page: () => const Scaffold(body: Text('REGISTER'))),
          GetPage(name: AppRoutes.placeholder, page: () => const Scaffold(body: Text('ENTRY'))),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders email and password fields and a Log In button', (tester) async {
    await pumpPage(tester);

    expect(find.byKey(const Key('login-email-field')), findsOneWidget);
    expect(find.byKey(const Key('login-password-field')), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
  });

  testWidgets('AC7: shows the generic invalid-credentials error and does not navigate', (
    tester,
  ) async {
    when(
      () => repository.login(any()),
    ).thenAnswer((_) async => Result.error('Invalid email or password.'));

    await pumpPage(tester);

    await tester.enterText(find.byKey(const Key('login-email-field')), 'nobody@intglobal.com');
    await tester.enterText(find.byKey(const Key('login-password-field')), 'Password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password.'), findsOneWidget);
    expect(find.text('ENTRY'), findsNothing);
  });

  testWidgets('AC6: a successful login navigates to the entry route', (tester) async {
    when(() => repository.login(any())).thenAnswer((_) async => Result.success(_account()));

    await pumpPage(tester);

    await tester.enterText(find.byKey(const Key('login-email-field')), 'person@intglobal.com');
    await tester.enterText(find.byKey(const Key('login-password-field')), 'Password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('ENTRY'), findsOneWidget);
  });

  testWidgets('tapping the Register link navigates to the Register screen', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('REGISTER'), findsOneWidget);
  });
}
