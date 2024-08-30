class DFirebaseAuthException implements Exception {
  final String code;
  DFirebaseAuthException(this.code);

  String get message {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'user-disabled':
        return 'The user account has been disabled by an administrator.';
      case 'too-many-requests':
        return 'There have been too many attempts to sign in. Please try again later.';
      case 'operation-not-allowed':
        return 'Signing in with email and password is not enabled.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'weak-password':
        return 'The password is not strong enough.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'user-token-expired':
        return 'The user\'s token has expired. Please log in again.';
      case 'invalid-user-token':
        return 'The user\'s token is invalid. Please log in again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.';
      case 'invalid-credential':
        return 'The provided credential is malformed or has expired.';
      case 'invalid-verification-code':
        return 'The verification code is not valid.';
      case 'invalid-verification-id':
        return 'The verification ID is not valid.';
      case 'session-expired':
        return 'The SMS code has expired. Please request a new code.';
      case 'quota-exceeded':
        return 'The SMS quota for this project has been exceeded.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.';
      case 'no-such-provider':
        return 'The requested authentication provider does not exist.';
      case 'invalid-api-key':
        return 'The API key provided is invalid.';
      case 'invalid-custom-token':
        return 'The custom token format is incorrect. Please check the documentation.';
      case 'custom-token-mismatch':
        return 'The custom token corresponds to a different audience.';
      case 'invalid-phone-number':
        return 'The phone number is not valid.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'internal-error':
        return 'An internal error has occurred. Please try again later.';
      default:
        return 'An undefined error occurred.';
    }
  }
}