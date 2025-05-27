import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String _apiKey =
      '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';
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _messagesKey = 'chat_messages';
  static const int _maxMessageAge = 3; // days

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'com.nutrition.app://',
          'X-Title': 'Nutrition Tracker Chat Support',
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-r1:free',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a concise nutrition assistant. Provide brief, accurate nutrition advice. Focus on practical, actionable advice.',
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null &&
            data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null) {
          return data['choices'][0]['message']['content'];
        } else {
          throw Exception('Invalid response format from API');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error']?['message'] ?? 'Unknown error occurred';
        throw Exception(
            'API Error: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Chat API Error: $e');
      throw Exception('Failed to communicate with chat service: $e');
    }
  }

  static Future<void> saveMessage(String message, bool isUser) async {
    final prefs = await SharedPreferences.getInstance();
    final messages = await getMessages();

    messages.add({
      'message': message,
      'isUser': isUser,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Remove messages older than 3 days
    final now = DateTime.now();
    messages.removeWhere((msg) {
      final timestamp = DateTime.parse(msg['timestamp'] as String);
      return now.difference(timestamp).inDays > _maxMessageAge;
    });

    await prefs.setString(_messagesKey, jsonEncode(messages));
  }

  static Future<List<Map<String, dynamic>>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString(_messagesKey);

    if (messagesJson == null) {
      // Add welcome message if no messages exist
      final welcomeMessage = {
        'message':
            'Hello! I\'m your nutrition assistant. How can I help you with your nutrition goals today?',
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_messagesKey, jsonEncode([welcomeMessage]));
      return [welcomeMessage];
    }

    final List<dynamic> decoded = jsonDecode(messagesJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesKey);
  }
}
