/// Application-wide string constants.
class AppStrings {
  AppStrings._();

  // ─── App Info ───
  static const String appName = 'StepSync';
  static const String appTagline = 'Walk Together, Win Together';
  static const String appVersion = '1.0.0';

  // ─── Auth Strings ───
  static const String welcomeBack = 'Welcome Back!';
  static const String createAccount = 'Create Account';
  static const String loginSubtitle = 'Sign in to continue your fitness journey';
  static const String registerSubtitle = 'Join the community and start tracking';
  static const String forgotPassword = 'Forgot Password?';
  static const String forgotPasswordSubtitle =
      'Enter your email to receive a password reset link';
  static const String signInWithGoogle = 'Continue with Google';
  static const String signInWithPhone = 'Continue with Phone';
  static const String signInWithEmail = 'Sign in with Email';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String orContinueWith = 'Or continue with';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String sendResetLink = 'Send Reset Link';
  static const String verifyOtp = 'Verify OTP';
  static const String otpSentTo = 'OTP sent to ';
  static const String resendOtp = 'Resend OTP';
  static const String enterPhoneNumber = 'Enter your phone number';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';

  // ─── Dashboard Strings ───
  static const String todaysSteps = "Today's Steps";
  static const String dailyGoal = 'Daily Goal';
  static const String goalProgress = 'Goal Progress';
  static const String distanceCovered = 'Distance';
  static const String caloriesBurned = 'Calories';
  static const String currentStreak = 'Current Streak';
  static const String longestStreak = 'Longest Streak';
  static const String globalRank = 'Global Rank';
  static const String stepsUnit = 'steps';
  static const String kmUnit = 'km';
  static const String kcalUnit = 'kcal';
  static const String daysUnit = 'days';

  // ─── Leaderboard Strings ───
  static const String leaderboard = 'Leaderboard';
  static const String today = 'Today';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String allTime = 'All Time';
  static const String globalCommunity = 'Global Community';
  static const String dailySteps = 'Daily Steps';
  static const String weeklySteps = 'Weekly Steps';
  static const String totalSteps = 'Total Steps';

  // ─── History Strings ───
  static const String history = 'History';
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String averageDailySteps = 'Avg Daily Steps';
  static const String totalMonthlySteps = 'Total Monthly Steps';
  static const String last7Days = 'Last 7 Days';

  // ─── Profile Strings ───
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String settings = 'Settings';
  static const String changePhoto = 'Change Photo';
  static const String totalDistance = 'Total Distance';
  static const String achievements = 'Achievements';
  static const String save = 'Save';
  static const String cancel = 'Cancel';

  // ─── Settings Strings ───
  static const String darkMode = 'Dark Mode';
  static const String notifications = 'Notifications';
  static const String stepGoal = 'Daily Step Goal';
  static const String about = 'About';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String deleteAccount = 'Delete Account';

  // ─── Motivational Messages ───
  static const List<String> motivationalMessages = [
    'Every step counts! Keep moving! 🚶',
    "You're making progress! Halfway there! 💪",
    'Amazing effort! Almost at your goal! 🔥',
    'So close! Push through! 🎯',
    'Goal achieved! You\'re a champion! 🏆',
  ];

  // ─── Onboarding ───
  static const String onboardingTitle1 = 'Track Your Steps';
  static const String onboardingDesc1 =
      'Automatically count your steps throughout the day with precision tracking.';
  static const String onboardingTitle2 = 'Compete & Connect';
  static const String onboardingDesc2 =
      'Join the global community, climb leaderboards, and challenge friends.';
  static const String onboardingTitle3 = 'Achieve Your Goals';
  static const String onboardingDesc3 =
      'Set daily targets, build streaks, and earn achievement badges.';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String next = 'Next';

  // ─── Error Messages ───
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noInternet = 'No internet connection.';
  static const String pedometerNotAvailable =
      'Step sensor not available on this device.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String weakPassword = 'Password must be at least 6 characters.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String nameRequired = 'Please enter your name.';
  static const String phoneRequired = 'Please enter your phone number.';

  // ─── Streak Badges ───
  static const String streak3Day = '3-Day Streak 🔥';
  static const String streak7Day = '7-Day Streak ⚡';
  static const String streak30Day = '30-Day Streak 🏅';
  static const String streak100Day = '100-Day Streak 🏆';

  // ─── Bottom Navigation ───
  static const String home = 'Home';
}
