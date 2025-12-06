import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moodmate/models/journal_model.dart';
import 'package:moodmate/features/auth/services/auth_service.dart';

class JournalService {
  final String _baseUrl = 'http://localhost:8080/api/journals'; // Adjust as per your backend API

  // Create
  Future<Map<String, dynamic>> saveJournalEntry(String content) async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'content': content,
          'userId': userId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Journal entry saved successfully.'};
      } else {
        String errorMessage = 'Unknown error';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON, use default message
        }
        return {
          'success': false,
          'message': 'Failed to save journal entry: $errorMessage (Code: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to the server: ${e.toString()}',
      };
    }
  }

  // Read
  Future<List<JournalEntry>> getJournalEntries() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/user/$userId'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<JournalEntry> entries = body.map((dynamic item) => JournalEntry.fromJson(item)).toList();
        return entries;
      } else {
        throw Exception('Failed to load journal entries');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: ${e.toString()}');
    }
  }

  // Update
  Future<Map<String, dynamic>> updateJournalEntry(int id, String content) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Journal entry updated successfully.'};
      } else {
        return {'success': false, 'message': 'Failed to update journal entry: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to the server: ${e.toString()}'};
    }
  }

  // Delete
  Future<Map<String, dynamic>> deleteJournalEntry(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Journal entry deleted successfully.'};
      } else {
        return {'success': false, 'message': 'Failed to delete journal entry: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to the server: ${e.toString()}'};
    }
  }
}
