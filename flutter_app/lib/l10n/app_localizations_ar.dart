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
  String get tagline => 'اشتراك واحد، العب في أي مكان.';

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
  String visitsRemainingOf(int remaining, int max) {
    return '$remaining زيارة متبقية من أصل $max';
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
  String get profile => 'الحساب';

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

  @override
  String get locationAmmanJordan => 'عمّان, الأردن';

  @override
  String get subscribeNow1Pass => 'اشترك الآن في 1Pass';

  @override
  String get oneSubAnyGym => 'اشتراك واحد، ادخل أي نادي في الشبكة';

  @override
  String get subscribeNow => 'اشترك الآن';

  @override
  String get categories => 'الفئات';

  @override
  String get categoryGyms => 'صالات رياضية';

  @override
  String get categoryMartialArts => 'فنون قتالية';

  @override
  String get categoryCrossfit => 'كروس فت';

  @override
  String get categoryYoga => 'يوغا';

  @override
  String get categorySpa => 'سبا';

  @override
  String get categoryPool => 'مسابح';

  @override
  String get subscribed => 'مشترك';

  @override
  String get noPlan => 'لا يوجد خطة';

  @override
  String get planLabel => 'الخطة';

  @override
  String get visitsRemainingLabel => 'الزيارات المتبقية';

  @override
  String get myPlan => 'خطتي';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get helpCenter => 'مركز المساعدة والأسئلة الشائعة';

  @override
  String get invalidQr => 'رمز QR غير صالح';

  @override
  String get checkinSuccess => 'تم تسجيل الدخول بنجاح!';

  @override
  String get checkinFailed => 'فشل تسجيل الدخول';

  @override
  String get noActiveSub => 'لا يوجد اشتراك فعّال';

  @override
  String get subExpired => 'الاشتراك منتهي';

  @override
  String get alreadyCheckedIn => 'تم التسجيل مسبقاً اليوم';

  @override
  String get tierNotAllowed => 'فئة الخطة غير مسموح بها لهذا النادي';

  @override
  String get gymNotFound => 'النادي غير موجود';

  @override
  String get subscribeToEnter => 'اشترك في خطة للدخول إلى الأندية';

  @override
  String get scanGymQr => 'امسح رمز QR الموجود في النادي';

  @override
  String get oneVisitPerDay => 'زيارة واحدة لكل نادي يومياً';

  @override
  String get cameraAccessDenied => 'لا يمكن الوصول إلى الكاميرا';

  @override
  String get grantCameraPermission => 'تأكد من منح صلاحية الكاميرا';

  @override
  String get gymLabel => 'النادي';

  @override
  String get scanAnother => 'مسح آخر';

  @override
  String get gymPlans => 'خطط الأندية';

  @override
  String get historyLabel => 'السجل';

  @override
  String get unlimitedGymAccess =>
      'وصول غير محدود للأندية شهرياً برسوم ثابتة مع تجديد تلقائي';

  @override
  String get choosePlan => 'اختر الاشتراك الأنسب لك';

  @override
  String continueWith(String tier, String duration) {
    return 'متابعة مع $tier Plan ($duration)';
  }

  @override
  String get validOneMonth => 'صالح لمدة شهر';

  @override
  String get autoRenew => 'تجديد تلقائي';

  @override
  String get year => 'سنة';

  @override
  String get months => 'أشهر';

  @override
  String get month => 'شهر';

  @override
  String startsFrom(String price) {
    return 'يبدأ من $price د.أ/شهر';
  }

  @override
  String networkGyms(String tier) {
    return 'أندية شبكة خطة $tier';
  }

  @override
  String exploreNetworkGyms(String tier) {
    return 'استكشف جميع أندية شبكة خطة $tier...';
  }

  @override
  String get noGymsYet => 'لا توجد أندية متاحة بعد';

  @override
  String get understood => 'فهمت';

  @override
  String partnerHello(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get partnerDashboard => 'لوحة تحكم النادي';

  @override
  String get showGymQr => 'عرض رمز QR للنادي';

  @override
  String get memberScansToCheckin => 'يمسح العضو هذا الرمز لتسجيل دخوله';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get today => 'اليوم';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get total => 'الإجمالي';

  @override
  String get monthEarnings => 'أرباح الشهر';

  @override
  String get noGymLinked => 'لا يوجد نادي مرتبط';

  @override
  String get askAdminLinkGym => 'اطلب من المشرف ربط نادي بحسابك';

  @override
  String get recentCheckins => 'آخر عمليات الدخول';

  @override
  String get noCheckinsYet => 'لا توجد عمليات دخول بعد';

  @override
  String get member => 'عضو';

  @override
  String get gymQrCode => 'رمز QR للنادي';

  @override
  String get noGymLinkedToAccount => 'لا يوجد نادي مرتبط بحسابك';

  @override
  String get showQrToMembers => 'اعرض هذا الرمز للأعضاء لمسحه';

  @override
  String get memberScansThisQr => 'يمسح العضو هذا الرمز لتسجيل دخوله';

  @override
  String get qrCodeFixed => 'الرمز ثابت — لا يتغير';

  @override
  String get partnerHome => 'الرئيسية';

  @override
  String get partnerQr => 'رمز QR';

  @override
  String get defaultGymName => 'النادي';

  @override
  String get partnerDefault => 'شريك';

  @override
  String get defaultInitial => 'م';

  @override
  String get amountPaid => 'المبلغ المدفوع';
}
