import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String _apiKey = "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"; // حط مفتاحك هنا
  final String _model = "moonshotai/Kimi-K2-Instruct-0905";

  // Chat مع LLM
  Future<String> getChatResponse(String message) async {
    final url = Uri.parse("https://router.huggingface.co/v1/chat/completions");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": _model,
        "messages": [
          {"role": "user", "content": message}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final choices = data['choices'];
      if (choices != null && choices.isNotEmpty) {
        return choices[0]['message']['content'] ?? "لا يوجد رد";
      }
      return "لا يوجد رد";
    } else {
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");
      return "حدث خطأ في الاتصال بالذكاء الاصطناعي";
    }
  }

  // تحليل BPM (نفس القديم)
  Future<Map<String, dynamic>> analyzeBPM(int bpm) async {
    await Future.delayed(const Duration(seconds: 1));

    if (bpm < 60) {
      return {
        'status': 'منخفض',
        'recommendations': [
          'استرح قليلًا',
          'اشرب ماء',
        ],
      };
    } else if (bpm <= 100) {
      return {
        'status': 'طبيعي',
        'recommendations': [
          'حافظ على نشاطك الطبيعي',
          'نم جيدًا',
        ],
      };
    } else {
      return {
        'status': 'مرتفع',
        'recommendations': [
          'استرخِ وخذ نفسًا عميقًا',
          'تجنب المجهود الشديد',
        ],
      };
    }
  }
}
