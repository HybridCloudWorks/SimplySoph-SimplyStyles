// ignore_for_file: avoid_web_libraries_in_flutter,deprecated_member_use
import 'dart:html' as html;

/// Returns true when running inside an embedded webview or a restricted
/// browser environment where popups are commonly blocked (VS Code Simple
/// Browser, in-app webviews, etc.). This is a heuristic using the userAgent.
bool isEmbeddedWebView() {
  final ua = html.window.navigator.userAgent.toLowerCase();

  // Common embedded webview indicators
  final indicators = [
    'wv', // Android WebView
    'webview',
    'flutter', // flutter webview shells
    'electron',
    'cordova',
    'capacitor',
  ];

  for (final ind in indicators) {
    if (ua.contains(ind)) return true;
  }

  // VS Code Simple Browser uses "SimpleBrowser" in UA sometimes; check for that.
  if (ua.contains('simplebrowser') || ua.contains('vscode')) return true;

  return false;
}
