import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../../../core/services/ai_service.dart';

class RecommendationsScreen extends StatefulWidget {
  final int bpm;

  const RecommendationsScreen({super.key, required this.bpm});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['الكل', 'AI'];

  late Future<Map<String, dynamic>> _aiResult;
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();
    _aiResult = _aiService.analyzeBPM(widget.bpm);
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'مرتفع':
        return Colors.red;
      case 'منخفض':
        return Colors.green;
      case 'طبيعي':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التوصيات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        label: const Text("Chat مع AI"),
        icon: const Icon(Icons.chat),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: FilterChip(
                    label: Text(_categories[index]),
                    selected: _selectedCategory == index,
                    onSelected: (_) {
                      setState(() => _selectedCategory = index);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _aiResult,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('لا توجد بيانات'));
                }

                final data = snapshot.data!;
                final List<String> recommendations =
                    List<String>.from(data['recommendations']);

                final aiRecommendations = recommendations.map((text) => {
                  'title': text,
                  'description': '',
                  'category': 'AI',
                  'icon': Icons.lightbulb,
                  'color': Colors.blue,
                  'priority': data['status'],
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: aiRecommendations.length,
                  itemBuilder: (context, index) {
                    final rec = aiRecommendations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rec['color'].withOpacity(0.1),
                          child: Icon(rec['icon'], color: rec['color']),
                        ),
                        title: Text(rec['title']),
                        trailing: Chip(
                          label: Text(
                            rec['priority'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor:
                              _getPriorityColor(rec['priority']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
