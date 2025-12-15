import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moodmate/models/mood_model.dart';
import 'package:moodmate/features/auth/services/auth_service.dart';

class MoodService {
  final String _baseUrl =
      'http://localhost:8080/api/moods'; // Adjust as per your backend API

  // Read: Get moods for the logged-in user
  Future<List<Mood>> getMoods() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      // It's better to throw an exception or return an empty list
      // if no user is logged in, depending on desired behavior.
      throw Exception('User is not logged in.');
    }

    try {
      // Assuming the backend has an endpoint like /api/moods/user/{userId}
      final response = await http.get(Uri.parse('$_baseUrl/user/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        // Map the JSON data to a list of Mood objects
        return jsonData.map((json) => Mood.fromJson(json)).toList();
      } else {
        // If the server does not return a 200 OK response,
        // throw an exception.
        throw Exception(
          'Failed to load moods. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Handle connection errors or other issues
      throw Exception('Failed to connect to the server: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> saveMood(Mood mood) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(mood.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Humeur enregistrée avec succès.'};
      } else {
        // Attempt to parse error message from backend
        String errorMessage = 'Erreur inconnue';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON, use default message
        }
        return {
          'success': false,
          'message':
              'Échec de l\'enregistrement de l\'humeur: $errorMessage (Code: ${response.statusCode})',
        }; // Corrected escaping for apostrophe
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Échec de la connexion au serveur: ${e.toString()}',
      };
    }
  }

  // Update: Update an existing mood
  Future<Map<String, dynamic>> updateMood(Mood mood) async {
    if (mood.id == null) {
      return {
        'success': false,
        'message': 'Mood ID must be provided for an update.',
      };
    }
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${mood.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(mood.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Humeur mise à jour avec succès.'};
      } else {
        String errorMessage = 'Erreur inconnue';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          // keep default message
        }
        return {
          'success': false,
          'message':
              'Échec de la mise à jour de l\'humeur: $errorMessage (Code: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Échec de la connexion au serveur: ${e.toString()}',
      };
    }
  }

  // Delete: Delete a mood by its ID
  Future<Map<String, dynamic>> deleteMood(int moodId) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$moodId'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content is also a success
        return {'success': true, 'message': 'Humeur supprimée avec succès.'};
      } else {
        String errorMessage = 'Erreur inconnue';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          // keep default message
        }
        return {
          'success': false,
          'message':
              'Échec de la suppression: $errorMessage (Code: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Échec de la connexion au serveur: ${e.toString()}',
      };
    }
  }
}
