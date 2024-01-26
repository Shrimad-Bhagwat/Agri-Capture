import 'dart:io';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../model/farmer.dart';

class FarmersListScreen extends StatefulWidget {
  @override
  _FarmersListScreenState createState() => _FarmersListScreenState();
}

class _FarmersListScreenState extends State<FarmersListScreen> {
  late List<Farmer> farmers;

  @override
  void initState() {
    super.initState();
    loadFarmers();
  }

  // Fetch farmers from local storage
  Future<void> loadFarmers() async {
    farmers = await FarmerPreferences.getFarmers();
    setState(() {}); // Trigger a rebuild of the widget tree
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Farmers List'),
      ),
      body: farmers.isEmpty
          ? const Center(
              child: Text('No farmers available.'),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: buildFarmersTable(),
            ),
    );
  }

  // Displaying Farmers in Table
  Widget buildFarmersTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Address')),
        DataColumn(label: Text('DOB')),
        DataColumn(label: Text('Gender')),
        DataColumn(label: Text('Farm Land Area')),
        DataColumn(label: Text('Latitude')),
        DataColumn(label: Text('Longitude')),
        DataColumn(label: Text('Image 1')),
        DataColumn(label: Text('Image 2')),
        DataColumn(label: Text('Video')),
      ],
      rows: farmers.map((farmer) {
        return DataRow(
          cells: [
            DataCell(Text(farmer.name)),
            DataCell(Text(farmer.address)),
            DataCell(Text(farmer.dob)),
            DataCell(Text(farmer.gender)),
            DataCell(Text(farmer.farmLandArea)),
            DataCell(Text(farmer.latitude)),
            DataCell(Text(farmer.longitude)),
            DataCell(GestureDetector(
                onTap: () => _showImageAlertDialog(context, farmer.image1),
                child: const Text(
                  "Image 1 ",
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ))),
            DataCell(GestureDetector(
                onTap: () => _showImageAlertDialog(context, farmer.image2),
                child: const Text(
                  "Image 2 ",
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ))),
            DataCell((farmer.videoPath != null)
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoScreen(
                                  videoFilePath: farmer.videoPath)));
                    },
                    child: const Text("Video", style: TextStyle(color: Colors.blue,decoration: TextDecoration.underline),))
                : const Text("Video not found!")),
          ],
        );
      }).toList(),
    );
  }

  // Display images
  void _showImageAlertDialog(BuildContext context, String myfile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.file(File(myfile)),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the AlertDialog
                },
                child: const Text('Close'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Display Video on another screen
class VideoScreen extends StatefulWidget {
  final String videoFilePath;

  VideoScreen({required this.videoFilePath});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();

    flickManager = FlickManager(
      videoPlayerController:
          VideoPlayerController.file(File(widget.videoFilePath)),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: FlickVideoPlayer(
            flickManager: flickManager,
          ),
        ),
      ),
    );
  }
}
