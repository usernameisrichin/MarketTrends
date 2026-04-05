// ============================================================
// core/constants/api_constants.dart — App-wide Constants
// ============================================================
//
// Why have a constants file?
//   Instead of scattering URLs and magic strings throughout the code,
//   we define them ONCE here. If the URL ever changes, you update
//   one line — not 10 files.
//
// "core/" holds things that are truly app-wide:
//   constants, theme, utilities, base classes, etc.
// ============================================================

class ApiConstants {
  // Private constructor — prevents anyone from doing `ApiConstants()`
  // This class is meant to be used as a namespace, not instantiated.
  ApiConstants._();

  /// Base URL of the FastAPI backend.
  ///
  /// Android emulator: use 10.0.2.2 (maps to your computer's localhost)
  /// iOS simulator / Web: use localhost
  /// Real device on same WiFi: use your computer's local IP, e.g. 192.168.1.5
  static const String baseUrl = 'http://localhost:8000';

  /// Full URL for the portfolio endpoint
  static const String portfolioEndpoint = '$baseUrl/portfolio';
}
