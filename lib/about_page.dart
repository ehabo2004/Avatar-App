import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'sensor_data.dart'; // Import your SensorData class
import 'mqtt.dart'; // Import your MQTTClientWrapper class

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

// declare an instance of mqtt and instance of sensor data to store sensors reading
class _AboutPageState extends State<AboutPage> {
  late MQTTClientWrapper mqttClientWrapper;
  SensorData sensorData = SensorData();
  final Uri url =
      Uri.parse('https://github.com/AhmedMohamady1/IoT-Project-Avatar'); //gtihub link of our project
// initialize the mqtt client and set the callback for receiving data
  @override
  void initState() {
    super.initState();
    mqttClientWrapper = MQTTClientWrapper();
    mqttClientWrapper.onMessageReceived = _onMessageReceived;
    mqttClientWrapper.prepareMqttClient().then((_) {
      // prepare the mqtt client and subscribe to topics 
      mqttClientWrapper.subscribeToTopic('esp32/temperature');
      mqttClientWrapper.subscribeToTopic('esp32/humidity');
      mqttClientWrapper.subscribeToTopic('esp32/gas');
      mqttClientWrapper.subscribeToTopic('esp32/flame');
      mqttClientWrapper.subscribeToTopic('esp32/uv');
      mqttClientWrapper.subscribeToTopic('esp32/rain');
    });
  }
// callback to handle received mqtt messages
  void _onMessageReceived(String topic, String message) {
    setState(() {
      switch (topic) {
        case 'esp32/temperature':
          sensorData.temperatureReadings.add(int.tryParse(message) ?? 0);
          break;
        case 'esp32/humidity':
          sensorData.humidityReadings.add(int.tryParse(message) ?? 0);
          break;
        case 'esp32/gas':
          sensorData.isGasDetected = message == '1';
          sensorData.gasDetectionReadings.add(sensorData.isGasDetected ? 1 : 0);
          break;
        case 'esp32/flame':
          sensorData.isFlameDetected = message == '1';
          sensorData.flameDetectionReadings
              .add(sensorData.isFlameDetected ? 1 : 0);
          break;
        case 'esp32/uv':
          sensorData.uvReadings.add(int.tryParse(message) ?? 0);
          break;
        case 'esp32/rain':
          sensorData.rainReadings.add(int.tryParse(message) ?? 0);
          break;
      }
    });
  }

/* add the app bar , put "About" text and back button to navigate back to settings
add the logo and name of app, then brief about the project , then a contact part, our names
and our emails , then put the version of the app , then icon github when user click on it 
leads him to github of the project */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            color: Color(0xFFBBAAB8), // Set color of "About" text
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFFBBAAB8), // Set color of back button icon
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF776483), Color(0xFF292643)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF776483), Color(0xFF292643)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 1), 
                Image.asset(
                  'assets/logo.png',
                  height: 120,
                  width: 120,
                ),
                SizedBox(height: 1), 
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Color(0xFFE99E75), Color(0xFF44426E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Avatar',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Avatar app provides real-time data on temperature, humidity, rain, UV levels, and detects gas and flame. Stay informed with accurate sensor data.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE99E75),
                  ),
                ),
                SizedBox(height: 16),
                _buildContactInfo('Ahmed', 'ahmed34@gmail.com'),
                _buildContactInfo('Omar', 'omar25@gmail.com'),
                _buildContactInfo('Mohamed', 'mohamed71@gmail.com'),
                _buildContactInfo('Mazen', 'mazen56@gmail.com'),
                _buildContactInfo('Fares', 'fares84@gmail.com'),
                SizedBox(height: 16),
                Text(
                  'Version: v1.3',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    if (!await launchUrl(url,
                        mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/git.png',
                        height: 100, 
                        width: 100, 
                      ),
                      SizedBox(height: 8),
                      Text(
                        'GitHub Repository',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFBBAAB8),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget responsible for displaying each team member's name and email
  Widget _buildContactInfo(String name, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$name: $email',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
