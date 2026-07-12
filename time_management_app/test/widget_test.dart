import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_management_app/main.dart';
import 'package:time_management_app/services/api_service.dart';
import 'package:time_management_app/services/auth_service.dart';

import 'package:time_management_app/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await Get.putAsync<AuthService>(() => AuthService().init());
    await Get.putAsync<ApiService>(() => ApiService().init());
    await Get.putAsync<NotificationService>(() => NotificationService().init());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App khởi động với splash screen TimeWise', (WidgetTester tester) async {
    await tester.pumpWidget(const TimeWiseApp());
    await tester.pump();

    expect(find.text('TimeWise'), findsOneWidget);
    expect(tester.widget<GetMaterialApp>(find.byType(GetMaterialApp)).title,
        'TimeWise');

    // Hoàn tất timer splash để test kết thúc sạch
    await tester.pump(const Duration(seconds: 3));
  });
}
