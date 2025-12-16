// lib/screens/recommendations_screen.dart
import 'package:flutter/material.dart';
import '../recommendations/recommendations_screen.dart';
import 'chat_screen.dart';
import '../../../core/services/ai_service.dart';

class RecommendationsScreen extends StatefulWidget {
  final int bpm;

  RecommendationsScreen({super.key, required this.bpm});

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
      appBar: AppBar(title: Text('التوصيات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        label: Text("Chat مع AI"),
        icon: Icon(Icons.chat),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: FilterChip(
                    label: Text(_categories[index]),
                    selected: _selectedCategory == index,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = index);
                    },
                    backgroundColor:
                        _selectedCategory == index ? Colors.blue[100] : Colors.grey[200],
                    selectedColor: Colors.blue[200],
                    checkmarkColor: Colors.blue[700],
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
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ، حاول مرة أخرى'));
                } else {
                  final data = snapshot.data!;
                  final List<Map<String, dynamic>> aiRecommendations =
                      data['recommendations'].map<Map<String, dynamic>>((text) => {
                            'title': text,
                            'description': '',
                            'category': 'AI',
                            'icon': Icons.lightbulb,
                            'color': Colors.blue,
                            'priority': data['status'],
                          }).toList();

                  final filtered = (_selectedCategory == 0)
                      ? aiRecommendations
                      : aiRecommendations
                          .where((rec) => rec['category'] == _categories[_selectedCategory])
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services, size: 60, color: Colors.grey[400]),
                          SizedBox(height: 10),
                          Text(
                            'لا توجد توصيات في هذا القسم',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(15),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final rec = filtered[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 15),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: rec['color'].withOpacity(0.1),
                                radius: 25,
                                child: Icon(rec['icon'], color: rec['color']),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            rec['title'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Chip(
                                          label: Text(
                                            rec['priority'],
                                            style: TextStyle(color: Colors.white, fontSize: 11),
                                          ),
                                          backgroundColor: _getPriorityColor(rec['priority']),
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    if (rec['description'] != '')
                                      Text(
                                        rec['description'],
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
