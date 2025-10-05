import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GymMapPage extends StatefulWidget {
  @override
  _GymMapPageState createState() => _GymMapPageState();
}

class _GymMapPageState extends State<GymMapPage> {
  final MapController _mapController = MapController();

 
  LatLng _center = LatLng(28.4595, 77.0266); 

 
  List<Marker> _markers = [];
  bool _isLoading = true;
  String? _error;

 
  final List<Map<String, dynamic>> _gymData = [
    {'name': 'PowerHouse Gym', 'lat': 28.4595, 'lng': 77.0266, 'rating': 4.5, 'distance': '0.5 km'},
    {'name': 'Gold\'s Gym', 'lat': 28.4620, 'lng': 77.0300, 'rating': 4.2, 'distance': '1.2 km'},
    {'name': 'Fitness First', 'lat': 28.4550, 'lng': 77.0200, 'rating': 4.0, 'distance': '0.8 km'},
    {'name': 'Anytime Fitness', 'lat': 28.4650, 'lng': 77.0350, 'rating': 4.3, 'distance': '1.8 km'},
    {'name': 'Cult.fit Center', 'lat': 28.4500, 'lng': 77.0150, 'rating': 4.4, 'distance': '1.5 km'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

 
  Future<void> _initializeMap() async {
    try {
      await _requestLocationPermission();
      await _getCurrentLocation();
      _createMarkers(); 
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
       
        _center = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
     
    }
  }

  void _createMarkers() {
   
    final gymMarkers = _gymData.map((gym) {
      
      return Marker(
        point: LatLng(gym['lat'], gym['lng']),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${gym['name']} - ${gym['rating']} ⭐'),
              ),
            );
          },
          child: Column(
            children: [
              Icon(Icons.location_pin, color: Colors.blue, size: 40),
              Text(gym['name'], style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
            ],
          ),
        ),
      );
    }).toList();

   
    final userMarker = Marker(
      point: _center,
      width: 80,
      height: 80,
      child: Icon(Icons.my_location, color: Colors.red, size: 40),
    );

    setState(() {
      _markers = [...gymMarkers, userMarker];
    });
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Gyms (OSM)'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search gyms near you...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
           
            child: _buildMapWidget(),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _gymData.length,
              itemBuilder: (context, index) {
                final gym = _gymData[index];
                return _buildGymListItem(gym);
              },
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildMapWidget() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: 13.0,
      ),
      children: [
       
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.aryan.kevin_11', 
        ),
      
        MarkerLayer(
          markers: _markers,
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              '© OpenStreetMap contributors',
              onTap: () {
                
              },
            ),
          ],
        ),
      ],

    );
  }

 
  Widget _buildErrorWidget() {
    return Center();
  }


    
  Widget _buildGymListItem(Map<String, dynamic> gym) {
    return InkWell(
      onTap: () {
    
        _mapController.move(
          LatLng(gym['lat'], gym['lng']),
          16.0, 
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Centered map on ${gym['name']}")),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 40, color: Colors.green),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gym['name'],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Distance: ${gym['distance']}',
                        style: TextStyle(color: Colors.grey[600])),
                    SizedBox(height: 2),
                    Text('⭐ ${gym['rating']}',
                        style: TextStyle(color: Colors.orange[800])),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.directions, color: Colors.blue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Getting directions to ${gym['name']}...")),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Calling ${gym['name']}...")),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
