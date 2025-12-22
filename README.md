# shelf_essentials

![license](https://img.shields.io/github/license/k-arindam/shelf_essentials)
![dart](https://img.shields.io/badge/Dart-3%2B-blue)

**Essential utilities for building HTTP servers with `shelf`.**

`shelf_essentials` provides commonly needed extensions and helpers for:
- Reading request bodies
- Parsing JSON requests
- Handling multipart form data
- Working with HTTP methods safely

Designed to be **lightweight**, **idiomatic**, and **shelf-native**.

---

## Features

- 🔌 `Request` extensions for body, JSON, and form data
- 📦 Multipart form parsing with fields & files
- 🧭 Type-safe HTTP method enum
- 🧱 Zero framework lock-in
- ⚡ Minimal dependencies

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  shelf_essentials: ^1.0.0
```

Then run:

```bash
dart pub get
```

---

## Usage

### Import

```dart
import 'package:shelf_essentials/shelf_essentials.dart';
```

---

## Request Extensions

### Read Request Body

```dart
final body = await request.body();
```

---

### Parse JSON Body

```dart
final data = await request.json();

print(data['email']);
```

> The returned value can be a `Map`, `List`, `String`, `num`, or `bool`.

---

### Access HTTP Method Safely

```dart
switch (request.httpMethod) {
  case HttpMethod.get:
    return Response.ok('GET request');
  case HttpMethod.post:
    return Response.ok('POST request');
  default:
    return Response.notFound('Unsupported method');
}
```

---

## Form Data Handling

### Parse Multipart Form Data

```dart
final form = await request.formData();
```

---

### Access Fields

```dart
final username = form.fields['username'];
final email = form.fields['email'];
```

---

### Access Uploaded Files

```dart
final avatar = form.files['avatar'];

if (avatar != null) {
  final bytes = await avatar.readAsBytes();
  print('Uploaded file: ${avatar.name}');
}
```

---

## CORS Headers

### Enable CORS for All Origins

Add CORS headers to all responses with default settings:

```dart
final handler = Pipeline()
  .addMiddleware(corsHeaders())
  .addHandler((request) => Response.ok('Hello'));
```

---

### Restrict CORS to Specific Origins

Allow CORS only from specific origins:

```dart
final handler = Pipeline()
  .addMiddleware(corsHeaders(
    originChecker: originOneOf(['https://example.com', 'https://app.example.com']),
  ))
  .addHandler((request) => Response.ok('Hello'));
```

---

### Add Custom Headers

Include additional custom headers in CORS responses:

```dart
final handler = Pipeline()
  .addMiddleware(corsHeaders(
    addedHeaders: {
      'X-Custom-Header': 'custom-value',
      'Access-Control-Allow-Credentials': 'true',
    },
    originChecker: originOneOf(['https://example.com']),
  ))
  .addHandler((request) => Response.ok('Hello'));
```

---

### CORS Defaults

When using `corsHeaders` middleware, the following defaults are applied:

- **Allowed Methods**: DELETE, GET, OPTIONS, PATCH, POST, PUT
- **Allowed Headers**: accept, accept-encoding, authorization, content-type, dnt, origin, user-agent
- **Credentials**: true
- **Max-Age**: 86400 seconds (24 hours)

---

## UploadedFile

Each uploaded file provides:

```dart
final name = file.name;
final contentType = file.contentType;
final bytes = await file.readAsBytes();
```

⚠️ **Note:**  
File streams are **single-use**. Call either `readAsBytes()` **or** `openRead()` once.

---

### API Overview

| Feature | Description |
|---------|------------|
| **Request Extensions** | Methods to read body, parse JSON, handle forms, access HTTP method |
| **CORS Middleware** | Add CORS headers with origin validation |
| **Form Data Parsing** | Support for URL-encoded and multipart form data |
| **Uploaded Files** | Access file name, content-type, and read contents |
| **HTTP Methods** | Type-safe enum for common HTTP methods |

---

#### RequestExtension Methods

| Method | Returns | Description |
|--------|---------|------------|
| `body()` | `Future<String>` | Reads request body as String |
| `json()` | `Future<dynamic>` | Parses body as JSON (Map, List, String, num, bool) |
| `formData()` | `Future<FormData>` | Parses multipart or URL-encoded form data |
| `httpMethod` | `HttpMethod` | Type-safe HTTP method enum |
| `connectionInfo` | `HttpConnectionInfo?` | Socket connection information |

---

#### CORS Functions

| Function | Description |
|----------|------------|
| `corsHeaders()` | Middleware to add CORS headers to responses |
| `originAllowAll()` | Origin checker that allows all origins |
| `originOneOf()` | Origin checker that allows specific origins |

---

## Example Shelf Server

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_essentials/shelf_essentials.dart';

void main() async {
  final handler = (Request request) async {
    if (request.httpMethod == HttpMethod.post) {
      final data = await request.json();
      return Response.ok('Hello ${data['name']}');
    }
    return Response.ok('Send a POST request');
  };

  await serve(handler, 'localhost', 8080);
  print('Server running on http://localhost:8080');
}
```

---

## Design Goals

- ✅ Minimal surface area
- ✅ Idiomatic Dart
- ✅ Shelf-first
- ✅ No hidden magic
- ✅ Easy to extend

---

## Roadmap

- Content-Type validation helpers
- Typed JSON parsing utilities
- Streaming file size helpers
- Improved error handling
- Middleware utilities

---

## Contributing

Contributions are welcome!

- Open an issue for bugs or feature requests
- Submit a PR with clear description and tests
- Keep APIs simple and shelf-compatible

---

## License

MIT License © 2025  
Use it freely in open-source and commercial projects.

---

## Acknowledgements

- Inspired by the simplicity of the [`shelf`](https://pub.dev/packages/shelf) package
- Special thanks to [`dart-frog`](https://dart-frog.dev)
- Special thanks to [`shelf-cors-headers`](https://github.com/lenniezelk/shelf-cors-headers)
