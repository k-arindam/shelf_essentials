/// Essential utilities for building HTTP servers with [shelf](https://pub.dev/packages/shelf).
///
/// This package provides commonly needed extensions and helpers for:
/// - Reading request bodies
/// - Parsing JSON requests
/// - Handling multipart form data
/// - Working with HTTP methods safely
/// - Adding CORS headers to responses
///
/// ## Features
///
/// - 🔌 [RequestExtension] for body, JSON, and form data
/// - 📦 Multipart form parsing with fields & files
/// - 🧭 Type-safe [HttpMethod] enum
/// - 🔐 CORS headers middleware
/// - 🔧 Zero framework lock-in
/// - ⚡ Minimal dependencies
///
/// ## Quick Start
///
/// ```dart
/// import 'package:shelf/shelf.dart';
/// import 'package:shelf/shelf_io.dart';
/// import 'package:shelf_essentials/shelf_essentials.dart';
///
/// void main() async {
///   final handler = (Request request) async {
///     switch (request.httpMethod) {
///       case HttpMethod.get:
///         return Response.ok('Hello World');
///       case HttpMethod.post:
///         final data = await request.json();
///         return Response.ok('Received: ${data}');
///       default:
///         return Response.notFound('Not Found');
///     }
///   };
///
///   await serve(handler, 'localhost', 8080);
/// }
/// ```
library;

export 'src/request_extension.dart' show RequestExtension;
export 'src/form_data.dart' show FormData, UploadedFile;
export 'src/http_method.dart' show HttpMethod;
export 'src/cors_headers.dart' show corsHeaders, originOneOf, OriginChecker;
