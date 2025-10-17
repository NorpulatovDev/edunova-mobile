class AppConstants {
  static const String appName = 'EduNova';
  static const String appDescription = 'Education Management System';
  static const String version = '1.0.0';
  
  // API
  static const String baseUrl = 'https://edunova-production.up.railway.app/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String usernameKey = 'username';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String studentsRoute = '/students';
  static const String teachersRoute = '/teachers';
  static const String coursesRoute = '/courses';
  static const String paymentsRoute = '/payments';
  static const String expensesRoute = '/expenses';
  static const String reportsRoute = '/reports';
  static const String settingsRoute = '/settings';
  
  // Test Credentials
  static const Map<String, String> testCredentials = {
    'admin': 'admin123',
    'manager': 'manager123',
  };
  
  // UI Constants
  static const double sidebarWidth = 280.0;
  static const double sidebarWidthCollapsed = 70.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}