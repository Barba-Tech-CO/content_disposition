# content_disposition

Cross-platform (web, mobile, desktop) parser for the HTTP `Content-Disposition`
header. Pure Dart — no `dart:io` — so it works the same in a browser and on
native targets.

Implements the practical subset of RFC 6266: the disposition type and the
`filename` / `filename*` parameters. `filename*` (RFC 5987 extended notation,
e.g. `UTF-8''fa%C3%A7ura.pdf`) is decoded and takes precedence over a plain
`filename`.

## Usage

```dart
import 'package:content_disposition/content_disposition.dart';

final name = ContentDisposition.filenameOf('attachment; filename="danfse.pdf"');
// -> 'danfse.pdf'

final cd = ContentDisposition.parse("attachment; filename*=UTF-8''fa%C3%A7ura.pdf")!;
cd.type;     // 'attachment'
cd.filename; // 'façura.pdf'
```

## Test

```bash
dart test
```
