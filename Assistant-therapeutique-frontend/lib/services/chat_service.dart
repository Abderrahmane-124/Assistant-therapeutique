import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = 'http://15.236.232.37:8000';

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'max_tokens': 200,
          'temperature': 0.4,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else if (response.statusCode == 503) {
        return 'Le modèle est en cours de chargement. Veuillez réessayer dans quelques instants.';
      } else {
        throw Exception('Erreur du serveur: ${response.statusCode}');
      }
    } catch (e) {
      return 'Désolé, je ne peux pas me connecter au serveur pour le moment. Veuillez vérifier votre connexion.';
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
