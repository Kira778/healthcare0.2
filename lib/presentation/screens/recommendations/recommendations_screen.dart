import 'package:flutter/material.dart';

class RecommendationsScreen extends StatefulWidget {
  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['الكل', 'الغذاء', 'الرياضة', 'النوم', 'نفسية'];

  final List<Map<String, dynamic>> _recommendations = [
    {
      'title': 'شرب الماء',
      'description': 'اشرب 8 أكواب من الماء يومياً للحفاظ على رطوبة الجسم',
      'category': 'الغذاء',
      'icon': Icons.local_drink,
      'color': Colors.blue,
      'priority': 'عالية',
    },
    {
      'title': 'المشي اليومي',
      'description': 'امشِ 30 دقيقة يومياً لتحسين الدورة الدموية',
      'category': 'الرياضة',
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'priority': 'متوسطة',
    },
    {
      'title': 'النوم المبكر',
      'description': 'نم 8 ساعات ليلاً لاستعادة نشاط الجسم',
      'category': 'النوم',
      'icon': Icons.bedtime,
      'color': Colors.purple,
      'priority': 'عالية',
    },
    {
      'title': 'التنفس العميق',
      'description': 'تمارين التنفس تقلل التوتر وتحسن التركيز',
      'category': 'نفسية',
      'icon': Icons.air,
      'color': Colors.teal,
      'priority': 'منخفضة',
    },
    {
      'title': 'تجنب السكر',
      'description': 'قلل من السكريات للحفاظ على مستويات طاقة ثابتة',
      'category': 'الغذاء',
      'icon': Icons.cake,
      'color': Colors.red,
      'priority': 'متوسطة',
    },
    {
      'title': 'اليوغا',
      'description': 'مارس اليوجا 3 مرات أسبوعياً لمرونة الجسم',
      'category': 'الرياضة',
      'icon': Icons.self_improvement,
      'color': Colors.orange,
      'priority': 'منخفضة',
    },
  ];

  List<Map<String, dynamic>> get _filteredRecommendations {
    if (_selectedCategory == 0) return _recommendations;
    final category = _categories[_selectedCategory];
    return _recommendations.where((rec) => rec['category'] == category).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'عالية': return Colors.red;
      case 'متوسطة': return Colors.orange;
      case 'منخفضة': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  backgroundColor: _selectedCategory == index ? Colors.blue[100] : Colors.grey[200],
                  selectedColor: Colors.blue[200],
                  checkmarkColor: Colors.blue[700],
                ),
              );
            },
          ),
        ),

        Expanded(
          child: _filteredRecommendations.isEmpty
              ? Center(
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
          )
              : ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: _filteredRecommendations.length,
            itemBuilder: (context, index) {
              final rec = _filteredRecommendations[index];
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
                            Text(
                              rec['description'],
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Chip(
                                  label: Text(rec['category']),
                                  backgroundColor: Colors.grey[100],
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.bookmark_border),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}