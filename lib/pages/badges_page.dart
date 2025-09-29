import 'package:flutter/material.dart';

class BadgesPage extends StatelessWidget {
  final List<Map<String, dynamic>> _badges = [
    {'title': 'Early Bird', 'description': 'Complete 5 morning workouts', 'icon': Icons.wb_sunny, 'earned': true, 'progress': 5, 'total': 5, 'color': Colors.yellow},
    {'title': 'Consistent', 'description': 'Workout 7 days in a row', 'icon': Icons.fitness_center, 'earned': true, 'progress': 7, 'total': 7, 'color': Colors.blue},
    {'title': 'Step Master', 'description': 'Walk 10,000 steps in a day', 'icon': Icons.directions_walk, 'earned': false, 'progress': 8547, 'total': 10000, 'color': Colors.green},
    {'title': 'Calorie Crusher', 'description': 'Burn 500 calories in one workout', 'icon': Icons.local_fire_department, 'earned': false, 'progress': 350, 'total': 500, 'color': Colors.red},
    {'title': 'Hydration Hero', 'description': 'Drink 8 glasses of water daily for a week', 'icon': Icons.water_drop, 'earned': false, 'progress': 4, 'total': 7, 'color': Colors.cyan},
    {'title': 'Social Butterfly', 'description': 'Complete 3 group workouts', 'icon': Icons.group, 'earned': false, 'progress': 1, 'total': 3, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Badges & Progress'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Progress Summary
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildProgressItem('Daily Steps Goal', 8547, 10000, Colors.green),
                    SizedBox(height: 12),
                    _buildProgressItem('Calories Burned', 245, 400, Colors.red),
                    SizedBox(height: 12),
                    _buildProgressItem('Active Minutes', 45, 60, Colors.blue),
                    SizedBox(height: 12),
                    _buildProgressItem('Water Intake', 6, 8, Colors.cyan),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Badges Section
            Text(
              'Achievement Badges',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _badges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(_badges[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, int current, int goal, Color color) {
    double progress = current / goal;
    if (progress > 1.0) progress = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
            Text('$current/$goal'),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    return Card(
      elevation: badge['earned'] ? 6 : 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badge['earned'] ? badge['color'] : Colors.grey[300],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                badge['icon'],
                size: 24,
                color: badge['earned'] ? Colors.white : Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Flexible(
              child: Text(
                badge['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: badge['earned'] ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            Flexible(
              child: Text(
                badge['description'],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8),
            if (!badge['earned'])
              LinearProgressIndicator(
                value: badge['progress'] / badge['total'],
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(badge['color']),
              ),
            if (badge['earned'])
              Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }
}