import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Farmer Model
class Farmer {
  String name;
  String address;
  String dob;
  String gender;
  String farmLandArea;
  String latitude;
  String longitude;
  String image1;
  String image2;
  String videoPath;

  Farmer({
    required this.name,
    required this.address,
    required this.dob,
    required this.gender,
    required this.farmLandArea,
    required this.latitude,
    required this.longitude,
    required this.image1,
    required this.image2,
    required this.videoPath,
  });

  // To change Farmer object to json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'dob': dob,
      'gender': gender,
      'farmLandArea': farmLandArea,
      'latitude': latitude,
      'longitude': longitude,
      'image1': image1,
      'image2': image2,
      'videoPath': videoPath,
    };
  }

  // Get farmer object from json
  Farmer.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        address = json['address'],
        dob = json['dob'],
        gender = json['gender'],
        farmLandArea = json['farmLandArea'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        image1 = json['image1'],
        image2 = json['image2'],
        videoPath = json['videoPath'];
}

// Storing Farmer objects
class FarmerPreferences {
  static Future<void> saveFarmer(Farmer farmer) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Generate a Unique UID for the farmer
    final String farmerId = Uuid().v4();

    final String farmerJson = jsonEncode(farmer.toJson());

    // Save the JSON data with the UUID key
    prefs.setString(farmerId, farmerJson);
  }

  static Future<List<Farmer>> getFarmers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve all keys from SharedPreferences
    final List<String> keys = prefs.getKeys().toList();

    // Retrieve and deserialize each Farmer object
    final List<Farmer> farmers = [];
    for (String key in keys) {
      final String? farmerJson = prefs.getString(key);
      if (farmerJson != null) {
        final Map<String, dynamic> farmerMap = jsonDecode(farmerJson);
        final Farmer farmer = Farmer.fromJson(farmerMap);
        farmers.add(farmer);
      }
    }

    return farmers;
  }
}