## 1.0.1

* Add CORS headers middleware for cross-origin request support
* Add `corsHeaders()` middleware function with origin validation
* Add `originAllowAll()` for unrestricted CORS
* Add `originOneOf()` for origin whitelist validation
* Improve dartdoc documentation for all public APIs
* Enhance README with CORS usage examples and API reference

## 1.0.0

* Initial release
* Add `RequestExtension` with methods for reading body, parsing JSON, handling form data
* Add `HttpMethod` enum for type-safe HTTP method handling
* Add `FormData` class for parsing URL-encoded and multipart form data
* Add `UploadedFile` class for accessing uploaded files
* Add `UnsupportedHttpMethodException` for unsupported HTTP methods
