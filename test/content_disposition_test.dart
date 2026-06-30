import 'package:content_disposition/content_disposition.dart';
import 'package:test/test.dart';

void main() {
  group('ContentDisposition.filenameOf', () {
    test('returns null for null or blank', () {
      expect(ContentDisposition.filenameOf(null), isNull);
      expect(ContentDisposition.filenameOf('   '), isNull);
    });

    test('parses quoted filename', () {
      expect(
        ContentDisposition.filenameOf('attachment; filename="danfse.pdf"'),
        'danfse.pdf',
      );
    });

    test('parses unquoted filename', () {
      expect(
        ContentDisposition.filenameOf('attachment; filename=nfse.xml'),
        'nfse.xml',
      );
    });

    test('inline disposition', () {
      expect(
        ContentDisposition.filenameOf('inline; filename="danfse.pdf"'),
        'danfse.pdf',
      );
    });

    test('returns null when no filename param', () {
      expect(ContentDisposition.filenameOf('attachment'), isNull);
    });

    test('keeps semicolons inside quotes', () {
      expect(
        ContentDisposition.filenameOf('attachment; filename="a;b.pdf"'),
        'a;b.pdf',
      );
    });

    test('unescapes escaped quotes', () {
      expect(
        ContentDisposition.filenameOf(r'attachment; filename="a\"b.pdf"'),
        'a"b.pdf',
      );
    });

    test('filename* (UTF-8) takes precedence and is decoded', () {
      expect(
        ContentDisposition.filenameOf(
          "attachment; filename=\"fallback.pdf\"; filename*=UTF-8''fa%C3%A7ura.pdf",
        ),
        'façura.pdf',
      );
    });

    test('filename* with latin1 charset', () {
      expect(
        ContentDisposition.filenameOf("attachment; filename*=ISO-8859-1''a%E9.txt"),
        'aé.txt',
      );
    });

    test('case-insensitive parameter name', () {
      expect(
        ContentDisposition.filenameOf('attachment; FileName="x.pdf"'),
        'x.pdf',
      );
    });
  });

  group('ContentDisposition.parse', () {
    test('exposes lower-cased type and params', () {
      final cd = ContentDisposition.parse('Attachment; filename="x.pdf"')!;
      expect(cd.type, 'attachment');
      expect(cd.filename, 'x.pdf');
    });
  });
}
