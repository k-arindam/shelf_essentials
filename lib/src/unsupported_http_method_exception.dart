import 'package:shelf_essentials/src/http_method.dart';

/// {@template unsupported_http_method_exception}
/// Exception thrown when an unsupported HTTP method is used.
///
/// This exception is raised when a request uses an HTTP method that is not
/// supported by the [HttpMethod] enum.
/// {@endtemplate}
class UnsupportedHttpMethodException implements Exception {
  /// {@macro unsupported_http_method_exception}
  const UnsupportedHttpMethodException(this.method);

  /// The unsupported HTTP method as a string.
  ///
  /// Supported methods are: GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD.
  final String method;

  @override
  String toString() =>
      '''
Unsupported HTTP method: $method. 
The following methods are supported:
${HttpMethod.values.map((m) => m.value.toUpperCase()).join(', ')}.''';
}
