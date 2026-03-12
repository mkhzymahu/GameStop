import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/address_model.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  LatLng? _selectedLocation;
  String? _currentAddress;
  List<AddressModel> _savedAddresses = [];
  
  bool _isLoading = false;
  bool _locationServiceEnabled = false;
  String? _errorMessage;

  // Getters
  Position? get currentPosition => _currentPosition;
  LatLng? get selectedLocation => _selectedLocation;
  String? get currentAddress => _currentAddress;
  List<AddressModel> get savedAddresses => _savedAddresses;
  bool get isLoading => _isLoading;
  bool get locationServiceEnabled => _locationServiceEnabled;
  String? get errorMessage => _errorMessage;

  LocationProvider() {
    checkLocationService();
  }

  Future<void> checkLocationService() async {
    _isLoading = true;
    notifyListeners();

    try {
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (_locationServiceEnabled) {
        await getCurrentLocation();
      }
    } catch (e) {
      _errorMessage = 'Error checking location service';
      print('Error checking location service: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _selectedLocation = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      _currentAddress = 'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error getting current location';
      _isLoading = false;
      notifyListeners();
      print('Error getting current location: $e');
    }
  }

  Future<void> selectLocation(LatLng location) async {
    _isLoading = true;
    notifyListeners();

    _selectedLocation = location;
    _currentAddress = 'Lat: ${location.latitude}, Lng: ${location.longitude}';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, use Google Places API or similar
      // This is a mock implementation
      _currentAddress = query;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Location not found';
      print('Error searching location: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAddress(AddressModel address) async {
    _savedAddresses.add(address);
    notifyListeners();
  }

  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < _savedAddresses.length) {
      _savedAddresses.removeAt(index);
      notifyListeners();
    }
  }

  void clearSelectedLocation() {
    _selectedLocation = null;
    _currentAddress = null;
    notifyListeners();
  }

  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    ) / 1000; // Convert to kilometers
  }

  Future<LatLng?> getCurrentLocationForDelivery() async {
    await getCurrentLocation();
    return _selectedLocation;
  }
}