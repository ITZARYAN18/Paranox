import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';







class JumpScreen extends StatefulWidget {
  const JumpScreen({super.key});

  @override
  State<JumpScreen> createState() => _JumpScreenState();
}

class _JumpScreenState extends State<JumpScreen> {
  // --- STATE VARIABLES ---
  bool _isLoading = false;
  Map<String, dynamic>? _apiResponse;
  XFile? _pickedFile;

  // Video player controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // --- IMPORTANT: CHANGE THIS TO YOUR COMPUTER'S IP ADDRESS ---
  final String _apiUrl = "http://10.223.35.72:8000/predict_jump";

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  // --- LOGIC TO UPLOAD THE VIDEO ---
  Future<void> _uploadVideo(XFile videoFile) async {
    // --- THIS IS THE CORRECTED PART ---
    // Step 1: Dispose and nullify old controllers BEFORE rebuilding the UI.
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;

    // Step 2: Now, safely update the UI to show the loading state.
    setState(() {
      _isLoading = true;
      _apiResponse = null; // Clear previous results
    });
    // --- END OF CORRECTION ---

    try {
      var request = http.MultipartRequest("POST", Uri.parse(_apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('file', videoFile.path),
      );
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
        print("API call failed with status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to upload video.')),
        );
      }
    } catch (e) {
      print("An error occurred: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- LOGIC TO INITIALIZE THE VIDEO PLAYER ---
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

  // --- UI WIDGETS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness AI Trainer"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
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
        Text(
          "Results",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rep Count: ${_apiResponse!['count']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Stage: ${_apiResponse!['stage'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Feedback: ${_apiResponse!['feedback'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
          AspectRatio(
            aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}