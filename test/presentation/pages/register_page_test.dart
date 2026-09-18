import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_transfer_project/app/routes/app_routes.dart';
import 'package:employee_transfer_project/core/result/result.dart';
import 'package:employee_transfer_project/domain/entities/employee_account.dart';
import 'package:employee_transfer_project/domain/entities/register_employee_input.dart';
import 'package:employee_transfer_project/domain/repositories/employee_account_repository.dart';
import 'package:employee_transfer_project/domain/usecases/register_employee.dart';
import 'package:employee_transfer_project/presentation/controllers/register_controller.dart';
import 'package:employee_transfer_project/presentation/pages/register_page.dart';

class MockEmployeeAccountRepository extends Mock
    implements EmployeeAccountRepository {}

class FakeRegisterEmployeeInput extends Fake implements RegisterEmployeeInput {}

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
    registerFallbackValue(FakeRegisterEmployeeInput());
  });

  setUp(() {
    Get.testMode = true;
    repository = MockEmployeeAccountRepository();
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    Get.put<RegisterController>(
      RegisterController(registerEmployee: RegisterEmployee(repository)),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.register,
        getPages: [
          GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
          GetPage(name: AppRoutes.login, page: () => const Scaffold(body: Text('LOGIN'))),
          GetPage(name: AppRoutes.placeholder, page: () => const Scaffold(body: Text('ENTRY'))),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders name/email/password fields, 3 dropdowns, and a Register button', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.byKey(const Key('register-name-field')), findsOneWidget);
    expect(find.byKey(const Key('register-email-field')), findsOneWidget);
    expect(find.byKey(const Key('register-password-field')), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
  });

  testWidgets('AC4: blocks submission and shows field errors when nothing is filled in', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required.'), findsOneWidget);
    verifyNever(() => repository.register(any()));
  });

  testWidgets('AC5: shows the duplicate-email error and does not navigate', (tester) async {
    when(() => repository.register(any())).thenAnswer(
      (_) async => Result.error('An account with this email already exists.'),
    );

    await pumpPage(tester);

    await tester.enterText(find.byKey(const Key('register-name-field')), 'Person One');
    await tester.enterText(
      find.byKey(const Key('register-email-field')),
      'person@intglobal.com',
    );
    await tester.enterText(find.byKey(const Key('register-password-field')), 'Password123');
    Get.find<RegisterController>()
      ..setDepartment('dept-eng')
      ..setLocation('loc-blr')
      ..setRole('role-swe');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('An account with this email already exists.'), findsOneWidget);
    expect(find.text('ENTRY'), findsNothing);
  });

  testWidgets('AC3: a successful registration navigates to the entry route', (tester) async {
    when(() => repository.register(any())).thenAnswer((_) async => Result.success(_account()));

    await pumpPage(tester);

    await tester.enterText(find.byKey(const Key('register-name-field')), 'Person One');
    await tester.enterText(
      find.byKey(const Key('register-email-field')),
      'person@intglobal.com',
    );
    await tester.enterText(find.byKey(const Key('register-password-field')), 'Password123');
    Get.find<RegisterController>()
      ..setDepartment('dept-eng')
      ..setLocation('loc-blr')
      ..setRole('role-swe');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('ENTRY'), findsOneWidget);
  });

  testWidgets('tapping the Log In link navigates to the Login screen', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });
}
