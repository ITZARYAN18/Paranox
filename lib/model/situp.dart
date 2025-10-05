import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';





class SitupScreen extends StatefulWidget {
  const SitupScreen({super.key});

  @override
  State<SitupScreen> createState() => _SitupScreenState();
}

class _SitupScreenState extends State<SitupScreen> {
  // --- STATE VARIABLES ---
  bool _isLoading = false;
  Map<String, dynamic>? _apiResponse;
  XFile? _pickedFile;


  String? _detailedFeedback;
  bool _isFetchingFeedback = false;

  
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  
  final String _ipAddress = "10.223.35.72";
  final String _port = "8000";

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

 
  Future<void> _uploadVideo(XFile videoFile) async {
   
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;

    setState(() {
      _isLoading = true;
      _apiResponse = null;
      _detailedFeedback = null;
    });

    try {
      final uploadUrl = "http://$_ipAddress:$_port/predict_situp";
      var request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));
      var response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        setState(() {
          _apiResponse = decodedResponse;
        });
        _initializeVideoPlayer(decodedResponse['processed_video_url']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: Failed to upload video.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  Future<void> _getDetailedFeedback() async {
    setState(() {
      _isFetchingFeedback = true;
    });

    try {
      final feedbackUrl = "http://$_ipAddress:$_port/generate_feedback";
      final response = await http.post(
        Uri.parse(feedbackUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_apiResponse), 
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          _detailedFeedback = decodedResponse['feedback'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not fetch feedback.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingFeedback = false;
        });
      }
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: true,
        );
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fitness AI Trainer")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () async {
                  final picker = ImagePicker();
                  _pickedFile = await picker.pickVideo(source: ImageSource.gallery);
                  if (_pickedFile != null) {
                    _uploadVideo(_pickedFile!);
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text("Pick & Upload Video"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_apiResponse != null)
                _buildResultsWidget()
              else
                const Text("Upload a video to get started!"),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildResultsWidget() {
    return Column(
      children: [
        Text("Results", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rep Count: ${_apiResponse!['count']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Final Stage: ${_apiResponse!['stage'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

      
        if (_detailedFeedback != null)
          Card(
            color: Colors.teal.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_detailedFeedback!, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            ),
          )
        else if (_isFetchingFeedback)
          const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
        else
          ElevatedButton.icon(
            onPressed: _getDetailedFeedback,
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Get Detailed Feedback"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
          ),

        const SizedBox(height: 20),

       
        if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
          AspectRatio(
            aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          )
        else
          const Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator()),
      ],
    );
  }
}
