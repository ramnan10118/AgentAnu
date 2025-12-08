class ApiConfig {
  // Base URLs
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  
  // Environment
  static const String environment = 'development';
  
  // API Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String validatePan = '/auth/validate-pan';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  
  static const String assetsConsent = '/assets/consent';
  static const String assetsFetch = '/assets/fetch';
  static const String assets = '/assets';
  static const String assetsRevealed = '/assets/revealed';
  
  static const String nokDesignate = '/nok/designate';
  static const String nokStatus = '/nok/status';
  static const String nokDesignations = '/nok/designations';
  static const String nokAccept = '/nok/accept';
  static const String nokReject = '/nok/reject';
  static const String nokRevoke = '/nok/revoke';
  
  static const String deathUpload = '/death/upload-certificate';
  static const String deathStatus = '/death/status';
  static const String deathYellowHandoff = '/death/yellow-handoff';
  static const String deathClaimsGuidance = '/death/claims-guidance';
  
  // Demo credentials
  static const String mockOtp = '123456';
  static const List<String> samplePans = [
    'ABCDE1234F',
    'XYZAB5678C',
    'PQRST9012G',
  ];
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Socket events
  static const String socketAuthenticate = 'authenticate';
  static const String socketAuthenticated = 'authenticated';
  static const String socketNokDesignate = 'nok:designate';
  static const String socketNokDesignated = 'nok:designated';
  static const String socketNokAccept = 'nok:accept';
  static const String socketNokAccepted = 'nok:accepted';
  static const String socketNokRejected = 'nok:rejected';
  static const String socketDeathVerified = 'death:verified';
  static const String socketError = 'error';
}

