import 'package:shelf/shelf.dart';

/// Header name for Access-Control-Allow-Origin
const accessControlAllowOrigin = 'Access-Control-Allow-Origin';

/// Header name for Access-Control-Expose-Headers
const accessControlExposeHeaders = 'Access-Control-Expose-Headers';

/// Header name for Access-Control-Allow-Credentials
const accessControlAllowCredentials = 'Access-Control-Allow-Credentials';

/// Header name for Access-Control-Allow-Headers
const accessControlAllowHeaders = 'Access-Control-Allow-Headers';

/// Header name for Access-Control-Allow-Methods
const accessControlAllowMethods = 'Access-Control-Allow-Methods';

/// Header name for Access-Control-Max-Age
const accessControlMaxAge = 'Access-Control-Max-Age';

/// Header name for Vary
const vary = 'Vary';

/// Header name for Origin (lowercase as per HTTP header convention)
const originHeader = 'origin';

const _defaultHeadersList = [
  'accept',
  'accept-encoding',
  'authorization',
  'content-type',
  'dnt',
  'origin',
  'user-agent',
];

const _defaultMethodsList = ['DELETE', 'GET', 'OPTIONS', 'PATCH', 'POST', 'PUT'];

Map<String, String> _defaultHeaders = {
  accessControlExposeHeaders: '',
  accessControlAllowCredentials: 'true',
  accessControlAllowHeaders: _defaultHeadersList.join(','),
  accessControlAllowMethods: _defaultMethodsList.join(','),
  accessControlMaxAge: '86400',
};

final _defaultHeadersAll = _defaultHeaders.map((key, value) => MapEntry(key, [value]));

/// A function type that validates whether a given origin is allowed.
///
/// Returns `true` if the origin should be allowed, `false` otherwise.
typedef OriginChecker = bool Function(String origin);

/// Default origin checker that allows all origins.
///
/// Use this with [corsHeaders] to allow CORS requests from any origin.
bool originAllowAll(String origin) => true;

/// Creates an [OriginChecker] that allows only specific origins.
///
/// Example:
/// ```dart
/// final checker = originOneOf(['https://example.com', 'https://app.example.com']);
/// ```
OriginChecker originOneOf(List<String> origins) =>
    (origin) => origins.contains(origin);

/// A Shelf middleware that adds CORS (Cross-Origin Resource Sharing) headers to responses.
///
/// This middleware automatically:
/// - Validates the request origin using the provided [originChecker]
/// - Adds appropriate CORS headers for valid origins
/// - Handles CORS preflight (OPTIONS) requests
/// - Supports custom headers via [addedHeaders]
///
/// Parameters:
/// - [addedHeaders]: Additional custom headers to include in CORS responses
/// - [originChecker]: Function to validate if an origin is allowed (defaults to [originAllowAll])
///
/// Default allowed headers: accept, accept-encoding, authorization, content-type, dnt, origin, user-agent
/// Default allowed methods: DELETE, GET, OPTIONS, PATCH, POST, PUT
/// Default max-age: 86400 seconds (24 hours)
/// Default credentials: true
///
/// Example:
/// ```dart
/// final handler = Pipeline()
///   .addMiddleware(corsHeaders(
///     originChecker: originOneOf(['https://example.com']),
///     addedHeaders: {'X-Custom-Header': 'value'},
///   ))
///   .addHandler((request) => Response.ok('Hello'));
/// ```
Middleware corsHeaders({Map<String, String>? addedHeaders, OriginChecker originChecker = originAllowAll}) {
  final headersAll = addedHeaders?.map((key, value) => MapEntry(key, [value]));
  return (Handler handler) {
    return (Request request) async {
      final origin = request.headers[originHeader];

      if (origin == null || !originChecker(origin)) {
        return handler(request);
      }

      final headers = <String, List<String>>{..._defaultHeadersAll, ...?headersAll};

      final userProvidedAccessControlAllowOrigin = addedHeaders?[accessControlAllowOrigin];

      if (userProvidedAccessControlAllowOrigin != null) {
        headers[accessControlAllowOrigin] = [userProvidedAccessControlAllowOrigin];
        headers[vary] = ['Origin'];
      } else {
        headers[accessControlAllowOrigin] = [origin];
      }

      if (request.method == 'OPTIONS') {
        return Response.ok(null, headers: headers);
      }

      final response = await handler(request);

      return response.change(headers: {...headers, ...response.headersAll});
    };
  };
}
