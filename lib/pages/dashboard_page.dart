import 'package:flutter/material.dart';
import 'package:kevin_11/model/jump.dart';
import 'package:kevin_11/model/situp.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card (Unchanged)
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Ready for today\'s workout?', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Stats Grid (Unchanged)
            Text('Today\'s Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard('Steps', '8,547', Icons.directions_walk, Colors.green),
                _buildStatCard('Calories', '245', Icons.local_fire_department, Colors.red),
                _buildStatCard('Distance', '3.2 km', Icons.location_on, Colors.blue),
                _buildStatCard('Active Time', '45 min', Icons.timer, Colors.orange),
              ],
            ),
            SizedBox(height: 20),

            // --- NEW WORKOUT SECTION ---
            // This replaces the old "Quick Actions" row.
            _buildWorkoutSection(context),
            // --- END OF NEW SECTION ---

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- NEW HELPER WIDGET for the workout list ---
  Widget _buildWorkoutSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Less bottom padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start a Workout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Sit-Up Challenge
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.fitness_center, color: Colors.green),
              title: Text('Sit-Up Challenge'),
              trailing: ElevatedButton(
                onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>SitupScreen()));
                },
                child: Text('Start'),
              ),
            ),
            Divider(),

            // Vertical Jump Test
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.arrow_upward, color: Colors.orange),
              title: Text('Vertical Jump Test'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>JumpScreen()));
                },
                child: Text('Start'),
              ),
            ),
            Divider(),

            // Coming Soon item
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.accessibility_new, color: Colors.grey),
              title: Text('Push-Up Counter', style: TextStyle(color: Colors.grey)),
              trailing: Chip(
                label: Text('Coming Soon', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Unchanged helper widget for stats
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // NOTE: This helper widget is no longer used, but I've left it here in case you need it elsewhere.
  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}