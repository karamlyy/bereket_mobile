import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'AIzaSyD5g-4UPoOTjlew0EdBsL52KB5io3Nuqo0';
  static const String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

  Future<String> getRecipeSuggestions(List<String> ingredients) async {
    try {
      final prompt = '''
Given these ingredients: ${ingredients.join(', ')}, suggest a recipe that can be made with these ingredients.
Please provide the response in Azerbaijani language.
Please provide the following format:
Başlıq: [Reseptin adı]
Təsvir: [Qısa təsvir]
Lazım olan maddələr: [İngredientlərin siyahısı]
Hazırlanması: [Addım-addım təlimatlar]
Bişirmə müddəti: [Təxmini vaxt dəqiqələrlə]
Çətinlik: [Asan/Orta/Çətin]
''';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to get recipe suggestions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting recipe suggestions: $e');
    }
  }
} 