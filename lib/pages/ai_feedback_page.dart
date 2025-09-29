import 'package:flutter/material.dart';

class AIFeedbackPage extends StatefulWidget {
  @override
  _AIFeedbackPageState createState() => _AIFeedbackPageState();
}

class _AIFeedbackPageState extends State<AIFeedbackPage> {
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': 'Hi! I\'m your AI fitness coach. Ask me anything about workouts, nutrition, or fitness goals!',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'text': userMessage,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    // Simulate AI response delay
    await Future.delayed(Duration(seconds: 2));

    // Generate AI response based on message
    String aiResponse = _generateAIResponse(userMessage);

    setState(() {
      _messages.add({
        'text': aiResponse,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
      _isLoading = false;
    });
  }

  String _generateAIResponse(String message) {
    message = message.toLowerCase();

    if (message.contains('workout') || message.contains('exercise')) {
      return 'Great question! For an effective workout, I recommend starting with a 5-minute warm-up, followed by compound exercises like squats, push-ups, and planks. Remember to stay hydrated and listen to your body!';
    } else if (message.contains('diet') || message.contains('nutrition')) {
      return 'Nutrition is key to your fitness success! Focus on lean proteins, complex carbs, and healthy fats. Aim for 5-6 small meals throughout the day and don\'t forget to drink plenty of water.';
    } else if (message.contains('weight') || message.contains('lose')) {
      return 'Weight management is about creating a sustainable calorie deficit. Combine regular exercise with a balanced diet. Aim to lose 1-2 pounds per week for healthy, sustainable weight loss.';
    } else {
      return 'That\'s an interesting question! Based on your fitness journey, I\'d recommend focusing on consistency, proper form, and gradual progression. Would you like me to create a personalized workout plan for you?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Fitness Coach'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 12),
                  Text('AI is thinking...'),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Align(
      alignment: message['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message['isUser'] ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color: message['isUser'] ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask your AI coach...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
              ),
            ),
            SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              onPressed: _sendMessage,
              backgroundColor: Colors.purple,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}