import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

class AuthService {
  final String _baseUrl = 'http://localhost:8080'; // Pour iOS Simulator/Desktop
  static const String _userIdKey = 'userId'; // Key for storing userId

  Future<Map<String, dynamic>> login(String username, String password) async {
    final Uri url = Uri.parse('$_baseUrl/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          final int userId = responseBody['userId'];
          await _saveUserId(userId); // Store userId
          return {'success': true, 'userId': userId};
        } else {
          return {
            'success': false,
            'message': responseBody['message'] ?? 'Erreur de connexion',
          };
        }
      } else {
        // Le corps de la réponse contient le message d'erreur
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Erreur de connexion',
        };
      }
    } catch (e) {
      // Gérer les erreurs de connexion (ex: serveur non démarré)
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur. Veuillez réessayer.',
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String email,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'email': email,
        }),
      );

      if (response.statusCode == 201) {
        // CREATED
        return {'success': true};
      } else {
        // Gérer les erreurs, par exemple si l'utilisateur existe déjà
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Erreur d\'inscription',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur. Veuillez réessayer.',
      };
    }
  }

  // --- Utility methods for userId storage ---
  static Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}
