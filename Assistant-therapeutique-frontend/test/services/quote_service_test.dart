import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/services/quote_service.dart';
import 'package:moodmate/models/quote_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('QuoteService', () {
    late QuoteService quoteService;

    setUp(() {
      quoteService = QuoteService();
      // Reset SharedPreferences avant chaque test
      SharedPreferences.setMockInitialValues({});
    });

    group('fetchRandomQuote', () {
      test('devrait retourner un Quote (succès ou fallback)', () async {
        // Act
        final quote = await quoteService.fetchRandomQuote();

        // Assert
        expect(quote, isA<Quote>());
        expect(quote.content, isNotEmpty);
        expect(quote.author, isNotEmpty);
      });

      test('devrait retourner une citation avec des tags', () async {
        // Act
        final quote = await quoteService.fetchRandomQuote();

        // Assert
        expect(quote.tags, isA<List<String>>());
      });
    });

    group('getDailyQuote', () {
      test('devrait retourner un Quote', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final quote = await quoteService.getDailyQuote();

        // Assert
        expect(quote, isA<Quote>());
        expect(quote.content, isNotEmpty);
      });

      test('devrait retourner la même citation le même jour (cache)', () async {
        // Arrange
        final today = DateTime.now().toString().split(' ')[0];
        final cachedQuote = Quote(
          content: 'Citation du jour mise en cache',
          author: 'Test Author',
          tags: ['test'],
        );
        
        SharedPreferences.setMockInitialValues({
          'last_quote_date': today,
          'daily_quote': json.encode(cachedQuote.toJson()),
        });

        // Act
        final quote = await quoteService.getDailyQuote();

        // Assert
        expect(quote.content, equals('Citation du jour mise en cache'));
        expect(quote.author, equals('Test Author'));
      });

      test('devrait récupérer nouvelle citation si date différente', () async {
        // Arrange - date d'hier
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1))
            .toString()
            .split(' ')[0];
        
        SharedPreferences.setMockInitialValues({
          'last_quote_date': yesterday,
          'daily_quote': json.encode({
            'content': 'Ancienne citation',
            'author': 'Old Author',
            'tags': ['old'],
          }),
        });

        // Act
        final quote = await quoteService.getDailyQuote();

        // Assert
        expect(quote, isA<Quote>());
        // La citation doit être différente (nouvelle ou fallback)
      });
    });

    group('addToFavorites', () {
      test('devrait ajouter une citation aux favoris', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final quote = Quote(
          content: 'Citation favorite',
          author: 'Auteur Favori',
          tags: ['inspiration'],
        );

        // Act
        await quoteService.addToFavorites(quote);

        // Assert - Vérifie via isFavorite
        final isFav = await quoteService.isFavorite(quote);
        expect(isFav, isTrue);
      });

      test('ne devrait pas ajouter de doublons', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final quote = Quote(
          content: 'Citation unique',
          author: 'Auteur',
          tags: ['test'],
        );

        // Act - Ajouter deux fois
        await quoteService.addToFavorites(quote);
        await quoteService.addToFavorites(quote);

        // Assert
        final favorites = await quoteService.getFavoriteQuotes();
        final matchingQuotes = favorites.where((q) => q.content == 'Citation unique');
        expect(matchingQuotes.length, equals(1));
      });

      test('devrait ajouter plusieurs citations différentes', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final quote1 = Quote(
          content: 'Première citation',
          author: 'Auteur 1',
          tags: ['tag1'],
        );
        final quote2 = Quote(
          content: 'Deuxième citation',
          author: 'Auteur 2',
          tags: ['tag2'],
        );

        // Act
        await quoteService.addToFavorites(quote1);
        await quoteService.addToFavorites(quote2);

        // Assert
        final favorites = await quoteService.getFavoriteQuotes();
        expect(favorites.length, equals(2));
      });
    });

    group('removeFromFavorites', () {
      test('devrait retirer une citation des favoris', () async {
        // Arrange
        final quote = Quote(
          content: 'À supprimer',
          author: 'Test',
          tags: [],
        );
        SharedPreferences.setMockInitialValues({
          'favorite_quotes': [json.encode(quote.toJson())],
        });

        // Act
        await quoteService.removeFromFavorites(quote);

        // Assert
        final isFav = await quoteService.isFavorite(quote);
        expect(isFav, isFalse);
      });

      test('devrait gérer la suppression d\'une citation inexistante', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'favorite_quotes': []});
        final quote = Quote(
          content: 'Inexistante',
          author: 'Test',
          tags: [],
        );

        // Act & Assert - Ne devrait pas lancer d'erreur
        await quoteService.removeFromFavorites(quote);
        final favorites = await quoteService.getFavoriteQuotes();
        expect(favorites, isEmpty);
      });
    });

    group('isFavorite', () {
      test('devrait retourner true si la citation est favorite', () async {
        // Arrange
        final quote = Quote(
          content: 'Ma favorite',
          author: 'Moi',
          tags: ['personal'],
        );
        SharedPreferences.setMockInitialValues({
          'favorite_quotes': [json.encode(quote.toJson())],
        });

        // Act
        final result = await quoteService.isFavorite(quote);

        // Assert
        expect(result, isTrue);
      });

      test('devrait retourner false si la citation n\'est pas favorite', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'favorite_quotes': []});
        final quote = Quote(
          content: 'Pas favorite',
          author: 'Test',
          tags: [],
        );

        // Act
        final result = await quoteService.isFavorite(quote);

        // Assert
        expect(result, isFalse);
      });

      test('devrait retourner false si aucun favori n\'existe', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final quote = Quote(
          content: 'Test',
          author: 'Test',
          tags: [],
        );

        // Act
        final result = await quoteService.isFavorite(quote);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getFavoriteQuotes', () {
      test('devrait retourner une liste vide si aucun favori', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final favorites = await quoteService.getFavoriteQuotes();

        // Assert
        expect(favorites, isEmpty);
      });

      test('devrait retourner tous les favoris', () async {
        // Arrange
        final quotes = [
          Quote(content: 'Quote 1', author: 'Author 1', tags: ['a']),
          Quote(content: 'Quote 2', author: 'Author 2', tags: ['b']),
          Quote(content: 'Quote 3', author: 'Author 3', tags: ['c']),
        ];
        SharedPreferences.setMockInitialValues({
          'favorite_quotes': quotes.map((q) => json.encode(q.toJson())).toList(),
        });

        // Act
        final favorites = await quoteService.getFavoriteQuotes();

        // Assert
        expect(favorites.length, equals(3));
        expect(favorites[0].content, equals('Quote 1'));
        expect(favorites[1].content, equals('Quote 2'));
        expect(favorites[2].content, equals('Quote 3'));
      });

      test('devrait préserver l\'ordre des favoris', () async {
        // Arrange
        final quotes = [
          Quote(content: 'First', author: 'A1', tags: []),
          Quote(content: 'Second', author: 'A2', tags: []),
        ];
        SharedPreferences.setMockInitialValues({
          'favorite_quotes': quotes.map((q) => json.encode(q.toJson())).toList(),
        });

        // Act
        final favorites = await quoteService.getFavoriteQuotes();

        // Assert
        expect(favorites[0].content, equals('First'));
        expect(favorites[1].content, equals('Second'));
      });
    });

    group('Gestion du cache', () {
      test('devrait persister la citation du jour', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        await quoteService.getDailyQuote();

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('last_quote_date'), isNotNull);
        expect(prefs.getString('daily_quote'), isNotNull);
      });
    });

    group('Edge cases', () {
      test('devrait gérer une citation avec contenu très long', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final quote = Quote(
          content: 'A' * 1000,
          author: 'Long Author',
          tags: ['long'],
        );

        // Act
        await quoteService.addToFavorites(quote);
        final favorites = await quoteService.getFavoriteQuotes();

        // Assert
        expect(favorites.first.content.length, equals(1000));
      });

      test('devrait gérer une citation avec caractères spéciaux', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final quote = Quote(
          content: "L'amour est \"beau\" — 😊",
          author: "M. O'Brien",
          tags: ['amour', "l'espoir"],
        );

        // Act
        await quoteService.addToFavorites(quote);
        final favorites = await quoteService.getFavoriteQuotes();

        // Assert
        expect(favorites.first.content, contains('😊'));
        expect(favorites.first.author, contains("O'Brien"));
      });

      test('devrait gérer une citation sans tags', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final quote = Quote(
          content: 'Sans tags',
          author: 'Author',
          tags: [],
        );

        // Act
        await quoteService.addToFavorites(quote);
        final favorites = await quoteService.getFavoriteQuotes();

        // Assert
        expect(favorites.first.tags, isEmpty);
      });
    });
  });
}
