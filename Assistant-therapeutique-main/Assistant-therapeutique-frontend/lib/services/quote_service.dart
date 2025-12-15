import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';

class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io';
  static const String _lastQuoteDateKey = 'last_quote_date';
  static const String _dailyQuoteKey = 'daily_quote';
  static const String _favoriteQuotesKey = 'favorite_quotes';

  // Récupérer une citation aléatoire
  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/random?tags=inspirational,life,motivational,wisdom',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quote.fromJson(data);
      } else {
        throw Exception('Échec du chargement de la citation');
      }
    } catch (e) {
      // Citation de secours en cas d'erreur
      return Quote(
        content:
            'La vie est ce qui arrive pendant que tu es occupé à faire d\'autres plans.',
        author: 'John Lennon',
        tags: ['life', 'inspirational'],
      );
    }
  }

  // Obtenir la citation du jour (mise en cache)
  Future<Quote> getDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0]; // Format: YYYY-MM-DD
    final lastQuoteDate = prefs.getString(_lastQuoteDateKey);

    // Si c'est un nouveau jour, récupérer une nouvelle citation
    if (lastQuoteDate != today) {
      final quote = await fetchRandomQuote();
      await _saveDailyQuote(quote, today);
      return quote;
    }

    // Sinon, retourner la citation en cache
    final cachedQuoteJson = prefs.getString(_dailyQuoteKey);
    if (cachedQuoteJson != null) {
      return Quote.fromJson(json.decode(cachedQuoteJson));
    }

    // Si pas de cache, récupérer une nouvelle citation
    final quote = await fetchRandomQuote();
    await _saveDailyQuote(quote, today);
    return quote;
  }

  // Sauvegarder la citation du jour
  Future<void> _saveDailyQuote(Quote quote, String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastQuoteDateKey, date);
    await prefs.setString(_dailyQuoteKey, json.encode(quote.toJson()));
  }

  // Ajouter une citation aux favoris
  Future<void> addToFavorites(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoriteQuotesKey) ?? [];

    final quoteJson = json.encode(quote.toJson());
    if (!favoritesJson.contains(quoteJson)) {
      favoritesJson.add(quoteJson);
      await prefs.setStringList(_favoriteQuotesKey, favoritesJson);
    }
  }

  // Retirer une citation des favoris
  Future<void> removeFromFavorites(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoriteQuotesKey) ?? [];

    final quoteJson = json.encode(quote.toJson());
    favoritesJson.remove(quoteJson);
    await prefs.setStringList(_favoriteQuotesKey, favoritesJson);
  }

  // Vérifier si une citation est dans les favoris
  Future<bool> isFavorite(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoriteQuotesKey) ?? [];
    final quoteJson = json.encode(quote.toJson());
    return favoritesJson.contains(quoteJson);
  }

  // Obtenir toutes les citations favorites
  Future<List<Quote>> getFavoriteQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoriteQuotesKey) ?? [];

    return favoritesJson
        .map((quoteJson) => Quote.fromJson(json.decode(quoteJson)))
        .toList();
  }
}
