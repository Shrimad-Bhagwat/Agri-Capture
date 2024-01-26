import 'dart:io';
import 'package:agricapture/constants.dart';
import 'package:agricapture/screens/farmers_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';
import '../model/farmer.dart';
import 'package:agricapture/api-key.dart';

class FarmerFormScreen extends StatefulWidget {
  const FarmerFormScreen({super.key});

  @override
  _FarmerFormScreenState createState() => _FarmerFormScreenState();
}

class _FarmerFormScreenState extends State<FarmerFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form Fields
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  String _gender = "Male";
  TextEditingController _landAreaController = TextEditingController();
  Position _currentPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      altitudeAccuracy: 1,
      heading: 0,
      headingAccuracy: 1,
      speed: 0,
      speedAccuracy: 1);

  late String _currentAddress = "";
  late double _latitude;
  late double _longitude;
  String titleLocation = "Agri Capture";
  String tempLocation = "";
  String weatherDesc = "";
  WeatherFactory wf = new WeatherFactory(apiKey);
  bool _loading = false;

  File? selectedImage1, selectedImage2, selectedVideo;
  late SharedPreferences sharedPreferences;

  String getAppBarBackground() {
    // Choose background based on weather condition
    if (weatherDesc == 'Clouds') {
      return 'images/clear.png';
    } else if (weatherDesc == 'Clear') {
      return 'images/cloudy.png';
    } else {
      return 'images/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check dark mode
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      // Dynamic Appbar
      appBar: AppBar(
        title: Text("$titleLocation   $tempLocation   $weatherDesc",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(getAppBarBackground()),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          // Farmers List Button
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FarmersListScreen()));
              },
              icon: const Icon(
                Icons.list_alt_rounded,
                color: Colors.white,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Farmer Name', prefixIcon: Icon(Icons.person)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the farmer name';
                  }
                  return null;
                },
              ),
              kHalfSizedBox,
              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                    labelText: 'Address', prefixIcon: Icon(Icons.home)),
                maxLines: 3,
              ),
              kHalfSizedBox,
              // Dob
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Select date of birth',
                    prefixIcon: Icon(Icons.calendar_month_rounded)),
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (date != null) {
                    _dobController.text =
                        "${date.day}/${date.month}/${date.year}";
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please select the date of birth';
                  }
                  return null;
                },
              ),
              kHalfSizedBox,
              // Gender
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                decoration: const InputDecoration(
                    labelText: 'Gender', prefixIcon: Icon(Icons.male_rounded)),
              ),
              kHalfSizedBox,
              // Land Area
              TextFormField(
                controller: _landAreaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Farm Land Area in Acres *',
                    prefixIcon: Icon(Icons.landscape_rounded)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the land area';
                  }
                  double? landArea = double.tryParse(value);
                  if (landArea == null || landArea > 100) {
                    return 'Enter a valid land area (not more than 100)';
                  }
                  return null;
                },
              ),
              kHalfSizedBox,
              kHalfSizedBox,
              // Location
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 8,
                    child: isDarkMode ? const Icon(
                            Icons.location_on,
                            color: Colors.white54,
                          ) : const Icon(
                      Icons.location_on,
                      color: Colors.black87,
                    ),
                  ),
                  kWidthSizedBox,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentPosition != null)
                        Center(
                          child: Text(
                              "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"),
                        ),
                      Center(
                        child: Text(_currentAddress),
                      ),
                    ],
                  )
                ],
              ),
              kHalfSizedBox,
              OutlinedButton(
                child: (_loading)
                    ? const CircularProgressIndicator()
                    : const Text("Get Current location"),
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });

                    _getCurrentLocation();

                  setState(() {
                    _loading = false;
                  });
                },
              ),
              kHalfSizedBox,

              // Images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Image 1
                  InkWell(
                    onTap: () => _pickImageFromCamera1(),
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.all(10),
                      child: selectedImage1 != null
                          ? Image.file(
                              selectedImage1!,
                              width: 120,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 120,
                              height: 150,
                              decoration: const BoxDecoration(color: Colors.white54),
                              child: const Icon(Icons.camera_alt_rounded),
                            ),
                    ),
                  ),
                  // Image 2
                  InkWell(
                    onTap: () => _pickImageFromCamera2(),
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.all(10),
                      child: selectedImage2 != null
                          ? Image.file(
                              selectedImage2!,
                              width: 120,
                              height: 150,
                              fit: BoxFit.fill,
                            )
                          : Container(
                              width: 120,
                              height: 150,
                              decoration: const BoxDecoration(color: Colors.white54),
                              child: const Icon(Icons.camera_alt_rounded),
                            ),
                    ),
                  ),
                ],
              ),
              kHalfSizedBox,

              // Video
              InkWell(
                onTap: () => _pickVideoFromCamera(),
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.all(10),
                  child: selectedVideo == null
                      ? Container(
                          height: 100,
                          decoration: const BoxDecoration(color: Colors.white54),
                          child: const Icon(Icons.videocam_rounded),
                        )
                      : Center(
                          child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (selectedVideo?.path != null)
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("Video Saved Successfully!"),
                                )
                              : const Text("Error!"),
                        )),
                ),
              ),
              kHalfSizedBox,

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();

                  if (selectedVideo == null ) {
                    showDetailsSnackBar("Select Video!");
                  } else if (selectedImage2 == null) {
                    showDetailsSnackBar("Select Image 2!");
                  } else if (selectedImage1 == null) {
                    showDetailsSnackBar("Select Image 1!");
                  } else if (_currentPosition == null) {
                    showDetailsSnackBar("Select Current Location");
                  } else {
                    if (_formKey.currentState!.validate()) {
                      saveFarmer();
                      showDetailsSnackBar("Details Saved Successfully!");

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FarmersListScreen()));

                      // Clear textfields
                      setState(() {
                        _nameController.text = "";
                        _addressController.text = "";
                        _dobController.text = "";
                        _landAreaController.text = "";
                        _currentPosition = Position(
                            longitude: 0,
                            latitude: 0,
                            timestamp: DateTime.now(),
                            accuracy: 1,
                            altitude: 0,
                            altitudeAccuracy: 1,
                            heading: 0,
                            headingAccuracy: 1,
                            speed: 0,
                            speedAccuracy: 1);
                        _currentAddress = "";
                        selectedImage1 = null;
                        selectedImage2 = null;
                        selectedVideo = null;
                      });
                    } else {
                      showDetailsSnackBar("Complete all the details!");
                    }
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDetailsSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Save image to local storage
  void saveImage(XFile img) async {
    final String? path = (await getApplicationDocumentsDirectory())?.path;
    File convertedImage = File(img.path);
    final time = DateTime.now();
    final String fileName = "${time}_image.jpg";
    final File localImage = await convertedImage.copy('$path/$fileName');
    // print("Saved image under $path/$fileName");
  }

  // Save video to local storage
  void saveVideo(XFile video) async {
    final String? path = (await getApplicationDocumentsDirectory())?.path;
    File convertedVideo = File(video.path);
    final time = DateTime.now();
    final String fileName = "${time}_video.mp4";
    final File localImage = await convertedVideo.copy('$path/$fileName');
    // print("Saved video under $path/$fileName");
  }

  // Load image from local storage
  void loadImage(String file) async {
    final String filename = file;
    final String? path = (await getApplicationDocumentsDirectory())?.path;
    if (File('$path/$filename').existsSync()) {
      // print("Image Loaded $path/$filename");
      setState(() {
        selectedImage2 = File('$path/$filename');
      });
    }
  }

  // Getting image 1 from camera
  Future<dynamic> _pickImageFromCamera1() async {
    final XFile? returnImage = await ImagePicker().pickImage(
        source: ImageSource.camera, maxHeight: 720, imageQuality: 50);
    if (returnImage == null) return;
    setState(() {
      selectedImage1 = File(returnImage.path);
    });
    saveImage(returnImage);
  }

  // Getting image 2 from camera
  Future<dynamic> _pickImageFromCamera2() async {
    final XFile? returnImage = await ImagePicker().pickImage(
        source: ImageSource.camera, maxHeight: 720, imageQuality: 50);
    if (returnImage == null) return;
    setState(() {
      selectedImage2 = File(returnImage.path);
    });
    saveImage(returnImage);
  }

  // Getting video from camera
  Future _pickVideoFromCamera() async {
    final XFile? pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: const Duration(seconds: 30));
    if (pickedFile == null) return;
    setState(() {
      if (pickedFile != null) {
        selectedVideo = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
            const SnackBar(content: Text('Error in capturing video!')));
      }
    });
    saveVideo(pickedFile);
  }

  // Getting current location of user
  _getCurrentLocation() async {
    final permission = await Geolocator.isLocationServiceEnabled();
    if (permission == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          padding: EdgeInsets.all(20.0),
          content: Text(
            'Please turn on Location from the settings.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
              forceAndroidLocationManager: true)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
          _latitude = _currentPosition.latitude;
          _longitude = _currentPosition.longitude;
          // _latitude = 23.27;
          // _longitude = 77.33;
          _getAddressFromLatLng();
        });
      }).catchError((e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  // Getting current Address of the user
  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(_latitude, _longitude);
      Weather w = await wf.currentWeatherByLocation(_latitude, _longitude);

      Placemark place = placemarks[0];
      // print("=============${w.weatherMain}");
      setState(() {
        weatherDesc = "${w.weatherMain}";
        titleLocation = "${place.locality}";
        tempLocation = "${w.temperature}";
        tempLocation = tempLocation.substring(0, 4) + " °C";
      });

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }


  // Save the farmer data to your local storage
  void saveFarmer() async {
    Farmer farmer = Farmer(
      name: _nameController.text,
      address: _addressController.text,
      dob: _dobController.text,
      gender: _gender,
      farmLandArea: _landAreaController.text,
      latitude: _latitude.toString(),
      longitude: _longitude.toString(),
      image1: selectedImage1!.path,
      image2: selectedImage2!.path,
      videoPath: selectedVideo!.path,
    );
    try {
      FarmerPreferences.saveFarmer(farmer);
      // String userdata = jsonEncode(farmer);
      // print(userdata);
      // print('**************** Farmer saved');
    } on Exception catch (_) {
      showDetailsSnackBar("Error saving Farmer details!");
      // print('################# Farmer not saved');
    }
  }
}
