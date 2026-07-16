/// User-friendly messages for HTTP status codes.
class AppErrorMessages {
  AppErrorMessages._();

  static String forStatus(int? status, {String? serverMessage}) {
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }
    switch (status) {
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This action conflicts with existing data. Please refresh and try again.';
      case 422:
        return 'Please check your input and try again.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Our team has been notified. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again shortly.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
