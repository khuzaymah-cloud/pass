// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => '1Pass';

  @override
  String get tagline => 'اشتراك واحد. كل الأندية.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get sendOtp => 'إرسال رمز التحقق';

  @override
  String get verifyOtp => 'تأكيد الرمز';

  @override
  String get enterPhone => 'أدخل رقم هاتفك';

  @override
  String get enterOtp => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get debugOtpHint => 'وضع التطوير — استخدم 123456';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String get register => 'أكمل ملفك الشخصي';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get email => 'البريد الإلكتروني (اختياري)';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get birthday => 'تاريخ الميلاد';

  @override
  String get save => 'حفظ';

  @override
  String get home => 'الرئيسية';

  @override
  String hey(String name) {
    return 'مرحباً $name';
  }

  @override
  String visitsRemaining(int count) {
    return '$count زيارة متبقية';
  }

  @override
  String daysRemaining(int count) {
    return '$count يوم متبقي';
  }

  @override
  String get checkIn => 'تسجيل الدخول';

  @override
  String get findGym => 'ابحث عن نادي';

  @override
  String get renewPlan => 'تجديد الخطة';

  @override
  String get nearbyGyms => 'أندية قريبة';

  @override
  String get gyms => 'الأندية';

  @override
  String get gymMap => 'خريطة الأندية';

  @override
  String get gymDetail => 'تفاصيل النادي';

  @override
  String get openingHours => 'ساعات العمل';

  @override
  String get amenities => 'المرافق';

  @override
  String get checkInHere => 'سجل دخولك هنا';

  @override
  String get tierLocked => 'خطتك لا تشمل هذه الفئة';

  @override
  String get upgradePlan => 'ترقية الخطة';

  @override
  String get plans => 'الخطط';

  @override
  String get recommended => 'موصى بها';

  @override
  String get perMonth => '/شهرياً';

  @override
  String get visits30 => '30 زيارة';

  @override
  String get days30 => '30 يوم';

  @override
  String get subscribe => 'اشترك';

  @override
  String get payment => 'الدفع';

  @override
  String get simulatePayment => 'محاكاة الدفع';

  @override
  String get paymentComingSoon => 'تكامل الدفع قريباً';

  @override
  String get success => 'نجاح!';

  @override
  String get youreAllSet => 'أنت جاهز!';

  @override
  String get mySubscription => 'اشتراكي';

  @override
  String get active => 'فعّال';

  @override
  String get expired => 'منتهي';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String walletBalance(String balance, String currency) {
    return '$balance $currency متبقية في المحفظة';
  }

  @override
  String get checkinHistory => 'سجل الزيارات';

  @override
  String get qrCheckin => 'تسجيل دخول QR';

  @override
  String get scanAtGym => 'أظهر رمز QR في النادي';

  @override
  String get subscriptionExpired => 'انتهى اشتراكك';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String memberSince(String date) {
    return 'عضو منذ $date';
  }

  @override
  String get totalCheckins => 'إجمالي الزيارات';

  @override
  String get gymsVisited => 'الأندية المُزارة';

  @override
  String get editProfile => 'تعديل الملف';

  @override
  String get mySubscriptionMenu => 'اشتراكي';

  @override
  String get help => 'المساعدة والدعم';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get country => 'الدولة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get version => 'الإصدار';

  @override
  String get noActiveSubscription => 'لا يوجد اشتراك فعّال';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';
}
