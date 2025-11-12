# Deep Linking & URL Shortening Configuration

## Overview

This document covers deep linking setup for SimplyStyles, including Firebase Dynamic Links, Android App Links, iOS Universal Links, and Bitly integration for branded short URLs.

## Firebase Dynamic Links

### Default Domain
```
simplysoph.page.link
```

### Configuration
- **Auto-provisioned**: Firebase automatically creates this domain
- **Free tier**: Unlimited links
- **Analytics**: Built-in click tracking
- **Deep linking**: Native app routing support

### Setup
1. Enable Dynamic Links in Firebase Console
2. No additional configuration needed for basic usage
3. Links automatically route to app or web fallback

## Application Links Configuration

### Android App Links

Add to Bitly or custom domain configuration:
```
https://simplysoph.page.link
https://simplysoph-66c78.web.app
https://simplysoph-66c78.firebaseapp.com
```

**android/app/src/main/AndroidManifest.xml:**
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="simplysoph.page.link" />
    <data android:scheme="https" android:host="simplysoph-66c78.web.app" />
</intent-filter>
```

### iOS Universal Links

Add to Bitly or custom domain configuration:
```
applinks:simplysoph.page.link
applinks:simplysoph-66c78.web.app
applinks:simplysoph-66c78.firebaseapp.com
```

**ios/Runner/Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>simplysoph</string>
        </array>
    </dict>
</array>
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:simplysoph.page.link</string>
    <string>applinks:simplysoph-66c78.web.app</string>
</array>
```

## Bitly Integration

### OAuth Redirect URIs

For Bitly OAuth authentication, configure these redirect URIs in your Bitly app settings:

**Primary:**
```
https://simplysoph-66c78.firebaseapp.com/__/auth/handler
```

**Additional:**
```
https://simplysoph-66c78.web.app/__/auth/handler
http://localhost/__/auth/handler
```

### Bitly Setup Steps

1. Go to https://app.bitly.com/settings/api/
2. Navigate to **OAuth Applications**
3. Create new application or edit existing
4. Add redirect URIs above
5. Copy Client ID and Client Secret

### API Access Token (Simpler Alternative)

If only using URL shortening (not OAuth):
1. Go to https://app.bitly.com/settings/api/
2. Generate Access Token
3. Store in Firebase environment config
4. No redirect URIs needed

### Application Links in Bitly

Add these domains to Bitly's "Allowed Domains" or "Application Links":
```
https://simplysoph.page.link
https://simplysoph-66c78.web.app
https://simplysoph-66c78.firebaseapp.com
```

## Custom Domain (Future)

### Recommended Setup
```
Domain: simplystyles.app
Short links: go.simplystyles.app
```

### Configuration
```
https://go.simplystyles.app
applinks:go.simplystyles.app
```

## Implementation Strategy

### Recommended Approach
1. **Firebase Dynamic Links**: Primary deep linking (free, native)
2. **Bitly**: Marketing campaigns and branded short URLs
3. **Custom Domain**: Future branding upgrade

### Use Cases

**Firebase Dynamic Links:**
- In-app sharing (outfit recommendations)
- Email notifications (password reset, welcome)
- Push notifications
- Social media posts from app

**Bitly:**
- Marketing campaigns
- Influencer tracking
- A/B testing different links
- Analytics and click tracking
- Branded short URLs for external marketing

## Flutter Dependencies

### pubspec.yaml
```yaml
dependencies:
  firebase_dynamic_links: ^5.5.0  # Firebase Dynamic Links
  uni_links: ^0.5.1               # Deep link handling
  url_launcher: ^6.3.0            # Open URLs
  
  # Optional: Bitly API client
  http: ^1.2.0                    # For Bitly API calls
```

## Code Implementation

### Firebase Dynamic Links Service

**lib/services/dynamic_links_service.dart:**
```dart
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinksService {
  static const String _dynamicLinkDomain = 'simplysoph.page.link';
  static const String _webUrl = 'https://simplysoph-66c78.web.app';

  Future<String> createOutfitLink(String outfitId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://$_dynamicLinkDomain',
      link: Uri.parse('$_webUrl/outfit/$outfitId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.simplysoph.simplystyles',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.simplysoph.simplystyles',
        minimumVersion: '1.0.0',
        appStoreId: 'YOUR_APP_STORE_ID',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this outfit!',
        description: 'Discover this style on SimplyStyles',
        imageUrl: Uri.parse('$_webUrl/assets/share-image.png'),
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance
        .buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  Future<void> handleDynamicLink() async {
    // Handle link when app is opened
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(initialLink);

    // Handle link when app is in background
    FirebaseDynamicLinks.instance.onLink.listen(_handleDeepLink);
  }

  void _handleDeepLink(PendingDynamicLinkData? linkData) {
    if (linkData == null) return;
    final Uri deepLink = linkData.link;
    // Route to appropriate screen based on deepLink path
  }
}
```

### Bitly Service (Optional)

**lib/services/bitly_service.dart:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BitlyService {
  static const String _apiUrl = 'https://api-ssl.bitly.com/v4';
  final String _accessToken;

  BitlyService(this._accessToken);

  Future<String> shortenUrl(String longUrl) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/shorten'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'long_url': longUrl}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['link'];
    }
    throw Exception('Failed to shorten URL: ${response.body}');
  }
}
```

## Environment Configuration

### Firebase Functions Config

Store Bitly token securely:
```bash
firebase functions:config:set bitly.token="YOUR_BITLY_ACCESS_TOKEN"
```

### Flutter Environment Variables

**lib/config/env.dart:**
```dart
class Env {
  static const String bitlyToken = String.fromEnvironment(
    'BITLY_TOKEN',
    defaultValue: '',
  );
}
```

## Security Considerations

1. **Never commit API tokens** to version control
2. **Use Firebase Functions** for server-side Bitly API calls
3. **Validate deep links** before routing in app
4. **Implement rate limiting** on link creation
5. **Monitor link analytics** for abuse

## Testing

### Test Deep Links

**Android:**
```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://simplysoph.page.link/test"
```

**iOS:**
```bash
xcrun simctl openurl booted "https://simplysoph.page.link/test"
```

### Test Bitly Integration
```dart
final bitly = BitlyService('YOUR_TOKEN');
final shortUrl = await bitly.shortenUrl('https://simplysoph-66c78.web.app/outfit/123');
print(shortUrl); // https://bit.ly/xxxxx
```

## Analytics & Monitoring

### Firebase Dynamic Links Analytics
- Click tracking (automatic)
- Platform breakdown (iOS/Android/Web)
- Geographic data
- Referrer information

### Bitly Analytics
- Click counts
- Geographic data
- Referrer tracking
- Custom campaign parameters

## Cost Estimates

### Firebase Dynamic Links
- **Free**: Unlimited links and clicks
- **Analytics**: Included

### Bitly
- **Free Tier**: 50 links/month, basic analytics
- **Starter**: $29/month, 1,500 links/month
- **Premium**: $199/month, unlimited links, advanced analytics
- **Enterprise**: Custom pricing

## Next Steps

1. ✅ Document configuration (this file)
2. ⬜ Enable Firebase Dynamic Links in console
3. ⬜ Implement DynamicLinksService
4. ⬜ Add deep link handling to main.dart
5. ⬜ Test deep links on Android/iOS
6. ⬜ (Optional) Set up Bitly account
7. ⬜ (Optional) Implement BitlyService
8. ⬜ Configure custom domain (future)

## References

- [Firebase Dynamic Links](https://firebase.google.com/docs/dynamic-links)
- [Bitly API Documentation](https://dev.bitly.com/)
- [Android App Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
