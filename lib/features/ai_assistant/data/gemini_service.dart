import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhaya/app/config.dart';

class GeminiService {
  final Dio _dio = Dio();
  static const String apiKeyStorageKey = 'gemini_api_key';

  static const String _systemPrompt = '''
You are Nirbhaya AI, a compassionate, highly knowledgeable, and rapid personal safety assistant dedicated to women's safety, crisis assistance, emergency guidance, legal rights in India (such as Zero FIR, POCSO, POSH Act, Domestic Violence Act), and self-defense advice.
- Keep emergency advice concise, direct, and actionable.
- Prioritize physical safety above all else.
- If the user is in immediate life-threatening danger, urge them to trigger SOS or dial 112 immediately.
- Maintain an empowering, empathetic, and objective tone.
''';

  Future<String?> getSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(apiKeyStorageKey);
    if (savedKey != null && savedKey.trim().isNotEmpty) {
      return savedKey.trim();
    }
    // Return the default configured Gemini API key if present
    if (AppConfig.defaultGeminiApiKey.trim().isNotEmpty) {
      return AppConfig.defaultGeminiApiKey.trim();
    }
    return null;
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(apiKeyStorageKey, key.trim());
  }

  Future<String?> generateAiResponse(String userPrompt) async {
    final key = await getSavedApiKey();
    if (key == null || key.isEmpty) {
      return null; // Signals fallback to offline safety knowledge engine
    }

    try {
      final endpoint =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key';

      final response = await _dio.post(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': key,
          },
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 15),
        ),
        data: {
          'system_instruction': {
            'parts': [
              {'text': _systemPrompt}
            ]
          },
          'contents': [
            {
              'parts': [
                {'text': userPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 500,
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final candidates = response.data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text']?.toString();
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
      }
    } catch (_) {
      // Return null on network error, invalid key, or timeout to invoke offline safety engine
      return null;
    }
    return null;
  }
}
