import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String _apiKey =
      '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'; // Replace with your OpenAI API key
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _messagesKey = 'chat_messages';
  static const int _maxMessageAge = 3; // days

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // 'model': 'gpt-4o', // 100 messages are around $3
          'model': 'gpt-4o-2024-08-06', // 100 messages are around $1.5
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a professional nutrition assistant with expertise in multiple languages. 
              Provide accurate, evidence-based nutrition advice. 
              Keep responses concise but informative.
              If the user's message is not in English, respond in their language.
              Focus on practical, actionable advice that aligns with current nutritional guidelines.
              Always consider cultural context when providing advice.
              and do not answer any questions that are not related to nutrition.
              ''',
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
        'message': '''Hello! I'm your multilingual nutrition assistant. 
        I can help you with nutrition advice in multiple languages.
        How can I assist you with your nutrition goals today?''',
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
