import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_essentials/src/form_data.dart';
import 'package:shelf_essentials/src/http_method.dart';
import 'package:shelf_essentials/src/unsupported_http_method_exception.dart';

/// Extension methods on [Request] to simplify common HTTP operations.
///
/// Provides convenient methods for reading and parsing request bodies,
/// accessing the HTTP method, and retrieving connection information.
///
/// Example:
/// ```dart
/// final handler = (Request request) async {
///   switch (request.httpMethod) {
///     case HttpMethod.post:
///       final data = await request.json();
///       return Response.ok('Received: ${data}');
///     case HttpMethod.get:
///       return Response.ok('Hello');
///     default:
///       return Response.notFound('Not found');
///   }
/// };
/// ```
extension RequestExtension on Request {
  /// Reads and returns the request body as a [String].
  ///
  /// The body stream is consumed entirely and converted to a UTF-8 string.
  /// This should only be called once per request.
  ///
  /// Returns: A [Future] containing the body text
  Future<String> body() => readAsString();

  /// Parses the request body as form data and returns a [FormData] object.
  ///
  /// Supports both:
  /// - `application/x-www-form-urlencoded`
  /// - `multipart/form-data`
  ///
  /// Throws [StateError] if the content-type is not one of the supported types.
  ///
  /// Returns: A [Future] containing parsed form fields and uploaded files
  ///
  /// Example:
  /// ```dart
  /// final form = await request.formData();
  /// final username = form.fields['username'];
  /// final avatar = form.files['avatar'];
  /// ```
  Future<FormData> formData() {
    return parseFormData(headers: headers, body: body, bytes: read);
  }

  /// Parses the request body as JSON and returns the decoded value.
  ///
  /// The returned value can be any JSON-decodable type:
  /// - [Map] for JSON objects
  /// - [List] for JSON arrays
  /// - [String], [num], [bool], or `null` for JSON primitives
  ///
  /// Throws [FormatException] if the content-type is not `application/json`.
  /// Throws [FormatException] if the body is not valid JSON.
  ///
  /// Returns: A [Future] containing the decoded JSON value
  ///
  /// Example:
  /// ```dart
  /// final data = await request.json();
  /// print(data['email']); // Access JSON object properties
  /// ```
  Future<dynamic> json() async {
    final contentType = headers['content-type'];

    if (contentType == null || !contentType.contains('application/json')) {
      throw FormatException('Request content-type is not application/json');
    }

    return jsonDecode(await body());
  }

  /// Returns the HTTP method of the request as a type-safe [HttpMethod] enum.
  ///
  /// Throws [UnsupportedHttpMethodException] if the HTTP method is not one of
  /// the supported methods: GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD.
  ///
  /// Returns: The [HttpMethod] enum value corresponding to the request method
  ///
  /// Example:
  /// ```dart
  /// if (request.httpMethod == HttpMethod.post) {
  ///   // Handle POST
  /// }
  /// ```
  HttpMethod get httpMethod {
    return HttpMethod.values.firstWhere(
      (m) => m.value == method.toUpperCase(),
      orElse: () => throw UnsupportedHttpMethodException(method),
    );
  }

  /// Returns connection information for the associated HTTP request.
  ///
  /// Provides details about the socket connection such as remote and local addresses.
  /// Returns `null` if connection information is not available.
  ///
  /// Returns: A [HttpConnectionInfo] object or `null`
  HttpConnectionInfo? get connectionInfo {
    return context['shelf.io.connection_info'] as HttpConnectionInfo?;
  }
}
