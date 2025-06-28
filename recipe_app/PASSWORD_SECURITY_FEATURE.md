# Password Security Feature

## Overview
This document describes the password attempt tracking and account lockout security feature implemented in the Recipe App.

## Features Implemented

### 1. **Failed Login Attempt Tracking**
- The system tracks failed login attempts for each user account
- Failed attempts are stored in the user's profile in Firestore
- Timestamps of failed attempts are recorded

### 2. **Account Lockout Protection**
- After **5 consecutive failed login attempts**, the user account is automatically locked
- Locked accounts cannot be accessed until the password is reset via email
- The system shows clear warning messages as attempts increase

### 3. **Password Reset via Email**
- Users can reset their password through Firebase Auth's email reset system
- Password reset is the only way to unlock a locked account
- Reset functionality is available through:
  - "Forgot Password?" link on the login screen
  - Account lockout dialog when account is locked

### 4. **Enhanced User Experience**
- **Progressive warnings**: Users receive warnings when they have 2 or fewer attempts remaining
- **Clear error messages**: Different messages for various error scenarios
- **Visual indicators**: Color-coded warnings (orange for low attempts, red for errors)
- **Account lockout dialog**: Clear explanation and direct access to password reset

## Technical Implementation

### Database Schema Changes
The `User` model has been extended with the following fields:
```dart
final int failedLoginAttempts;        // Default: 0
final bool isAccountLocked;           // Default: false  
final DateTime? lastFailedAttempt;    // Timestamp of last failed attempt
final DateTime? accountLockedUntil;   // Future: Could be used for time-based unlocking
```

### Security Methods Added
- `FirebaseService.recordFailedLoginAttempt(String email)`
- `FirebaseService.resetFailedLoginAttempts(String userId)`
- `FirebaseService.isAccountLocked(String email)`
- `FirebaseService.getRemainingLoginAttempts(String email)`
- `FirebaseService.sendPasswordResetEmail(String email)`
- `FirebaseService.unlockAccount(String email)` (for admin use)

### Login Flow Updates
1. **Pre-login check**: Verify account is not locked before attempting authentication
2. **Failed attempt handling**: Record failures and update attempt count
3. **Success handling**: Reset attempt counter on successful login
4. **Error categorization**: Different handling for authentication vs. system errors

## User Experience Flow

### Normal Login Process
1. User enters credentials
2. If successful → Welcome message, redirect to home
3. If failed → Show remaining attempts warning

### Account Lockout Process  
1. User exceeds 5 failed attempts
2. Account is automatically locked
3. Lockout dialog appears with explanation
4. User must reset password via email to regain access

### Password Reset Process
1. User clicks "Forgot Password?" or "Reset Password" in lockout dialog
2. System validates email format
3. Firebase sends password reset email
4. User follows email instructions to reset password
5. Account is automatically unlocked after successful password reset

## Security Benefits

### Brute Force Protection
- Prevents automated password guessing attacks
- Limits manual brute force attempts to 5 tries maximum

### Account Security
- Protects user accounts from unauthorized access attempts
- Forces password reset for compromised accounts

### User Awareness
- Users are notified of failed login attempts on their account
- Encourages strong password practices

## Testing the Feature

### Test Failed Login Attempts
1. Create a test account or use existing account
2. Enter wrong password repeatedly
3. Observe warning messages showing remaining attempts
4. On 5th failed attempt, account should be locked

### Test Account Lockout
1. Trigger account lockout (5 failed attempts)
2. Verify lockout dialog appears
3. Test password reset functionality
4. Verify account unlocks after password reset

### Test Password Reset
1. Click "Forgot Password?" link
2. Enter valid email address
3. Check email for reset instructions
4. Follow reset process
5. Verify ability to login with new password

## Future Enhancements

### Potential Improvements
- **Time-based auto-unlock**: Automatically unlock accounts after 24 hours
- **IP-based tracking**: Track attempts by IP address for additional security
- **Admin dashboard**: Allow administrators to view and manage locked accounts
- **Security notifications**: Email users about failed login attempts
- **Two-factor authentication**: Add additional security layer

### Configuration Options
- Make attempt limit configurable (currently hardcoded to 5)
- Add different lockout durations for different user types
- Implement progressive delays between attempts

## Maintenance

### Monitoring
- Monitor locked account frequency in Firestore
- Track password reset usage patterns
- Review security logs for suspicious activity

### Support
- Customer support can use `FirebaseService.unlockAccount(email)` to manually unlock accounts
- Monitor user feedback regarding security warnings and messages

## Conclusion
This security feature significantly enhances the app's protection against unauthorized access while maintaining a good user experience through clear communication and easy recovery options. 