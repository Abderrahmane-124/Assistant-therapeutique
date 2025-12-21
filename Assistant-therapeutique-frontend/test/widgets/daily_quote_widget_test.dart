import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/auth/widgets/daily_quote_widget.dart';
import 'package:moodmate/models/quote_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DailyQuoteWidget', () {
    setUp(() {
      // Initialize SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('devrait afficher le titre "Citation du jour"', (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyQuoteWidget(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Citation du jour'), findsOneWidget);
    });

    testWidgets('devrait afficher l\'icône de citation', (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyQuoteWidget(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('devrait afficher un CircularProgressIndicator pendant le chargement', (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyQuoteWidget(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('devrait afficher l\'icône de rafraîchissement', (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyQuoteWidget(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('devrait afficher l\'icône de favoris', (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyQuoteWidget(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('devrait afficher la citation mise en cache', (WidgetTester tester) async {
      // Arrange
      final today = DateTime.now().toString().split(' ')[0];
      final cachedQuote = Quote(
        content: 'Citation test mise en cache',
        author: 'Test Author',
        tags: ['test'],
      );

      SharedPreferences.setMockInitialValues({
        'last_quote_date': today,
        'daily_quote': json.encode(cachedQuote.toJson()),
      });

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyQuoteWidget(),
            ),
          ),
        ),
      );

      // Attendre que le widget charge
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Citation test mise en cache'), findsOneWidget);
      expect(find.textContaining('Test Author'), findsOneWidget);
    });

    testWidgets('devrait contenir un Container comme widget principal', (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyQuoteWidget(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
    });
  });
}
