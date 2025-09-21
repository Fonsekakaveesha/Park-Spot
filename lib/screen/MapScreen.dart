// ignore_for_file: prefer_const_constructors, duplicate_ignore, deprecated_member_use, file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:final_pro/screen/CarSlotSelectPage.dart';
import 'package:final_pro/screen/VanSlotSelectPage.dart';
import 'package:final_pro/screen/WheelsSlotSelectPage.dart';
import 'package:final_pro/screen/MotoSlotSelectPage.dart';
import 'package:final_pro/screen/profilepage.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  // Map controller
  final MapController _mapController = MapController();

  // Location service
  final Location _location = Location();

  // Current location
  LocationData? _currentLocation;

  // Initial map position (Colombo, Sri Lanka)
  static const LatLng _initialPosition = LatLng(6.9271, 79.8612);

  // Selected vehicle type for filtering
  String _selectedVehicleType = 'All';

  // Animation controller for bottom sheet
  late AnimationController _animationController;

  // Current selected parking location
  int _selectedLocationIndex = -1;

  // Map markers
  List<Marker> _markers = [];

  // Toggle for list view
  bool _showListView = true;

  // List of parking facilities
  final List<ParkingLocation> _parkingLocations = [
    // ignore: prefer_const_constructors
    ParkingLocation(
      id: '1',
      name: 'City Central Mall Parking',
      address: '123 Main Street, Colombo',
      distance: 0.3,
      availableSpots: 24,
      totalSpots: 50,
      hourlyRate: 100,
      imageUrl: 'assets/images/parking1.jpg',
      position: const LatLng(6.9271, 79.8612),
      supportedVehicles: ['Car', 'Motorcycle', 'Van', 'Three Wheel'],
      amenities: ['Security', 'Covered', '24 Hours'],
      rating: 4.5,
    ),
    // ignore: prefer_const_constructors
    ParkingLocation(
      id: '2',
      name: 'Harbor Side Parking',
      address: '45 Port Road, Colombo',
      distance: 0.8,
      availableSpots: 12,
      totalSpots: 30,
      hourlyRate: 150,
      imageUrl: 'assets/images/parking2.jpg',
      position: const LatLng(6.9334, 79.8500),
      supportedVehicles: ['Car', 'Van'],
      amenities: ['Security', 'Charging'],
      rating: 4.2,
    ),
    ParkingLocation(
      id: '3',
      name: 'University Campus Parking',
      address: 'University Road, Colombo',
      distance: 1.2,
      availableSpots: 32,
      totalSpots: 100,
      hourlyRate: 80,
      imageUrl: 'assets/images/parking3.jpg',
      position: const LatLng(6.9220, 79.8670),
      supportedVehicles: ['Car', 'Motorcycle', 'Three Wheel'],
      amenities: ['Covered', 'CCTV'],
      rating: 4.7,
    ),
    ParkingLocation(
      id: '4',
      name: 'Station Road Parking',
      address: '78 Station Road, Colombo',
      distance: 1.5,
      availableSpots: 8,
      totalSpots: 25,
      hourlyRate: 120,
      imageUrl: 'assets/images/parking1.jpg',
      position: const LatLng(6.9300, 79.8550),
      supportedVehicles: ['Car', 'Van', 'Three Wheel'],
      amenities: ['Security', '24 Hours'],
      rating: 3.9,
    ),
  ];

  // Filtered parking locations based on vehicle type
  List<ParkingLocation> get _filteredLocations {
    if (_selectedVehicleType == 'All') {
      return _parkingLocations;
    } else {
      return _parkingLocations
          .where(
            (location) =>
                location.supportedVehicles.contains(_selectedVehicleType),
          )
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set up location service
    _initLocationService();

    // Set up map markers
    _setupMarkers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Initialize the location service
  Future<void> _initLocationService() async {
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if app has permission to access location
    permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    // Get current location
    _currentLocation = await _location.getLocation();

    // Move map to current location
    if (_currentLocation != null) {
      _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        15.0,
      );
    }

    // Listen for location changes
    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }

  // Set up map markers
  void _setupMarkers() {
    setState(() {
      _markers =
          _parkingLocations
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final location = entry.value;
                final availability =
                    location.availableSpots / location.totalSpots;

                // Determine marker color based on availability
                Color markerColor = Colors.red;
                if (availability > 0.5) {
                  markerColor = Colors.green;
                } else if (availability > 0.2) {
                  markerColor = Colors.orange;
                }

                return Marker(
                  width: 40.0,
                  height: 40.0,
                  point: location.position,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLocationIndex = index;
                        _showListView = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${location.availableSpots}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              'spots',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })
              .toList()
              .cast<Marker>();
    });
  }

  // Show parking location details
  void _showLocationDetails(int index) {
    setState(() {
      _selectedLocationIndex = index;
      _showListView = false;
    });
  }

  // Navigate to appropriate parking screen based on vehicle type
  void _navigateToParkingScreen(String vehicleType) {
    switch (vehicleType) {
      case 'Car':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CarSlotSelectPage()),
        );
        break;
      case 'Van':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VanSlotSelectPage()),
        );
        break;
      case 'Motorcycle':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MotoSlotSelectPage()),
        );
        break;
      case 'Three Wheel':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WheelsSlotSelectPage()),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CarSlotSelectPage()),
        );
    }
  }

  // Modified build method to ensure map is visible
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Leaflet Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 13.0,
              maxZoom: 18.0,
              minZoom: 3.0,
              onTap: (_, point) {
                // Close any open marker info if user taps on the map
                if (_selectedLocationIndex != -1) {
                  setState(() {
                    _selectedLocationIndex = -1;
                    _showListView = true;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smartpark',
                subdomains: const ['a', 'b', 'c'],
                maxNativeZoom: 19,
              ),
              MarkerLayer(markers: _markers),
              // User location marker
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 20.0,
                      height: 20.0,
                      point: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Material(
                elevation: 5,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for parking',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          onPressed: () {
                            // Show filter options
                            _showFilterDialog();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Vehicle Type Tabs
          Positioned(
            top: 90,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildVehicleTypeTab('All', Icons.all_inclusive),
                    _buildVehicleTypeTab('Car', Icons.directions_car),
                    _buildVehicleTypeTab('Van', Icons.airport_shuttle),
                    _buildVehicleTypeTab('Motorcycle', Icons.motorcycle),
                    _buildVehicleTypeTab(
                      'Three Wheel',
                      Icons.electric_rickshaw,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sheet - Parking List
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showListView ? 0 : -500,
            left: 0,
            right: 0,
            height:
                MediaQuery.of(context).size.height *
                0.5, // 50% of screen height
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Parking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_filteredLocations.length} Found',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List of parking locations
                  Expanded(
                    child:
                        _filteredLocations.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_parking,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No parking spaces found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try changing your filters',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _filteredLocations.length,
                              itemBuilder: (context, index) {
                                final location = _filteredLocations[index];

                                return _buildParkingCard(location, index);
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet - Selected Parking
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: (_selectedLocationIndex != -1 && !_showListView) ? 0 : -500,
            left: 0,
            right: 0,
            child:
                _selectedLocationIndex != -1
                    ? _buildSelectedParkingDetails()
                    : const SizedBox(),
          ),

          // Toggle list/details button
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  if (!_showListView) {
                    _showListView = true;
                    _selectedLocationIndex = -1;
                  } else {
                    _showListView = !_showListView;
                  }
                });
              },
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              elevation: 3,
              label: Text(_showListView ? 'Hide List' : 'Show List'),
              icon: Icon(
                _showListView
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
              ),
            ),
          ),

          // Location button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_currentLocation != null) {
                  _mapController.move(
                    LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                    15.0,
                  );
                }
              },
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              elevation: 3,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Profile button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: "profileBtn",
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: Icon(Icons.person_outline, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeTab(String type, IconData icon) {
    bool isSelected = _selectedVehicleType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = type;
          // Update filtered locations and markers
          _setupMarkers();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade700,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingCard(ParkingLocation location, int index) {
    final availability = location.availableSpots / location.totalSpots;
    Color availabilityColor = Colors.red;
    if (availability > 0.5) {
      availabilityColor = Colors.green;
    } else if (availability > 0.2) {
      availabilityColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showLocationDetails(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name, rating, price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        location.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          ' ${location.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rs. ${location.hourlyRate}/hr',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location.address,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Availability and Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: availabilityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_parking,
                                size: 14,
                                color: availabilityColor,
                              ),
                              Text(
                                ' ${location.availableSpots}/${location.totalSpots}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: availabilityColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 14,
                                color: Colors.blue.shade700,
                              ),
                              Text(
                                ' ${location.distance} km',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        // If there are supported vehicles, show dialog to select one
                        if (location.supportedVehicles.isNotEmpty) {
                          _showVehicleSelectionDialog(
                            location.supportedVehicles,
                          );
                        } else {
                          _navigateToParkingScreen('Car');
                        }
                      },
                      icon: const Icon(Icons.local_parking, size: 16),
                      label: const Text('Park'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        minimumSize: const Size(80, 32),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedParkingDetails() {
    if (_selectedLocationIndex < 0 ||
        _selectedLocationIndex >= _parkingLocations.length) {
      return const SizedBox();
    }

    final location = _parkingLocations[_selectedLocationIndex];
    final availability = location.availableSpots / location.totalSpots;
    Color availabilityColor = Colors.red;
    if (availability > 0.5) {
      availabilityColor = Colors.green;
    } else if (availability > 0.2) {
      availabilityColor = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Parking details
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                // Header: Name, rating, close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location.address,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedLocationIndex = -1;
                          _showListView = true;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats cards
                Row(
                  children: [
                    _buildStatCard(
                      'Availability',
                      '${location.availableSpots}/${location.totalSpots}',
                      Icons.local_parking,
                      availabilityColor,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Distance',
                      '${location.distance} km',
                      Icons.directions_car,
                      Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Rate',
                      'Rs. ${location.hourlyRate}/h',
                      Icons.attach_money,
                      Colors.green.shade700,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Amenities
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Facilities',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          location.amenities.map((amenity) {
                            IconData iconData;
                            switch (amenity) {
                              case 'Security':
                                iconData = Icons.security;
                                break;
                              case 'Covered':
                                iconData = Icons.roofing;
                                break;
                              case '24 Hours':
                                iconData = Icons.access_time;
                                break;
                              case 'CCTV':
                                iconData = Icons.videocam;
                                break;
                              case 'Charging':
                                iconData = Icons.electric_car;
                                break;
                              default:
                                iconData = Icons.check_circle;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    iconData,
                                    size: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    amenity,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Vehicle types
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supported Vehicles',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children:
                          location.supportedVehicles.map((vehicle) {
                            IconData iconData;
                            switch (vehicle) {
                              case 'Car':
                                iconData = Icons.directions_car;
                                break;
                              case 'Van':
                                iconData = Icons.airport_shuttle;
                                break;
                              case 'Motorcycle':
                                iconData = Icons.motorcycle;
                                break;
                              case 'Three Wheel':
                                iconData = Icons.electric_rickshaw;
                                break;
                              default:
                                iconData = Icons.directions_car;
                            }

                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      iconData,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    vehicle,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Get directions
                          // In a real app, this would use a maps API to provide directions
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Getting directions...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // If there are supported vehicles, show dialog to select one
                          if (location.supportedVehicles.isNotEmpty) {
                            _showVehicleSelectionDialog(
                              location.supportedVehicles,
                            );
                          } else {
                            _navigateToParkingScreen('Car');
                          }
                        },
                        icon: const Icon(Icons.local_parking),
                        label: const Text('Park Here'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Parking'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Filter options would go here'),
                SizedBox(height: 10),
                Text('- Distance'),
                Text('- Price range'),
                Text('- Availability'),
                Text('- Facilities'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Apply',
                style: TextStyle(color: Colors.blue.shade700),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Apply filters
              },
            ),
          ],
        );
      },
    );
  }

  void _showVehicleSelectionDialog(List<String> supportedVehicles) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Vehicle Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  supportedVehicles.map((vehicle) {
                    IconData iconData;
                    switch (vehicle) {
                      case 'Car':
                        iconData = Icons.directions_car;
                        break;
                      case 'Van':
                        iconData = Icons.airport_shuttle;
                        break;
                      case 'Motorcycle':
                        iconData = Icons.motorcycle;
                        break;
                      case 'Three Wheel':
                        iconData = Icons.electric_rickshaw;
                        break;
                      default:
                        iconData = Icons.directions_car;
                    }

                    return ListTile(
                      leading: Icon(iconData, color: Colors.blue.shade700),
                      title: Text(vehicle),
                      onTap: () {
                        Navigator.of(context).pop();
                        _navigateToParkingScreen(vehicle);
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ParkingLocation {
  final String id;
  final String name;
  final String address;
  final double distance; // km
  final int availableSpots;
  final int totalSpots;
  final double hourlyRate;
  final String imageUrl;
  final LatLng
  position; // Changed from GoogleMaps LatLng to latlong2 package LatLng
  final List<String> supportedVehicles;
  final List<String> amenities;
  final double rating;

  const ParkingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.availableSpots,
    required this.totalSpots,
    required this.hourlyRate,
    required this.imageUrl,
    required this.position,
    required this.supportedVehicles,
    required this.amenities,
    required this.rating,
  });
}
