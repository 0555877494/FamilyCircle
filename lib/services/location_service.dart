import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });
}

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> getLocationStream(String familyId, String memberId) {
    return _firestore.collection('locations')
        .doc('${familyId}_$memberId')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return doc.data() as Map<String, dynamic>;
        });
  }

  Future<void> updateLocation(String familyId, String memberId, double lat, double lng, String? address) async {
    await _firestore.collection('locations').doc('${familyId}_$memberId').set({
      'familyId': familyId,
      'memberId': memberId,
      'latitude': lat,
      'longitude': lng,
      'address': address,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getFamilyLocations(String familyId) async {
    final snapshot = await _firestore.collection('locations')
        .where('familyId', isEqualTo: familyId)
        .get();
    
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}