# Content Disposition Package Instructions

Small published pure-Dart parser for the practical RFC 6266/RFC 5987 subset.

- Keep it cross-platform: no `dart:io`, Flutter dependency or platform branches.
- Preserve `filename*` precedence over `filename`, quoted-value parsing and safe percent decoding.
- Prefer the current single public API over new abstractions or dependencies.
- Every parser behavior change needs a focused regression case in `test/content_disposition_test.dart` and a changelog entry when release-facing.

```bash
dart analyze
dart test
```
