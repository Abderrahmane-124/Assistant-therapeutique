import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/models/quote_model.dart';

void main() {
  group('Quote Model', () {
    group('fromJson', () {
      test('devrait créer un Quote à partir de JSON complet', () {
        // Arrange
        final json = {
          'content': 'La vie est belle.',
          'author': 'Albert Camus',
          'tags': ['inspiration', 'philosophie'],
        };

        // Act
        final quote = Quote.fromJson(json);

        // Assert
        expect(quote.content, equals('La vie est belle.'));
        expect(quote.author, equals('Albert Camus'));
        expect(quote.tags, equals(['inspiration', 'philosophie']));
      });

      test('devrait utiliser des valeurs par défaut pour content null', () {
        // Arrange
        final json = {
          'content': null,
          'author': 'Auteur',
          'tags': ['tag1'],
        };

        // Act
        final quote = Quote.fromJson(json);

        // Assert
        expect(quote.content, equals(''));
      });

      test('devrait utiliser Anonyme pour author null', () {
        // Arrange
        final json = {
          'content': 'Une citation',
          'author': null,
          'tags': ['tag1'],
        };

        // Act
        final quote = Quote.fromJson(json);

        // Assert
        expect(quote.author, equals('Anonyme'));
      });

      test('devrait utiliser liste vide pour tags null', () {
        // Arrange
        final json = {
          'content': 'Citation',
          'author': 'Auteur',
          'tags': null,
        };

        // Act
        final quote = Quote.fromJson(json);

        // Assert
        expect(quote.tags, isEmpty);
      });

      test('devrait gérer tous les champs manquants', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final quote = Quote.fromJson(json);

        // Assert
        expect(quote.content, equals(''));
        expect(quote.author, equals('Anonyme'));
        expect(quote.tags, isEmpty);
      });

      test('devrait parser correctement une liste de tags variés', () {
        // Arrange
        final json = {
          'content': 'Test',
          'author': 'Test Author',
          'tags': ['motivation', 'santé mentale', 'bien-être', 'bonheur'],
        };

        // Act
        final quote = Quote.fromJson(json);

        // Assert
        expect(quote.tags, hasLength(4));
        expect(quote.tags, contains('motivation'));
        expect(quote.tags, contains('santé mentale'));
        expect(quote.tags, contains('bien-être'));
        expect(quote.tags, contains('bonheur'));
      });
    });

    group('toJson', () {
      test('devrait convertir un Quote en JSON', () {
        // Arrange
        final quote = Quote(
          content: 'Sois le changement que tu veux voir.',
          author: 'Gandhi',
          tags: ['inspiration', 'changement'],
        );

        // Act
        final json = quote.toJson();

        // Assert
        expect(json['content'], equals('Sois le changement que tu veux voir.'));
        expect(json['author'], equals('Gandhi'));
        expect(json['tags'], equals(['inspiration', 'changement']));
      });

      test('devrait gérer une liste de tags vide', () {
        // Arrange
        final quote = Quote(
          content: 'Citation sans tags',
          author: 'Anonyme',
          tags: [],
        );

        // Act
        final json = quote.toJson();

        // Assert
        expect(json['tags'], isEmpty);
      });
    });

    group('Constructor', () {
      test('devrait créer un Quote avec tous les champs requis', () {
        // Arrange & Act
        final quote = Quote(
          content: 'Test content',
          author: 'Test author',
          tags: ['tag1', 'tag2'],
        );

        // Assert
        expect(quote.content, equals('Test content'));
        expect(quote.author, equals('Test author'));
        expect(quote.tags, equals(['tag1', 'tag2']));
      });
    });

    group('Round-trip serialization', () {
      test('devrait préserver les données lors de la sérialisation/désérialisation', () {
        // Arrange
        final original = Quote(
          content: 'Citation originale',
          author: 'Auteur Original',
          tags: ['tag1', 'tag2', 'tag3'],
        );

        // Act
        final json = original.toJson();
        final reconstructed = Quote.fromJson(json);

        // Assert
        expect(reconstructed.content, equals(original.content));
        expect(reconstructed.author, equals(original.author));
        expect(reconstructed.tags, equals(original.tags));
      });

      test('devrait gérer les caractères spéciaux dans le contenu', () {
        // Arrange
        final original = Quote(
          content: "L'amour vaincra \"toujours\" – n'est-ce pas?",
          author: "M. O'Brien",
          tags: ['amour', 'espoir'],
        );

        // Act
        final json = original.toJson();
        final reconstructed = Quote.fromJson(json);

        // Assert
        expect(reconstructed.content, equals(original.content));
        expect(reconstructed.author, equals(original.author));
      });

      test('devrait gérer les tags avec caractères spéciaux', () {
        // Arrange
        final original = Quote(
          content: 'Test',
          author: 'Test',
          tags: ['bien-être', "l'esprit", 'santé & vie'],
        );

        // Act
        final json = original.toJson();
        final reconstructed = Quote.fromJson(json);

        // Assert
        expect(reconstructed.tags, equals(original.tags));
      });
    });

    group('Edge cases', () {
      test('devrait gérer une citation très longue', () {
        // Arrange
        final longContent = 'A' * 1000;
        final quote = Quote(
          content: longContent,
          author: 'Author',
          tags: ['tag'],
        );

        // Act
        final json = quote.toJson();
        final reconstructed = Quote.fromJson(json);

        // Assert
        expect(reconstructed.content.length, equals(1000));
      });

      test('devrait gérer de nombreux tags', () {
        // Arrange
        final manyTags = List.generate(50, (i) => 'tag$i');
        final quote = Quote(
          content: 'Content',
          author: 'Author',
          tags: manyTags,
        );

        // Act
        final json = quote.toJson();
        final reconstructed = Quote.fromJson(json);

        // Assert
        expect(reconstructed.tags, hasLength(50));
      });
    });
  });
}
