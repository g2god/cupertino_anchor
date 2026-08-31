import 'package:flutter_test/flutter_test.dart';
import 'package:cupertino_anchor/cupertino_anchor.dart';

void main() {
  test('exports core models and positioning engine', () {
    expect(DropdownDirection.auto, isNotNull);
    expect(DropdownDismissBehavior.closeWhenAnchorLeavesScreen, isNotNull);
    expect(CupertinoDropdownTheme, isNotNull);
  });
}
