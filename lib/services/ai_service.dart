import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _openAIEndpoint = 'https://api.openai.com/v1/chat/completions';

  /// Sends a conversation to OpenAI and returns the assistant's response.
  /// [messages] should include the system message followed by conversation history.
  /// Returns the response text or throws an exception.
  static Future<String> getResponse({
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    String model = 'gpt-4',
    double temperature = 0.7,
  }) async {
    final response = await http.post(
      Uri.parse(_openAIEndpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': temperature,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final message = choices.first['message'] as Map<String, dynamic>;
        return message['content'] as String;
      }
      throw Exception('Empty response from AI service');
    } else {
      final error = jsonDecode(response.body) ?? {'error': {'message': response.body}};
      throw Exception('AI request failed: ${error['error']['message']}');
    }
  }
}
