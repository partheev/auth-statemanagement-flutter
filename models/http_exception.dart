class HttpException implements Exception {
  String message;
  HttpException(this.message);

  String toString() {
    return this.message;
  }
}
