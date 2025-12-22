import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

/// Content-Type for URL-encoded form data: `application/x-www-form-urlencoded`
final formUrlEncodedContentType = ContentType('application', 'x-www-form-urlencoded');

/// Content-Type for multipart form data: `multipart/form-data`
final multipartFormDataContentType = ContentType('multipart', 'form-data');

/// Parses the request body as form data.
///
/// Supports both:
/// - `application/x-www-form-urlencoded`
/// - `multipart/form-data`
///
/// Parameters:
/// - [headers]: The request headers (must include content-type)
/// - [body]: A function that returns the request body as a String
/// - [bytes]: A function that returns the request body as a byte stream
///
/// Returns: A [Future] containing a [FormData] object with parsed fields and files
///
/// Throws: [StateError] if the MIME type is not supported
///
/// See: https://fetch.spec.whatwg.org/#ref-for-dom-body-formdata%E2%91%A0
Future<FormData> parseFormData({
  required Map<String, String> headers,
  required Future<String> Function() body,
  required Stream<List<int>> Function() bytes,
}) async {
  final contentType = _extractContentType(headers);
  final isFormUrlEncoded = _isFormUrlEncoded(contentType);
  final isMultipartFormData = _isMultipartFormData(contentType);

  if (!isFormUrlEncoded && !isMultipartFormData) {
    throw StateError('''
Body could not be parsed as form data due to an invalid MIME type.
Expected MIME type: "${formUrlEncodedContentType.mimeType}" OR "${multipartFormDataContentType.mimeType}"
Actual MIME type: "${contentType?.mimeType ?? ''}"
''');
  }

  return isFormUrlEncoded
      ? _extractFormUrlEncodedFormData(body: await body())
      : await _extractMultipartFormData(headers: headers, bytes: bytes());
}

ContentType? _extractContentType(Map<String, String> headers) {
  final contentTypeValue = headers[HttpHeaders.contentTypeHeader];
  if (contentTypeValue == null) return null;
  return ContentType.parse(contentTypeValue);
}

bool _isFormUrlEncoded(ContentType? contentType) {
  if (contentType == null) return false;
  return contentType.mimeType == formUrlEncodedContentType.mimeType;
}

bool _isMultipartFormData(ContentType? contentType) {
  if (contentType == null) return false;
  return contentType.mimeType == multipartFormDataContentType.mimeType;
}

FormData _extractFormUrlEncodedFormData({required String body}) {
  return FormData(fields: Uri.splitQueryString(body), files: {});
}

final _keyValueRegexp = RegExp('(?:(?<key>[a-zA-Z0-9-_]+)="(?<value>.*?)";*)+');

Future<FormData> _extractMultipartFormData({
  required Map<String, String> headers,
  required Stream<List<int>> bytes,
}) async {
  final contentType = headers[HttpHeaders.contentTypeHeader]!;
  final mediaType = MediaType.parse(contentType);
  final boundary = mediaType.parameters['boundary'];
  final transformer = MimeMultipartTransformer(boundary!);

  final fields = <String, String>{};
  final files = <String, UploadedFile>{};

  await for (final part in transformer.bind(bytes)) {
    final contentDisposition = part.headers['content-disposition'];
    if (contentDisposition == null) continue;
    if (!contentDisposition.startsWith('form-data;')) continue;

    final values = _keyValueRegexp.allMatches(contentDisposition).fold(<String, String>{}, (map, match) {
      return map..[match.namedGroup('key')!] = match.namedGroup('value')!;
    });

    final name = values['name']!;
    final fileName = values['filename'];

    if (fileName != null) {
      files[name] = UploadedFile(fileName, ContentType.parse(part.headers['content-type'] ?? 'text/plain'), part);
    } else {
      final bytes = (await part.toList()).fold(<int>[], (p, e) => p..addAll(e));
      fields[name] = utf8.decode(bytes);
    }
  }

  return FormData(fields: fields, files: files);
}

/// {@template form_data}
/// The fields and files of received form data request.
/// {@endtemplate}
class FormData with MapMixin<String, String> {
  /// {@macro form_data}
  const FormData({required Map<String, String> fields, required Map<String, UploadedFile> files})
    : _fields = fields,
      _files = files;

  final Map<String, String> _fields;

  final Map<String, UploadedFile> _files;

  /// The fields that were submitted in the form.
  Map<String, String> get fields => Map.unmodifiable(_fields);

  /// The files that were uploaded in the form.
  Map<String, UploadedFile> get files => Map.unmodifiable(_files);

  @override
  @Deprecated('Use `fields[key]` to retrieve values')
  String? operator [](Object? key) => _fields[key] ?? _files[key]?.toString();

  @override
  @Deprecated('Use `fields.keys` to retrieve field keys')
  Iterable<String> get keys => _fields.keys;

  @override
  @Deprecated('Use `fields.values` to retrieve field values')
  Iterable<String> get values => _fields.values;

  @override
  @Deprecated('FormData should be immutable, in the future this will thrown an error')
  void operator []=(String key, String value) => _fields[key] = value;

  @override
  @Deprecated('FormData should be immutable, in the future this will thrown an error')
  void clear() => _fields.clear();

  @override
  @Deprecated('FormData should be immutable, in the future this will thrown an error')
  String? remove(Object? key) => _fields.remove(key);
}

/// {@template uploaded_file}
/// Represents an uploaded file from a form data request.
///
/// Provides access to the file name, content type, and file contents via stream or bytes.
/// {@endtemplate}
class UploadedFile {
  /// {@macro uploaded_file}
  const UploadedFile(this.name, this.contentType, this._byteStream);

  /// The name of the uploaded file.
  final String name;

  /// The MIME type of the uploaded file.
  final ContentType contentType;

  final Stream<List<int>> _byteStream;

  /// Read the content of the file as a list of bytes.
  ///
  /// Can only be called once. After calling this method, [openRead] cannot be used.
  ///
  /// Returns: A [Future] containing the file contents as bytes
  Future<List<int>> readAsBytes() async {
    return (await _byteStream.toList()).fold<List<int>>([], (p, e) => p..addAll(e));
  }

  /// Open the content of the file as a stream of bytes.
  ///
  /// Can only be called once. After calling this method, [readAsBytes] cannot be used.
  ///
  /// Returns: A [Stream] of byte lists
  Stream<List<int>> openRead() => _byteStream;

  @override
  String toString() {
    return '{ name: $name, contentType: $contentType }';
  }
}
