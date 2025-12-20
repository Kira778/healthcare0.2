import 'ai_service.dart';

class BPMAnalyzer {
  final AIService _aiService = AIService();

  Future<Map<String, dynamic>> analyze(int bpm) {
    return _aiService.analyzeBPM(bpm);
  }
}
