import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupertino_anchor/cupertino_anchor.dart';

class TestUser {
  final int id;
  final String name;
  const TestUser(this.id, this.name);

  @override
  String toString() => name;
}

void main() {
  group('CupertinoDropdown Widget Tests', () {
    testWidgets('Renders anchor field with hint when value is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: CupertinoDropdown<String>(
                items: const ['Apple', 'Banana', 'Cherry'],
                hint: 'Pick a fruit',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pick a fruit'), findsOneWidget);
    });

    testWidgets('Tapping anchor opens overlay and selecting item invokes onChanged and closes', (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: CupertinoDropdown<String>(
                items: const ['Option 1', 'Option 2', 'Option 3'],
                value: selectedValue,
                hint: 'Select',
                onChanged: (String val) {
                  selectedValue = val;
                },
              ),
            ),
          ),
        ),
      );

      // Tap to open
      await tester.tap(find.text('Select'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // Finish opening animation

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);

      // Tap Option 2
      await tester.tap(find.text('Option 2'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // Finish closing animation

      expect(selectedValue, 'Option 2');
      // Overlay is closed
      expect(find.text('Option 1'), findsNothing);
    });

    testWidgets('Disabled items cannot be selected', (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: CupertinoDropdown<String>(
                items: const ['Active 1', 'Disabled 2', 'Active 3'],
                isItemDisabled: (item) => item == 'Disabled 2',
                onChanged: (String val) {
                  selectedValue = val;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoDropdown<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disabled 2'));
      await tester.pump();

      expect(selectedValue, isNull);
      // Popup remains open
      expect(find.text('Active 1'), findsOneWidget);
    });

    testWidgets('Controller programmatically opens and closes dropdown', (WidgetTester tester) async {
      final CupertinoDropdownController controller = CupertinoDropdownController();

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: CupertinoDropdown<String>(
                controller: controller,
                items: const ['Alpha', 'Beta'],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(controller.isOpen, isFalse);

      controller.open();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.isOpen, isTrue);
      expect(find.text('Alpha'), findsOneWidget);

      controller.close();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.isOpen, isFalse);
      expect(find.text('Alpha'), findsNothing);
    });

    testWidgets('Rapid tapping does not cause duplicate overlays or exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: CupertinoDropdown<String>(
                items: const ['Item 1', 'Item 2'],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      for (int i = 0; i < 6; i++) {
        await tester.tap(find.byType(CupertinoDropdown<String>));
        await tester.pump(const Duration(milliseconds: 30));
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Custom generic models with itemBuilder work seamlessly', (WidgetTester tester) async {
      const List<TestUser> users = [
        TestUser(1, 'Alice Smith'),
        TestUser(2, 'Bob Jones'),
      ];
      TestUser? selectedUser = users.first;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: CupertinoDropdown<TestUser>(
                items: users,
                value: selectedUser,
                itemBuilder: (context, user) {
                  return Row(
                    children: [
                      const Icon(CupertinoIcons.person),
                      const SizedBox(width: 6),
                      Text(user.name),
                    ],
                  );
                },
                onChanged: (user) {
                  selectedUser = user;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Alice Smith'), findsOneWidget);
    });
  });
}
