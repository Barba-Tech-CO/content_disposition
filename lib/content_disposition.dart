/// Cross-platform parser for the HTTP `Content-Disposition` header.
///
/// Pure Dart (no `dart:io`), so it works on web, mobile and desktop alike.
/// Implements the parts of RFC 6266 that matter in practice: the disposition
/// type and the `filename` / `filename*` parameters, with `filename*` (RFC 5987
/// extended notation) taking precedence over the plain `filename`.
library;

import 'dart:convert';

/// A parsed `Content-Disposition` header.
class ContentDisposition {
  /// The disposition type (e.g. `attachment`, `inline`, `form-data`),
  /// lower-cased. Empty when the header has no type.
  final String type;

  /// The parameters keyed by their lower-cased name. For `filename*` the value
  /// is already decoded; the key is normalized to `filename`.
  final Map<String, String> parameters;

  const ContentDisposition({required this.type, required this.parameters});

  /// The best available filename: `filename*` when present (decoded), otherwise
  /// the plain `filename`. Returns `null` when neither is present.
  String? get filename {
    final value = parameters['filename'];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Parses [header]. Returns `null` when [header] is `null` or blank.
  static ContentDisposition? parse(String? header) {
    if (header == null) return null;
    final trimmedHeader = header.trim();
    if (trimmedHeader.isEmpty) return null;

    final segments = _splitTopLevel(trimmedHeader);
    final type = segments.isEmpty ? '' : segments.first.trim().toLowerCase();

    final params = <String, String>{};
    String? extendedFilename;
    String? plainFilename;

    for (var i = 1; i < segments.length; i++) {
      final segment = segments[i].trim();
      final eq = segment.indexOf('=');
      if (eq <= 0) continue;
      final key = segment.substring(0, eq).trim().toLowerCase();
      final rawValue = segment.substring(eq + 1).trim();

      if (key == 'filename*') {
        extendedFilename = _decodeExtended(rawValue) ?? extendedFilename;
      } else if (key == 'filename') {
        plainFilename = _unquote(rawValue);
        params[key] = plainFilename;
      } else {
        params[key] = _unquote(rawValue);
      }
    }

    final filename = extendedFilename ?? plainFilename;
    if (filename != null && filename.isNotEmpty) {
      params['filename'] = filename;
    }

    return ContentDisposition(type: type, parameters: params);
  }

  /// Convenience: the filename from [header], or `null`.
  static String? filenameOf(String? header) => parse(header)?.filename;

  /// Splits on `;` that are not inside a double-quoted string.
  static List<String> _splitTopLevel(String input) {
    final parts = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    var escaped = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (escaped) {
        buffer.write(char);
        escaped = false;
        continue;
      }
      if (char == r'\' && inQuotes) {
        buffer.write(char);
        escaped = true;
        continue;
      }
      if (char == '"') {
        inQuotes = !inQuotes;
        buffer.write(char);
        continue;
      }
      if (char == ';' && !inQuotes) {
        parts.add(buffer.toString());
        buffer.clear();
        continue;
      }
      buffer.write(char);
    }
    parts.add(buffer.toString());
    return parts;
  }

  /// Removes surrounding quotes and unescapes `\"` / `\\` from a quoted-string.
  static String _unquote(String value) {
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      final inner = value.substring(1, value.length - 1);
      final buffer = StringBuffer();
      var escaped = false;
      for (var i = 0; i < inner.length; i++) {
        final char = inner[i];
        if (escaped) {
          buffer.write(char);
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else {
          buffer.write(char);
        }
      }
      return buffer.toString();
    }
    return value;
  }

  /// Decodes an RFC 5987 ext-value: `charset "'" [language] "'" value-chars`,
  /// e.g. `UTF-8''fa%C3%A7ura.pdf`. Returns `null` when malformed.
  static String? _decodeExtended(String value) {
    final firstQuote = value.indexOf("'");
    if (firstQuote < 0) return null;
    final secondQuote = value.indexOf("'", firstQuote + 1);
    if (secondQuote < 0) return null;

    final charset = value.substring(0, firstQuote).toLowerCase();
    final encoded = value.substring(secondQuote + 1);
    final bytes = _percentDecodeToBytes(encoded);
    if (bytes == null) return null;

    try {
      switch (charset) {
        case 'utf-8':
        case '':
          return utf8.decode(bytes);
        case 'iso-8859-1':
        case 'latin1':
          return latin1.decode(bytes);
        default:
          return utf8.decode(bytes, allowMalformed: true);
      }
    } catch (_) {
      return null;
    }
  }

  /// Percent-decodes [input] into raw bytes (does not assume an encoding).
  static List<int>? _percentDecodeToBytes(String input) {
    final bytes = <int>[];
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '%') {
        if (i + 2 >= input.length) return null;
        final hex = input.substring(i + 1, i + 3);
        final byte = int.tryParse(hex, radix: 16);
        if (byte == null) return null;
        bytes.add(byte);
        i += 2;
      } else {
        bytes.addAll(utf8.encode(char));
      }
    }
    return bytes;
  }
}
