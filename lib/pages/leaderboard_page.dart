import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  // Using final for immutable properties is a good practice.
  final List<Map<String, dynamic>> _leaderboardData = [
    {'name': 'Alex Johnson', 'points': 1250, 'rank': 1, 'streak': 15},
    {'name': 'Sarah Chen', 'points': 1180, 'rank': 2, 'streak': 12},
    {'name': 'Mike Wilson', 'points': 1120, 'rank': 3, 'streak': 8},
    {'name': 'Emma Davis', 'points': 1050, 'rank': 4, 'streak': 10},
    {'name': 'You', 'points': 980, 'rank': 5, 'streak': 7},
    {'name': 'John Smith', 'points': 920, 'rank': 6, 'streak': 5},
    {'name': 'Lisa Brown', 'points': 850, 'rank': 7, 'streak': 9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Top 3 Podium
          Container(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0), // Added padding for better spacing
            height: 200, // Slightly increased height for better visual balance
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.orangeAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // --- CHANGED HEIGHTS HERE ---
                _buildPodiumPosition(_leaderboardData[1], 2, 80), // 2nd place
                _buildPodiumPosition(_leaderboardData[0], 1, 110), // 1st place
                _buildPodiumPosition(_leaderboardData[2], 3, 60), // 3rd place
              ],
            ),
          ),

          // Rest of leaderboard
          Expanded(
            child: ListView.builder(
              // Changed padding to only be horizontal to avoid extra space at the top
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _leaderboardData.length - 3,
              itemBuilder: (context, index) {
                final user = _leaderboardData[index + 3];
                return _buildLeaderboardItem(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(Map<String, dynamic> user, int position, double height) {
    Color medalColor = position == 1 ? Colors.amber[600]! : position == 2 ? Colors.grey[400]! : Color(0xFFCD7F32);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 22, // Slightly larger avatar
          backgroundColor: Colors.white,
          child: Text(
            user['name'][0],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ),
        SizedBox(height: 8),
        Text(
          user['name'].split(' ')[0],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          '${user['points']} pts',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        SizedBox(height: 8),
        Container(
          height: height,
          width: 60, // A bit wider for better proportions
          decoration: BoxDecoration(
            // Use a simple gradient instead of a solid color
            gradient: LinearGradient(
              colors: [
                Color.lerp(medalColor, Colors.white, 0.1)!, // Lighter top
                medalColor,                                // Main color
                Color.lerp(medalColor, Colors.black, 0.1)!, // Darker bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, -2),
              ),
            ],
          ),


          child: Center(
            child: Text(
              '$position',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user) {
    bool isCurrentUser = user['name'] == 'You';

    return Card(
      elevation: isCurrentUser ? 4 : 1,
      margin: EdgeInsets.only(bottom: 10),
      color: isCurrentUser ? Colors.orange.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser ? BorderSide(color: Colors.orange, width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.orange,
          child: Text(
            '${user['rank']}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user['name'],
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        subtitle: Text('${user['streak']} day streak 🔥'),
        trailing: Text(
          '${user['points']} pts',
          style: TextStyle(
            fontSize: 16, // --- CHANGED FONT SIZE HERE ---
            fontWeight: FontWeight.bold,
            color: Colors.orange[800],
          ),
        ),
      ),
    );
  }
}