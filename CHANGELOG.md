# Changelog

## 0.1.0

- Initial release.
- `ContentDisposition.parse` and `ContentDisposition.filenameOf`.
- RFC 6266 `filename` (quoted/unquoted, escaped quotes, quoted semicolons) and
  `filename*` (RFC 5987 `UTF-8`/`ISO-8859-1`, percent-decoded) with `filename*`
  taking precedence.
- Pure Dart, no `dart:io`; works on web, mobile and desktop.
