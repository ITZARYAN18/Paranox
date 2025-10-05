import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userEmail = 'user@example.com';

  final Map<String, dynamic> _userStats = {
    'totalWorkouts': 156,
    'totalCaloriesBurned': 45890,
    'totalDistance': 342.5,
    'streakDays': 7,
    'memberSince': 'January 2024',
    'currentWeight': 70.5,
    'goalWeight': 65.0,
    'height': 175,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? 'user@example.com';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => FitnessApp()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
           
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bhawishya',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Member since ${_userStats['memberSince']}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

           
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitness Overview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Total Workouts',
                            '${_userStats['totalWorkouts']}',
                            Icons.fitness_center,
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Calories Burned',
                            '${_userStats['totalCaloriesBurned']}',
                            Icons.local_fire_department,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Distance (km)',
                            '${_userStats['totalDistance']}',
                            Icons.directions_run,
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Current Streak',
                            '${_userStats['streakDays']} days',
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

           
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Measurements',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildMeasurementRow('Height', '${_userStats['height']} cm'),
                    _buildMeasurementRow('Current Weight', '${_userStats['currentWeight']} kg'),
                    _buildMeasurementRow('Goal Weight', '${_userStats['goalWeight']} kg'),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: 0.7, // Progress towards goal
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Weight Goal Progress: 70%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

          
            Card(
              elevation: 4,
              child: Column(
                children: [
                  _buildSettingsTile(
                    'Edit Profile',
                    Icons.edit,
                        () => _showEditDialog('Profile'),
                  ),
                  Divider(height: 1),
                  _buildSettingsTile(
                    'Fitness Goals',
                    Icons.flag,
                        () => _showEditDialog('Goals'),
                  ),
                  Divider(height: 1),
                  _buildSettingsTile(
                    'Notifications',
                    Icons.notifications,
                        () => _showEditDialog('Notifications'),
                  ),
                  Divider(height: 1),
                  _buildSettingsTile(
                    'Privacy Settings',
                    Icons.privacy_tip,
                        () => _showEditDialog('Privacy'),
                  ),
                  Divider(height: 1),
                  _buildSettingsTile(
                    'Help & Support',
                    Icons.help,
                        () => _showEditDialog('Support'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

           
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditDialog(String setting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$setting Settings'),
        content: Text('$setting settings feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
