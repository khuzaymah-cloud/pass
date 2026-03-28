import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'1Pass'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'One Subscription, Play Anywhere.'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhone;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterOtp;

  /// No description provided for @debugOtpHint.
  ///
  /// In en, this message translates to:
  /// **'Debug mode — use 123456'**
  String get debugOtpHint;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get register;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get email;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @hey.
  ///
  /// In en, this message translates to:
  /// **'Hey {name}'**
  String hey(String name);

  /// No description provided for @visitsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} visits remaining'**
  String visitsRemaining(int count);

  /// No description provided for @visitsRemainingOf.
  ///
  /// In en, this message translates to:
  /// **'{remaining} visits remaining of {max}'**
  String visitsRemainingOf(int remaining, int max);

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} days remaining'**
  String daysRemaining(int count);

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @findGym.
  ///
  /// In en, this message translates to:
  /// **'Find Gym'**
  String get findGym;

  /// No description provided for @renewPlan.
  ///
  /// In en, this message translates to:
  /// **'Renew Plan'**
  String get renewPlan;

  /// No description provided for @nearbyGyms.
  ///
  /// In en, this message translates to:
  /// **'Nearby Gyms'**
  String get nearbyGyms;

  /// No description provided for @gyms.
  ///
  /// In en, this message translates to:
  /// **'Gyms'**
  String get gyms;

  /// No description provided for @gymMap.
  ///
  /// In en, this message translates to:
  /// **'Gym Map'**
  String get gymMap;

  /// No description provided for @gymDetail.
  ///
  /// In en, this message translates to:
  /// **'Gym Details'**
  String get gymDetail;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get openingHours;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @checkInHere.
  ///
  /// In en, this message translates to:
  /// **'Check in here'**
  String get checkInHere;

  /// No description provided for @tierLocked.
  ///
  /// In en, this message translates to:
  /// **'Your plan doesn\'t include this gym tier'**
  String get tierLocked;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @visits30.
  ///
  /// In en, this message translates to:
  /// **'30 visits'**
  String get visits30;

  /// No description provided for @days30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get days30;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @simulatePayment.
  ///
  /// In en, this message translates to:
  /// **'Simulate Payment'**
  String get simulatePayment;

  /// No description provided for @paymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Payment integration coming soon'**
  String get paymentComingSoon;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @youreAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get youreAllSet;

  /// No description provided for @mySubscription.
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get mySubscription;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'{balance} {currency} remaining in pool'**
  String walletBalance(String balance, String currency);

  /// No description provided for @checkinHistory.
  ///
  /// In en, this message translates to:
  /// **'Check-in History'**
  String get checkinHistory;

  /// No description provided for @qrCheckin.
  ///
  /// In en, this message translates to:
  /// **'QR Check-in'**
  String get qrCheckin;

  /// No description provided for @scanAtGym.
  ///
  /// In en, this message translates to:
  /// **'Show this QR code at the gym'**
  String get scanAtGym;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has expired'**
  String get subscriptionExpired;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @totalCheckins.
  ///
  /// In en, this message translates to:
  /// **'Total Check-ins'**
  String get totalCheckins;

  /// No description provided for @gymsVisited.
  ///
  /// In en, this message translates to:
  /// **'Gyms Visited'**
  String get gymsVisited;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @mySubscriptionMenu.
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get mySubscriptionMenu;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @noActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get noActiveSubscription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @locationAmmanJordan.
  ///
  /// In en, this message translates to:
  /// **'Amman, Jordan'**
  String get locationAmmanJordan;

  /// No description provided for @subscribeNow1Pass.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to 1Pass now'**
  String get subscribeNow1Pass;

  /// No description provided for @oneSubAnyGym.
  ///
  /// In en, this message translates to:
  /// **'One subscription, enter any gym in the network'**
  String get oneSubAnyGym;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @categoryGyms.
  ///
  /// In en, this message translates to:
  /// **'Gyms'**
  String get categoryGyms;

  /// No description provided for @categoryMartialArts.
  ///
  /// In en, this message translates to:
  /// **'Martial Arts'**
  String get categoryMartialArts;

  /// No description provided for @categoryCrossfit.
  ///
  /// In en, this message translates to:
  /// **'CrossFit'**
  String get categoryCrossfit;

  /// No description provided for @categoryYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get categoryYoga;

  /// No description provided for @categorySpa.
  ///
  /// In en, this message translates to:
  /// **'Spa'**
  String get categorySpa;

  /// No description provided for @categoryPool.
  ///
  /// In en, this message translates to:
  /// **'Pools'**
  String get categoryPool;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @noPlan.
  ///
  /// In en, this message translates to:
  /// **'No plan'**
  String get noPlan;

  /// No description provided for @planLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planLabel;

  /// No description provided for @visitsRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Visits remaining'**
  String get visitsRemainingLabel;

  /// No description provided for @myPlan.
  ///
  /// In en, this message translates to:
  /// **'My Plan'**
  String get myPlan;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center & FAQ'**
  String get helpCenter;

  /// No description provided for @invalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQr;

  /// No description provided for @checkinSuccess.
  ///
  /// In en, this message translates to:
  /// **'Checked in successfully!'**
  String get checkinSuccess;

  /// No description provided for @checkinFailed.
  ///
  /// In en, this message translates to:
  /// **'Check-in failed'**
  String get checkinFailed;

  /// No description provided for @noActiveSub.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get noActiveSub;

  /// No description provided for @subExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get subExpired;

  /// No description provided for @alreadyCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Already checked in today'**
  String get alreadyCheckedIn;

  /// No description provided for @tierNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Plan tier not allowed for this gym'**
  String get tierNotAllowed;

  /// No description provided for @gymNotFound.
  ///
  /// In en, this message translates to:
  /// **'Gym not found'**
  String get gymNotFound;

  /// No description provided for @subscribeToEnter.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to a plan to enter gyms'**
  String get subscribeToEnter;

  /// No description provided for @scanGymQr.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code at the gym'**
  String get scanGymQr;

  /// No description provided for @oneVisitPerDay.
  ///
  /// In en, this message translates to:
  /// **'One visit per gym per day'**
  String get oneVisitPerDay;

  /// No description provided for @cameraAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Cannot access camera'**
  String get cameraAccessDenied;

  /// No description provided for @grantCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Make sure to grant camera permission'**
  String get grantCameraPermission;

  /// No description provided for @gymLabel.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gymLabel;

  /// No description provided for @scanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan Another'**
  String get scanAnother;

  /// No description provided for @gymPlans.
  ///
  /// In en, this message translates to:
  /// **'Gym Plans'**
  String get gymPlans;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @unlimitedGymAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited monthly gym access with a fixed fee and auto-renewal'**
  String get unlimitedGymAccess;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose the best plan for you'**
  String get choosePlan;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with {tier} Plan ({duration})'**
  String continueWith(String tier, String duration);

  /// No description provided for @validOneMonth.
  ///
  /// In en, this message translates to:
  /// **'Valid for one month'**
  String get validOneMonth;

  /// No description provided for @autoRenew.
  ///
  /// In en, this message translates to:
  /// **'Auto-renewal'**
  String get autoRenew;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @startsFrom.
  ///
  /// In en, this message translates to:
  /// **'Starts from {price} JD/month'**
  String startsFrom(String price);

  /// No description provided for @networkGyms.
  ///
  /// In en, this message translates to:
  /// **'{tier} Plan Network Gyms'**
  String networkGyms(String tier);

  /// No description provided for @exploreNetworkGyms.
  ///
  /// In en, this message translates to:
  /// **'Explore all {tier} plan network gyms...'**
  String exploreNetworkGyms(String tier);

  /// No description provided for @noGymsYet.
  ///
  /// In en, this message translates to:
  /// **'No gyms available yet'**
  String get noGymsYet;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @partnerHello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String partnerHello(String name);

  /// No description provided for @partnerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Gym Dashboard'**
  String get partnerDashboard;

  /// No description provided for @showGymQr.
  ///
  /// In en, this message translates to:
  /// **'Show Gym QR Code'**
  String get showGymQr;

  /// No description provided for @memberScansToCheckin.
  ///
  /// In en, this message translates to:
  /// **'Member scans this code to check in'**
  String get memberScansToCheckin;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @monthEarnings.
  ///
  /// In en, this message translates to:
  /// **'Monthly Earnings'**
  String get monthEarnings;

  /// No description provided for @noGymLinked.
  ///
  /// In en, this message translates to:
  /// **'No gym linked'**
  String get noGymLinked;

  /// No description provided for @askAdminLinkGym.
  ///
  /// In en, this message translates to:
  /// **'Ask the admin to link a gym to your account'**
  String get askAdminLinkGym;

  /// No description provided for @recentCheckins.
  ///
  /// In en, this message translates to:
  /// **'Recent Check-ins'**
  String get recentCheckins;

  /// No description provided for @noCheckinsYet.
  ///
  /// In en, this message translates to:
  /// **'No check-ins yet'**
  String get noCheckinsYet;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @gymQrCode.
  ///
  /// In en, this message translates to:
  /// **'Gym QR Code'**
  String get gymQrCode;

  /// No description provided for @noGymLinkedToAccount.
  ///
  /// In en, this message translates to:
  /// **'No gym linked to your account'**
  String get noGymLinkedToAccount;

  /// No description provided for @showQrToMembers.
  ///
  /// In en, this message translates to:
  /// **'Show this code to members to scan'**
  String get showQrToMembers;

  /// No description provided for @memberScansThisQr.
  ///
  /// In en, this message translates to:
  /// **'Member scans this code to check in'**
  String get memberScansThisQr;

  /// No description provided for @qrCodeFixed.
  ///
  /// In en, this message translates to:
  /// **'This code is fixed — it doesn\'t change'**
  String get qrCodeFixed;

  /// No description provided for @partnerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get partnerHome;

  /// No description provided for @partnerQr.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get partnerQr;

  /// No description provided for @defaultGymName.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get defaultGymName;

  /// No description provided for @partnerDefault.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get partnerDefault;

  /// No description provided for @defaultInitial.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get defaultInitial;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
