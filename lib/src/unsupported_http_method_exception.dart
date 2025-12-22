import 'package:shelf_essentials/src/http_method.dart';

/// {@template unsupported_http_method_exception}
/// Exception thrown when an unsupported HTTP method is used.
/// {@endtemplate}
class UnsupportedHttpMethodException implements Exception {
  /// {@macro unsupported_http_method_exception}
  const UnsupportedHttpMethodException(this.method);

  /// The unsupported http method.
  final String method;

  @override
  String toString() =>
      '''
Unsupported HTTP method: $method. 
The following methods are supported:
${HttpMethod.values.map((m) => m.value.toUpperCase()).join(', ')}.''';
}
