// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => '1Pass';

  @override
  String get tagline => 'One subscription. Every gym.';

  @override
  String get login => 'Login';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get enterPhone => 'Enter your phone number';

  @override
  String get enterOtp => 'Enter the 6-digit code';

  @override
  String get debugOtpHint => 'Debug mode — use 123456';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get register => 'Complete Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email (optional)';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get birthday => 'Birthday';

  @override
  String get save => 'Save';

  @override
  String get home => 'Home';

  @override
  String hey(String name) {
    return 'Hey $name';
  }

  @override
  String visitsRemaining(int count) {
    return '$count visits remaining';
  }

  @override
  String daysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String get checkIn => 'Check In';

  @override
  String get findGym => 'Find Gym';

  @override
  String get renewPlan => 'Renew Plan';

  @override
  String get nearbyGyms => 'Nearby Gyms';

  @override
  String get gyms => 'Gyms';

  @override
  String get gymMap => 'Gym Map';

  @override
  String get gymDetail => 'Gym Details';

  @override
  String get openingHours => 'Opening Hours';

  @override
  String get amenities => 'Amenities';

  @override
  String get checkInHere => 'Check in here';

  @override
  String get tierLocked => 'Your plan doesn\'t include this gym tier';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get plans => 'Plans';

  @override
  String get recommended => 'Recommended';

  @override
  String get perMonth => '/month';

  @override
  String get visits30 => '30 visits';

  @override
  String get days30 => '30 days';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get payment => 'Payment';

  @override
  String get simulatePayment => 'Simulate Payment';

  @override
  String get paymentComingSoon => 'Payment integration coming soon';

  @override
  String get success => 'Success!';

  @override
  String get youreAllSet => 'You\'re all set!';

  @override
  String get mySubscription => 'My Subscription';

  @override
  String get active => 'Active';

  @override
  String get expired => 'Expired';

  @override
  String get pending => 'Pending';

  @override
  String walletBalance(String balance, String currency) {
    return '$balance $currency remaining in pool';
  }

  @override
  String get checkinHistory => 'Check-in History';

  @override
  String get qrCheckin => 'QR Check-in';

  @override
  String get scanAtGym => 'Show this QR code at the gym';

  @override
  String get subscriptionExpired => 'Your subscription has expired';

  @override
  String get profile => 'Profile';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get totalCheckins => 'Total Check-ins';

  @override
  String get gymsVisited => 'Gyms Visited';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get mySubscriptionMenu => 'My Subscription';

  @override
  String get help => 'Help & Support';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get country => 'Country';

  @override
  String get notifications => 'Notifications';

  @override
  String get version => 'Version';

  @override
  String get noActiveSubscription => 'No active subscription';

  @override
  String get getStarted => 'Get Started';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';
}
