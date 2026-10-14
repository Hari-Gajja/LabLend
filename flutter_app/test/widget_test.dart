import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/widgets/app_button.dart';
import 'package:flutter_app/widgets/status_badge.dart';
import 'package:flutter_app/widgets/empty_state_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('AppButton renders label and triggers callback on tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'Reserve Instrument',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Reserve Instrument'), findsOneWidget);
    await tester.tap(find.text('Reserve Instrument'));
    expect(tapped, isTrue);
  });

  testWidgets('StatusBadge displays correct text and theme color for approved status', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: 'approved'),
        ),
      ),
    );

    expect(find.text('Approved'), findsOneWidget);
  });

  testWidgets('EmptyStateView renders title, description, and action button', (WidgetTester tester) async {
    bool actionTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyStateView(
            icon: Icons.search_off,
            title: 'No equipment available',
            description: 'Please broaden your search parameters.',
            buttonText: 'Reset',
            onButtonPressed: () {
              actionTriggered = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('No equipment available'), findsOneWidget);
    expect(find.text('Please broaden your search parameters.'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    expect(actionTriggered, isTrue);
  });
}
