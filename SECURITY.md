# Security Documentation

## Authentication

### Providers
- Email/Password (Firebase Auth)
- Google OAuth
- Apple Sign-In

### Session Management
- Firebase handles token refresh
- Tokens expire after 1 hour
- Auto-refresh on expiry

## Authorization

### Firestore Rules
```javascript
// Users can only access their own data
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

match /wardrobe_items/{itemId} {
  allow read, write: if resource.data.userId == request.auth.uid;
}
```

### Storage Rules
```javascript
match /users/{userId}/{allPaths=**} {
  allow read, write: if request.auth.uid == userId
    && request.resource.size < 10MB
    && request.resource.contentType.matches('image/.*');
}
```

## Data Privacy

### PII Protection
- No faces stored in images (planned redaction)
- Email encrypted at rest
- No location data collected
- User can export/delete data

### Image Processing
- Face detection and redaction (planned)
- Background removal (planned)
- Replace with stock images (planned)

## Security Checklist

### Implemented
- ✅ Firebase Authentication
- ✅ Firestore security rules
- ✅ Storage security rules
- ✅ HTTPS only

### Missing
- ❌ Multi-factor authentication
- ❌ Rate limiting
- ❌ Input validation
- ❌ Error logging
- ❌ Security monitoring

## Vulnerabilities

### High Priority
1. No MFA - users can be compromised
2. No rate limiting - API abuse possible
3. No input validation - injection risks

### Medium Priority
4. No image sanitization - privacy risk
5. No error logging - blind to attacks

## Incident Response

1. Detect issue via monitoring
2. Disable affected function
3. Notify users if data breach
4. Fix vulnerability
5. Deploy patch
6. Post-mortem review

---

**Last Updated**: 2024
