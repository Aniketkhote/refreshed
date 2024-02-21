/// A class for representing HTTP status codes and providing utility methods for handling them.
class HttpStatus {
  /// Constructs an instance of [HttpStatus] with the provided HTTP status [code].
  HttpStatus(this.code);

  /// The HTTP status code.
  final int? code;

  // Informational 1xx
  static const int continue_ = 100;
  static const int switchingProtocols = 101;
  static const int processing = 102;
  static const int earlyHints = 103;

  // Success 2xx
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int nonAuthoritativeInformation = 203;
  static const int noContent = 204;
  static const int resetContent = 205;
  static const int partialContent = 206;
  static const int multiStatus = 207;
  static const int alreadyReported = 208;
  static const int imUsed = 226;

  // Redirection 3xx
  static const int multipleChoices = 300;
  static const int movedPermanently = 301;
  static const int found = 302;
  static const int movedTemporarily = 302; // Common alias for found.
  static const int seeOther = 303;
  static const int notModified = 304;
  static const int useProxy = 305;
  static const int switchProxy = 306;
  static const int temporaryRedirect = 307;
  static const int permanentRedirect = 308;

  // Client Error 4xx
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int paymentRequired = 402;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int notAcceptable = 406;
  static const int proxyAuthenticationRequired = 407;
  static const int requestTimeout = 408;
  static const int conflict = 409;
  static const int gone = 410;
  static const int lengthRequired = 411;
  static const int preconditionFailed = 412;
  static const int requestEntityTooLarge = 413;
  static const int requestUriTooLong = 414;
  static const int unsupportedMediaType = 415;
  static const int requestedRangeNotSatisfiable = 416;
  static const int expectationFailed = 417;
  static const int imATeapot = 418;
  static const int misdirectedRequest = 421;
  static const int unprocessableEntity = 422;
  static const int locked = 423;
  static const int failedDependency = 424;
  static const int tooEarly = 425;
  static const int upgradeRequired = 426;
  static const int preconditionRequired = 428;
  static const int tooManyRequests = 429;
  static const int requestHeaderFieldsTooLarge = 431;
  static const int connectionClosedWithoutResponse = 444;
  static const int unavailableForLegalReasons = 451;
  static const int clientClosedRequest = 499;

  // Server Error 5xx
  static const int internalServerError = 500;
  static const int notImplemented = 501;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
  static const int httpVersionNotSupported = 505;
  static const int variantAlsoNegotiates = 506;
  static const int insufficientStorage = 507;
  static const int loopDetected = 508;
  static const int notExtended = 510;
  static const int networkAuthenticationRequired = 511;
  static const int networkConnectTimeoutError = 599;

  /// Returns `true` if there is a connection error (code is null).
  bool get connectionError => code == null;

  /// Returns `true` if the status code represents an unauthorized access error.
  bool get isUnauthorized => code == unauthorized;

  /// Returns `true` if the status code represents a forbidden access error.
  bool get isForbidden => code == forbidden;

  /// Returns `true` if the status code represents a not found error.
  bool get isNotFound => code == notFound;

  /// Returns `true` if the status code represents a server error.
  bool get isServerError =>
      between(internalServerError, networkConnectTimeoutError);

  /// Checks if the status code falls within the range specified by [begin] and [end].
  bool between(int begin, int end) {
    return !connectionError && code! >= begin && code! <= end;
  }

  /// Returns `true` if the status code is within the range of successful status codes (200-299).
  bool get isOk => between(200, 299);

  /// Returns `true` if the status code indicates an error (not within the successful range).
  bool get hasError => !isOk;
}
