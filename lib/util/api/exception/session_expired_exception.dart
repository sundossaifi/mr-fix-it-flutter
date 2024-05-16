class SessionExpiredException implements Exception {
  String cause;
  SessionExpiredException(this.cause);
}
