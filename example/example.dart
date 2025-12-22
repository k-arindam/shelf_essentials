import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_essentials/shelf_essentials.dart';

void main() async {
  // Create a comprehensive handler demonstrating all shelf_essentials features
  final handler = Pipeline()
      .addMiddleware(
        corsHeaders(
          originChecker: originOneOf(['http://localhost:3000', 'http://localhost:8080']),
          addedHeaders: {'X-API-Version': '1.0.1'},
        ),
      )
      .addHandler(_handleRequest);

  final _ = await serve(handler, 'localhost', 8080);
}

Future<Response> _handleRequest(Request request) async {
  // Demonstrate HttpMethod enum usage
  switch (request.httpMethod) {
    case HttpMethod.get:
      return _handleGet(request);
    case HttpMethod.post:
      return await _handlePost(request);
    default:
      return Response.notFound('Method not supported');
  }
}

Response _handleGet(Request request) {
  final path = request.url.path;

  switch (path) {
    case 'hello':
      return Response.ok('Hello from shelf_essentials!');

    case 'method':
      // Demonstrate httpMethod property
      return Response.ok('HTTP Method: ${request.httpMethod.value}');

    case 'info':
      // Demonstrate connectionInfo property
      final info = request.connectionInfo;
      if (info != null) {
        return Response.ok(
          jsonEncode({
            'remoteAddress': info.remoteAddress.address,
            'remotePort': info.remotePort,
            'localPort': info.localPort,
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      return Response.ok('No connection info available');

    default:
      return Response.notFound('GET endpoint not found');
  }
}

Future<Response> _handlePost(Request request) async {
  final path = request.url.path;

  switch (path) {
    case 'json':
      return await _handleJsonPost(request);
    case 'form':
      return await _handleFormPost(request);
    case 'upload':
      return await _handleFileUpload(request);
    default:
      return Response.notFound('POST endpoint not found');
  }
}

Future<Response> _handleJsonPost(Request request) async {
  try {
    // Demonstrate json() method from RequestExtension
    final data = await request.json();

    // Handle different JSON types
    if (data is Map) {
      final name = data['name'] ?? 'Anonymous';
      final age = data['age'];
      return Response.ok('Hello $name${age != null ? ", age $age" : ""}!');
    } else if (data is List) {
      return Response.ok('Received list with ${data.length} items');
    } else {
      return Response.ok('Received: $data');
    }
  } catch (e) {
    return Response.badRequest(body: 'Invalid JSON: $e');
  }
}

Future<Response> _handleFormPost(Request request) async {
  try {
    // Demonstrate formData() method from RequestExtension
    final form = await request.formData();

    final username = form.fields['username'] ?? 'Unknown';
    final email = form.fields['email'] ?? 'No email';
    final message = form.fields['message'] ?? 'No message';

    return Response.ok(
      'Form received:\n'
      'Username: $username\n'
      'Email: $email\n'
      'Message: $message',
    );
  } catch (e) {
    return Response.badRequest(body: 'Invalid form data: $e');
  }
}

Future<Response> _handleFileUpload(Request request) async {
  try {
    // Demonstrate formData() method with file uploads
    final form = await request.formData();

    final files = form.files;
    if (files.isEmpty) {
      return Response.badRequest(body: 'No files uploaded');
    }

    final results = <String>[];

    // Demonstrate UploadedFile usage
    for (final entry in files.entries) {
      final fieldName = entry.key;
      final UploadedFile file = entry.value;

      // Read file as bytes (demonstrates readAsBytes())
      final bytes = await file.readAsBytes();
      final size = bytes.length;

      results.add(
        'Field: $fieldName\n'
        '  Name: ${file.name}\n'
        '  Content-Type: ${file.contentType}\n'
        '  Size: $size bytes\n'
        '  First 50 bytes: ${bytes.take(50).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );
    }

    return Response.ok('Files uploaded:\n\n${results.join('\n\n')}');
  } catch (e) {
    return Response.badRequest(body: 'File upload failed: $e');
  }
}
