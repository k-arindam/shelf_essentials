import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_essentials/src/form_data.dart';
import 'package:shelf_essentials/src/http_method.dart';

extension RequestExtension on Request {
  /// Returns a [Stream] representing the body.
  Future<String> body() => readAsString();

  /// Returns a [Future] containing the form data as a [Map].
  Future<FormData> formData() {
    return parseFormData(headers: headers, body: body, bytes: read);
  }

  /// Returns a [Future] containing the body text parsed as a json object.
  /// This object could be anything that can be represented by json
  /// e.g. a map, a list, a string, a number, a bool...
  Future<dynamic> json() async {
    final contentType = headers['content-type'];

    if (contentType == null || !contentType.contains('application/json')) {
      throw FormatException('Request content-type is not application/json');
    }

    return jsonDecode(await body());
  }

  /// The [HttpMethod] associated with the request.
  HttpMethod get httpMethod {
    return HttpMethod.values.firstWhere(
      (m) => m.value == method.toUpperCase(),
      orElse: () => throw UnsupportedHttpMethodException(method),
    );
  }

  /// Connection information for the associated HTTP request.
  HttpConnectionInfo? get connectionInfo {
    return context['shelf.io.connection_info'] as HttpConnectionInfo?;
  }
}

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
