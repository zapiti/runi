class AppConfig {
  static const String supabaseUrl = 'https://gbzncppoknvrubjgwqdd.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdiem5jcHBva252cnViamd3cWRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMTA1NDksImV4cCI6MjA2MDc4NjU0OX0.9vVdtFe_ljhd5b-LT9umVms8zmpnYrLHutNXIXqtOJY';

  static const String stripePublishableKey =
      'pk_test_51RGCQFIG86LKQVTcewSUEF1D2DXRcqPEmKWlqJPfy7OXCkQI0nCjFz0gUDEntPA18OMg6XJucgobHkj4GG0UEks900KFEaSdgH';

  // AdMob IDs
  static const String adMobAppId = 'ca-app-pub-5285996164266896~5557463871';
  static const String adMobRewardedAdId =
      'ca-app-pub-5285996164266896~5557463871';

  // App Settings
  static const String appName = 'Runi';
  static const bool isDevelopment = true;

  // API Endpoints
  static const String apiVersion = 'v1';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Cache Settings
  static const Duration cacheValidityDuration = Duration(days: 1);

  // Workout Settings
  static const int defaultWorkoutDuration = 16; // minutes
  static const int minWorkoutDuration = 5; // minutes
  static const int maxWorkoutDuration = 120; // minutes
}
