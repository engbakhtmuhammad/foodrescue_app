import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:foodrescue_app/views/onboarding/IntroScreen.dart';
import 'package:foodrescue_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Utils/language_translate.dart';
import 'api/Data_save.dart';
import 'config/app_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/reservation_controller.dart';
import 'controllers/payment_controller.dart';
import 'controllers/favourites_controller.dart';
import 'services/stripe_service.dart';
import 'services/razorpay_service.dart';
import 'services/error_handling_service.dart';
import 'services/notification_service.dart';
import 'services/realtime_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  await GetStorage.init();

  // Initialize services
  try {
    // Initialize error handling
    await ErrorHandlingService.initialize();

    // Initialize payment services
    await StripeService.init();
    RazorPayService.init();

    // Initialize notifications
    await NotificationService.initializeFCM();

  } catch (e) {
    debugPrint('Services initialization failed: $e');
  }

  // Initialize controllers
  Get.put(AuthController());
  Get.put(HomeController());
  Get.put(ReservationController());
  Get.put(PaymentController());
  Get.put(FavouritesController());

  initPlatformState();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorNotifier())],
      child: GetMaterialApp(
        translations: LocaleString(),
        locale: getData.read("lan2") != null
            ? Locale(getData.read("lan2"), getData.read("lan1"))
            : const Locale('en_US', 'en_US'),
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          dividerColor: Colors.transparent,
          useMaterial3: true,
          textTheme: GoogleFonts.nunitoTextTheme(),
          fontFamily: GoogleFonts.nunito().fontFamily,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              textStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const onbording(),
      ),
    ),
  );
}
// Future<void> initPlatformState() async {
//   OneSignal.shared.setAppId(AppUrl.oneSignel);
//   OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {});
//   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//     print("Accepted OSPermissionStateChanges : $changes");
//   });
//
// }

Future<void> initPlatformState() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(AppConfig.oneSignalAppId);
  OneSignal.Notifications.requestPermission(true).then(
        (value) {
      // ignore: avoid_print
      print("Signal value:- $value");
    },
  );
}
