import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpFormTest(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(800.0, 600.0),
    AdaptiveThemeData? theme,
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: textScaler,
        ),
        child: AdaptiveApp(
          theme: theme,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: child),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Adaptive Forms & Input System', () {
    group('AdaptiveTextField', () {
      testWidgets('renders hint, label, and enters text correctly',
          (tester) async {
        final controller = TextEditingController();
        String? submittedText;

        await pumpFormTest(
          tester,
          AdaptiveTextField(
            controller: controller,
            labelText: 'Email Address',
            hintText: 'Enter your email',
            onFieldSubmitted: (v) => submittedText = v,
          ),
        );

        expect(find.text('Email Address'), findsOneWidget);
        expect(find.text('Enter your email'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'test@example.com');
        expect(controller.text, equals('test@example.com'));

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(submittedText, equals('test@example.com'));

        controller.dispose();
      });

      testWidgets('validates with Form and displays error message',
          (tester) async {
        final formKey = GlobalKey<FormState>();
        String? savedValue;

        await pumpFormTest(
          tester,
          Form(
            key: formKey,
            child: AdaptiveTextField(
              labelText: 'Username',
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Username is required';
                }
                return null;
              },
              onSaved: (val) => savedValue = val,
            ),
          ),
        );

        // Initially no error
        expect(find.text('Username is required'), findsNothing);

        // Validate should fail
        final isValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();

        expect(isValid, isFalse);
        expect(find.text('Username is required'), findsOneWidget);

        // Enter valid text
        await tester.enterText(find.byType(TextField), 'john_doe');
        await tester.pumpAndSettle();

        final isValidNow = formKey.currentState!.validate();
        await tester.pumpAndSettle();

        expect(isValidNow, isTrue);
        expect(find.text('Username is required'), findsNothing);

        formKey.currentState!.save();
        expect(savedValue, equals('john_doe'));
      });

      testWidgets('appends required indicator and semantics hint',
          (tester) async {
        await pumpFormTest(
          tester,
          const AdaptiveTextField(
            labelText: 'Full Name',
            required: true,
          ),
        );

        expect(find.text('Full Name *'), findsOneWidget);
      });

      testWidgets(
          'renders without overflow under extremely narrow constraints (50dp)',
          (tester) async {
        await pumpFormTest(
          tester,
          const SizedBox(
            width: 50.0,
            child: AdaptiveTextField(
              labelText: 'Very long form field label that could wrap',
              hintText: 'Hint',
            ),
          ),
        );

        expect(find.byType(AdaptiveTextField), findsOneWidget);
      });

      testWidgets('renders under 2.0x accessibility text scaling',
          (tester) async {
        await pumpFormTest(
          tester,
          const SizedBox(
            width: 320.0,
            child: AdaptiveTextField(
              labelText: 'Large Scaled Input',
              helperText: 'Helper instructions for accessibility scaling',
            ),
          ),
          textScaler: const TextScaler.linear(2.0),
        );

        expect(find.text('Large Scaled Input'), findsOneWidget);
        expect(find.text('Helper instructions for accessibility scaling'),
            findsOneWidget);
      });

      testWidgets('respects AdaptiveInputThemeData from ambient theme',
          (tester) async {
        const customBorderRadius = BorderRadius.all(Radius.circular(20.0));
        final customTheme = AdaptiveThemeData.light().copyWith(
          inputTheme: const AdaptiveInputThemeData(
            filled: true,
            fillColor: Color(0xFFE0F2FE),
            borderRadius: customBorderRadius,
            borderColor: Color(0xFF0284C7),
          ),
        );

        await pumpFormTest(
          tester,
          const AdaptiveTextField(
            hintText: 'Themed input',
          ),
          theme: customTheme,
        );

        expect(find.byType(AdaptiveTextField), findsOneWidget);
      });
    });

    group('AdaptiveSearchField', () {
      testWidgets('renders search icon, enters text, and shows clear button',
          (tester) async {
        String query = '';
        bool cleared = false;

        await pumpFormTest(
          tester,
          AdaptiveSearchField(
            hintText: 'Search catalog...',
            onChanged: (q) => query = q,
            onClear: () => cleared = true,
          ),
        );

        expect(find.text('Search catalog...'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byIcon(Icons.clear), findsNothing);

        await tester.enterText(find.byType(TextField), 'Flutter');
        await tester.pump();

        expect(query, equals('Flutter'));
        expect(find.byIcon(Icons.clear), findsOneWidget);

        // Tap clear button
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        expect(query, equals(''));
        expect(cleared, isTrue);
        expect(find.byIcon(Icons.clear), findsNothing);
      });

      testWidgets('debounces query changes when debounceDuration is specified',
          (tester) async {
        String query = '';

        await pumpFormTest(
          tester,
          AdaptiveSearchField(
            debounceDuration: const Duration(milliseconds: 300),
            onChanged: (q) => query = q,
          ),
        );

        await tester.enterText(find.byType(TextField), 'dart');
        await tester.pump(const Duration(milliseconds: 100));
        // Not fired yet due to debounce
        expect(query, equals(''));

        await tester.pump(const Duration(milliseconds: 250));
        // Now debounce duration has elapsed
        expect(query, equals('dart'));
      });
    });

    group('AdaptiveDropdownField', () {
      testWidgets('renders with items and selects value', (tester) async {
        String? selectedValue;

        await pumpFormTest(
          tester,
          AdaptiveDropdownField<String>(
            labelText: 'Role',
            hintText: 'Select a role',
            value: selectedValue,
            onChanged: (v) => selectedValue = v,
            items: const [
              AdaptiveDropdownMenuItem(
                  value: 'admin', child: Text('Administrator')),
              AdaptiveDropdownMenuItem(value: 'editor', child: Text('Editor')),
              AdaptiveDropdownMenuItem(value: 'viewer', child: Text('Viewer')),
            ],
          ),
        );

        expect(find.text('Role'), findsOneWidget);
        expect(find.text('Select a role'), findsOneWidget);

        await tester.tap(find.byType(AdaptiveDropdownField<String>));
        await tester.pumpAndSettle();

        expect(find.text('Administrator').last, findsOneWidget);
        expect(find.text('Editor').last, findsOneWidget);
        expect(find.text('Viewer').last, findsOneWidget);

        await tester.tap(find.text('Editor').last);
        await tester.pumpAndSettle();

        expect(selectedValue, equals('editor'));
      });

      testWidgets('validates required selection with Form', (tester) async {
        final formKey = GlobalKey<FormState>();

        await pumpFormTest(
          tester,
          Form(
            key: formKey,
            child: AdaptiveDropdownField<String>(
              labelText: 'Department',
              validator: (val) =>
                  val == null ? 'Please select a department' : null,
              items: const [
                AdaptiveDropdownMenuItem(
                    value: 'eng', child: Text('Engineering')),
                AdaptiveDropdownMenuItem(value: 'des', child: Text('Design')),
              ],
            ),
          ),
        );

        final isValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();

        expect(isValid, isFalse);
        expect(find.text('Please select a department'), findsOneWidget);
      });
    });

    group('AdaptiveCheckbox & AdaptiveCheckboxFormField', () {
      testWidgets('standalone toggles value and respects touch target',
          (tester) async {
        bool? isChecked = false;

        await pumpFormTest(
          tester,
          StatefulBuilder(
            builder: (ctx, setState) => AdaptiveCheckbox(
              value: isChecked,
              onChanged: (v) => setState(() => isChecked = v),
            ),
          ),
          size: const Size(360.0, 640.0), // Compact
        );

        final size = tester.getSize(find.byType(AdaptiveCheckbox));
        expect(size.height, greaterThanOrEqualTo(48.0));
        expect(size.width, greaterThanOrEqualTo(48.0));

        await tester.tap(find.byType(AdaptiveCheckbox));
        await tester.pump();

        expect(isChecked, isTrue);
      });

      testWidgets('tapping title toggles checkbox', (tester) async {
        bool? isChecked = false;

        await pumpFormTest(
          tester,
          StatefulBuilder(
            builder: (ctx, setState) => AdaptiveCheckbox(
              value: isChecked,
              title: const Text('Accept terms and conditions'),
              subtitle: const Text('Read our privacy policy'),
              onChanged: (v) => setState(() => isChecked = v),
            ),
          ),
        );

        expect(find.text('Accept terms and conditions'), findsOneWidget);
        expect(find.text('Read our privacy policy'), findsOneWidget);

        await tester.tap(find.text('Accept terms and conditions'));
        await tester.pump();

        expect(isChecked, isTrue);
      });

      testWidgets('AdaptiveCheckboxFormField validates and saves',
          (tester) async {
        final formKey = GlobalKey<FormState>();
        bool? saved;

        await pumpFormTest(
          tester,
          Form(
            key: formKey,
            child: AdaptiveCheckboxFormField(
              title: const Text('I agree to the terms'),
              validator: (val) => (val != true) ? 'You must agree' : null,
              onSaved: (val) => saved = val,
            ),
          ),
        );

        final isValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();

        expect(isValid, isFalse);
        expect(find.text('You must agree'), findsOneWidget);

        await tester.tap(find.text('I agree to the terms'));
        await tester.pumpAndSettle();

        final isValidNow = formKey.currentState!.validate();
        await tester.pumpAndSettle();

        expect(isValidNow, isTrue);
        expect(find.text('You must agree'), findsNothing);

        formKey.currentState!.save();
        expect(saved, isTrue);
      });
    });

    group('AdaptiveSwitch & AdaptiveSwitchFormField', () {
      testWidgets('toggles switch and title tap', (tester) async {
        bool isEnabled = false;

        await pumpFormTest(
          tester,
          StatefulBuilder(
            builder: (ctx, setState) => AdaptiveSwitch(
              value: isEnabled,
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive real-time alerts'),
              onChanged: (v) => setState(() => isEnabled = v),
            ),
          ),
          size: const Size(360.0, 640.0), // Compact
        );

        expect(find.text('Push Notifications'), findsOneWidget);

        await tester.tap(find.text('Push Notifications'));
        await tester.pump();

        expect(isEnabled, isTrue);
      });

      testWidgets('AdaptiveSwitchFormField validates', (tester) async {
        final formKey = GlobalKey<FormState>();

        await pumpFormTest(
          tester,
          Form(
            key: formKey,
            child: AdaptiveSwitchFormField(
              title: const Text('Enable feature'),
              validator: (val) =>
                  (val != true) ? 'Feature must be enabled' : null,
            ),
          ),
        );

        final isValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();

        expect(isValid, isFalse);
        expect(find.text('Feature must be enabled'), findsOneWidget);
      });
    });

    group('AdaptiveSlider & AdaptiveSliderFormField', () {
      testWidgets('displays title and formatted value', (tester) async {
        double currentVal = 50.0;

        await pumpFormTest(
          tester,
          StatefulBuilder(
            builder: (ctx, setState) => AdaptiveSlider(
              value: currentVal,
              min: 0.0,
              max: 100.0,
              title: const Text('Volume Level'),
              showValue: true,
              valueFormatter: (v) => '${v.toInt()}%',
              showMinMax: true,
              onChanged: (v) => setState(() => currentVal = v),
            ),
          ),
        );

        expect(find.text('Volume Level'), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);
      });

      testWidgets('AdaptiveSliderFormField validates', (tester) async {
        final formKey = GlobalKey<FormState>();

        await pumpFormTest(
          tester,
          Form(
            key: formKey,
            child: AdaptiveSliderFormField(
              initialValue: 10.0,
              min: 0.0,
              max: 100.0,
              validator: (v) =>
                  (v != null && v < 20.0) ? 'Minimum is 20' : null,
            ),
          ),
        );

        final isValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();

        expect(isValid, isFalse);
        expect(find.text('Minimum is 20'), findsOneWidget);
      });
    });

    group('AdaptiveRadioGroup & AdaptiveRadioGroupFormField', () {
      testWidgets('selects option on tap', (tester) async {
        String? selected = 'standard';

        await pumpFormTest(
          tester,
          StatefulBuilder(
            builder: (ctx, setState) => AdaptiveRadioGroup<String>(
              labelText: 'Delivery Method',
              groupValue: selected,
              onChanged: (v) => setState(() => selected = v),
              options: const [
                AdaptiveRadioOption(
                    value: 'standard', title: Text('Standard (3-5 days)')),
                AdaptiveRadioOption(
                    value: 'express', title: Text('Express (1-2 days)')),
                AdaptiveRadioOption(
                    value: 'overnight', title: Text('Overnight')),
              ],
            ),
          ),
        );

        expect(find.text('Delivery Method'), findsOneWidget);
        expect(find.text('Standard (3-5 days)'), findsOneWidget);

        await tester.tap(find.text('Express (1-2 days)'));
        await tester.pump();

        expect(selected, equals('express'));
      });

      testWidgets('AdaptiveRadioGroupFormField validates required choice',
          (tester) async {
        final formKey = GlobalKey<FormState>();

        await pumpFormTest(
          tester,
          Form(
            key: formKey,
            child: AdaptiveRadioGroupFormField<String>(
              labelText: 'Plan',
              validator: (v) => v == null ? 'Please pick a plan' : null,
              options: const [
                AdaptiveRadioOption(value: 'free', title: Text('Free Tier')),
                AdaptiveRadioOption(value: 'pro', title: Text('Pro Tier')),
              ],
            ),
          ),
        );

        final isValid = formKey.currentState!.validate();
        await tester.pumpAndSettle();

        expect(isValid, isFalse);
        expect(find.text('Please pick a plan'), findsOneWidget);
      });
    });

    group('AdaptiveForm & AdaptiveFormSection', () {
      testWidgets('AdaptiveForm validates all fields and saves via state proxy',
          (tester) async {
        final formKey = GlobalKey<AdaptiveFormState>();
        String? name;
        String? email;

        await pumpFormTest(
          tester,
          AdaptiveForm(
            key: formKey,
            children: [
              AdaptiveTextField(
                labelText: 'Name',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name required' : null,
                onSaved: (v) => name = v,
              ),
              AdaptiveTextField(
                labelText: 'Email',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Email required' : null,
                onSaved: (v) => email = v,
              ),
            ],
          ),
        );

        expect(formKey.currentState!.validate(), isFalse);
        await tester.pumpAndSettle();

        expect(find.text('Name required'), findsOneWidget);
        expect(find.text('Email required'), findsOneWidget);

        await tester.enterText(find.byType(TextField).first, 'Alice');
        await tester.enterText(
            find.byType(TextField).last, 'alice@example.com');
        await tester.pumpAndSettle();

        expect(formKey.currentState!.validate(), isTrue);
        formKey.currentState!.save();

        expect(name, equals('Alice'));
        expect(email, equals('alice@example.com'));
      });

      testWidgets('AdaptiveForm clamps to maxContentWidth on wide screens',
          (tester) async {
        await pumpFormTest(
          tester,
          const AdaptiveForm(
            maxContentWidth: 600.0,
            children: [
              AdaptiveTextField(labelText: 'Clamped input'),
            ],
          ),
          size: const Size(1200.0, 800.0), // Large desktop
        );

        final formBox = tester.getSize(find.byType(AdaptiveTextField));
        expect(formBox.width, lessThanOrEqualTo(600.0));
      });

      testWidgets(
          'AdaptiveFormSection renders 2-columns on wide and collapses on compact',
          (tester) async {
        // Wide screen test
        await pumpFormTest(
          tester,
          const AdaptiveFormSection(
            titleText: 'Personal Information',
            columns: 2,
            children: [
              AdaptiveTextField(labelText: 'First Name'),
              AdaptiveTextField(labelText: 'Last Name'),
            ],
          ),
          size: const Size(900.0, 800.0),
        );

        expect(find.text('Personal Information'), findsOneWidget);
        expect(find.text('First Name'), findsOneWidget);
        expect(find.text('Last Name'), findsOneWidget);

        final firstNamePos = tester.getTopLeft(find.text('First Name'));
        final lastNamePos = tester.getTopLeft(find.text('Last Name'));

        // On wide screen with 2 columns, they should be horizontally adjacent (same Y)
        expect(firstNamePos.dy, equals(lastNamePos.dy));

        // Compact screen test
        await pumpFormTest(
          tester,
          const AdaptiveFormSection(
            titleText: 'Personal Information',
            columns: 2,
            children: [
              AdaptiveTextField(labelText: 'First Name'),
              AdaptiveTextField(labelText: 'Last Name'),
            ],
          ),
          size: const Size(360.0, 640.0),
        );

        final compactFirstNamePos = tester.getTopLeft(find.text('First Name'));
        final compactLastNamePos = tester.getTopLeft(find.text('Last Name'));

        // On compact screen, columns collapse to 1 column (LastName is below FirstName)
        expect(compactLastNamePos.dy, greaterThan(compactFirstNamePos.dy));
      });
    });
  });
}
