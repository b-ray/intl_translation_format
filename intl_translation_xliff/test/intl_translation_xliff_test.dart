import 'package:intl_translation_format/intl_translation_format.dart';
import 'package:intl_translation_xliff/intl_translation_xliff.dart';
import 'package:intl_translation_xliff/src/parser/xliff_parser.dart';
import 'package:test/test.dart';

import 'xliff_v2_test.dart' as xliff2;
import 'xliff_v1_test.dart' as xliff1;

import 'xliff_v2_multi_test.dart' as xliff2_multi;
import 'xliff_v1_multi_test.dart' as xliff1_multi;

final _xliffAttributes = attributesForVersion(XliffVersion.v2).entries
    .map((e) => '${e.key}="${e.value}"')
    .reduce((value, element) => '$value $element');

void main() {
  xliff2.main();
  xliff1.main();

  xliff2_multi.main();
  xliff1_multi.main();
  
  group('Xliff parser:', () {
    test('Nested <xliff> not allowed', () async {
      final content = '''
          <?xml version="1.0 encoding="UTF-8""?>
          <xliff $_xliffAttributes version="2.0" srcLang="en">
          <xliff $_xliffAttributes version="2.0"  srcLang="en">
          </xliff>
          </xliff>
      ''';
      try {
        XliffParser(displayWarnings: false).parse(content);
      } on XliffParserException catch (e) {
        expect(e.title, 'Unsupported nested <xliff> element.');
        return;
      }
      throw 'Expected an error';
    });

    test('Required attribute version is missing in <xliff>', () async {
      final content = '''
          <?xml version="1.0 encoding="UTF-8""?>
          <xliff  srcLang="en" $_xliffAttributes>
          </xliff>
      ''';
      try {
        XliffParser(displayWarnings: false).parse(content);
      } on XliffParserException catch (e) {
        expect(e.title, 'version attribute is required for <xliff>');
        return;
      }
      throw 'Expected an error';
    });

    test('Wrong xliff version in format', () async {
      final content = '''
          <?xml version="1.0 encoding="UTF-8""?>
          <xliff  source-language="en" $_xliffAttributes version="2.0">
          </xliff>
      ''';
      try {
        XliffParser(displayWarnings: false, version: XliffVersion.v1)
            .parse(content);
      } on XliffParserException catch (e) {
        expect(e.title, 'Invalid Xliff version parser');
        return;
      }
      throw 'Expected an error';
    });

   
  });
}

const xliffBasicMessage = '''
<?xml version="1.0 encoding="UTF-8""?>
<xliff xmlns="urn:oasis:names:tc:xliff:document:2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="urn:oasis:names:tc:xliff:document:2.0 http://docs.oasis-open.org/xliff/xliff-core/v2.0/os/schemas/xliff_core_2.0.xsd" srcLang="en">
  <file>
    <unit id="text" name="text">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>normal Text</source>
      </segment>
    </unit>
    <unit id="textWithMetadata" name="textWithMetadata">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>text With Metadata</source>
      </segment>
    </unit>
    <unit id="pluralExample" name="pluralExample">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>{howMany,plural, =0{No items}=1{One item}many{A lot of items}other{{howMany} items}}</source>
      </segment>
    </unit>
    <unit id="variable" name="variable">
      <segment>
        <notes>
          <note category="format">icu</note>
        </notes>
        <source>Hello {variable}</source>
      </segment>
    </unit>
  </file>
</xliff>''';