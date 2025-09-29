import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
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
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.orangeAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPodiumPosition(_leaderboardData[1], 2, 80),
                  _buildPodiumPosition(_leaderboardData[0], 1, 100),
                  _buildPodiumPosition(_leaderboardData[2], 3, 60),
                ],
              ),
            ),
          ),

          // Rest of leaderboard
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
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
    Color medalColor = position == 1 ? Colors.amber : position == 2 ? Colors.grey[300]! : Colors.brown[300]!;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                user['name'][0],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
            SizedBox(height: 3),
            Text(
              user['name'].split(' ')[0],
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${user['points']}',
              style: TextStyle(color: Colors.white, fontSize: 9),
            ),
            SizedBox(height: 3),
            Container(
              height: height,
              decoration: BoxDecoration(
                color: medalColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: Text(
                  '$position',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user) {
    bool isCurrentUser = user['name'] == 'You';

    return Card(
      elevation: isCurrentUser ? 4 : 2,
      margin: EdgeInsets.only(bottom: 8),
      color: isCurrentUser ? Colors.blue[50] : null,
      child: ListTile(
        leading: CircleAvatar(
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
          ),
        ),
        subtitle: Text('${user['streak']} day streak'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${user['points']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('points', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}