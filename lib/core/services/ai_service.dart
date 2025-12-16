// lib/services/ai_service.dart
class AIService {
  // Fake AI response for BPM analysis
  Future<Map<String, dynamic>> analyzeBPM(int bpm) async {
    await Future.delayed(Duration(seconds: 1)); // محاكاة انتظار API

    if (bpm < 60) {
      return {
        'status': 'منخفض',
        'recommendations': [
          'استرح قليلاً',
          'اشرب ماء',
          'تجنب النشاط البدني الشديد'
        ],
      };
    } else if (bpm <= 100) {
      return {
        'status': 'طبيعي',
        'recommendations': [
          'حافظ على نشاطك الطبيعي',
          'اشرب ماء بانتظام',
          'نم جيدًا'
        ],
      };
    } else {
      return {
        'status': 'مرتفع',
        'recommendations': [
          'استرخِ وخذ نفس عميق',
          'تجنب التمارين الشاقة',
          'راجع طبيبك إذا استمر الوضع'
        ],
      };
    }
  }

  // Fake AI response for ChatScreen
  Future<String> getChatResponse(String message) async {
    await Future.delayed(Duration(seconds: 1));
    return "AI: فهمت '$message', نصيحة: اهتم بصحتك!";
  }
}
