import 'package:flutter/material.dart';
import 'mqtt.dart'; // Import the MQTT client wrapper
import 'sensors_page.dart'; // Import the file where SensorDashboard is defined
import 'weathersensors.dart'; // Import the file where WeatherSensors is defined
import 'safetysensors.dart'; // Import the file where SafetySensors is defined
import 'login_page.dart'; // Import the LoginPage
import 'sensor_data.dart'; //import the readings from sensor_data page
import 'about_page.dart'; // Import the new AboutPage

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

//here settings has addtional function to change frequency of buzzer
class _SettingsPageState extends State<SettingsPage> {
  late MQTTClientWrapper mqttClientWrapper; // instacne of MQTT client wrapper
  double _buzzerFrequency = 0; // Default frequency for buzzer

  //initialize the MQTT client and set the message receieve
  @override
  void initState() {
    super.initState();
    mqttClientWrapper = MQTTClientWrapper();
    mqttClientWrapper.onMessageReceived = _onMessageReceived;

    // Prepare the MQTT client and subscribe to topics
    mqttClientWrapper.prepareMqttClient().then((_) {
      mqttClientWrapper.subscribeToTopic('esp32/temperature');
      mqttClientWrapper.subscribeToTopic('esp32/humidity');
      mqttClientWrapper.subscribeToTopic('esp32/gas');
      mqttClientWrapper.subscribeToTopic('esp32/flame');
      mqttClientWrapper.subscribeToTopic('esp32/uv');
      mqttClientWrapper.subscribeToTopic('esp32/rain');
    });
  }

  //update the buzzer frequency and publish it to the MQTT topic
  void _updateBuzzerFrequency(double frequency) {
    setState(() {
      _buzzerFrequency = frequency;
    });
    mqttClientWrapper.publishMessage(
        'esp32/buzzer', _buzzerFrequency.toStringAsFixed(0));
  }

  //handle incoming MQTT messgae or readings and update the sensor data in sensor_data page
  void _onMessageReceived(String topic, String message) {
    final sensorData = SensorData();
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
          break;
        case 'esp32/flame':
          sensorData.isFlameDetected = message == '1';
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

  // add sign out button ,when user click on it he returns to login page
  void _signOut() {
    // Clear any user-specific data or session here if needed

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  /*set up the color of the page to be like other pages and add icon and button of about 
  when user click on the "About" text , user goes to about page, then set the crusor of buzzer frquency to color of#E99E75
  set up buzzer frequncy range from zero to 10000, then set up sign out color to #E99E75
  add the navigator below to naviagte from settings to other pages like weather sensors page and home page (sensors_page)*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF776483), Color(0xFF292643)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 16.0),
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE99E75),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Color(0xFFBBAAB8),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'About',
                          style: TextStyle(
                            color: Color(0xFFBBAAB8),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Buzzer Frequency',
                    style: TextStyle(
                      color: Color(0xFFBBAAB8),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 Hz',
                        style: TextStyle(color: Color(0xFFE99E75)),
                      ),
                      Expanded(
                        child: Slider(
                          value: _buzzerFrequency,
                          min: 0,
                          max: 10000,
                          divisions: 100,
                          label: '${_buzzerFrequency.toStringAsFixed(0)} Hz',
                          activeColor: Color(0xFFE99E75),
                          onChanged: _updateBuzzerFrequency,
                        ),
                      ),
                      Text(
                        '10000 Hz',
                        style: TextStyle(color: Color(0xFFE99E75)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(), // Spacer before Sign Out button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBBAAB8), // Button fill color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(Icons.home, false, () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SensorDashboard(userName: 'YourUsername'),
                        ),
                      );
                    }),
                    _buildBottomNavItem(Icons.cloud, false, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeatherSensors(),
                        ),
                      );
                    }),
                    _buildBottomNavItem(Icons.warning_amber_outlined, false,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SafetySensors(),
                        ),
                      );
                    }),
                    _buildBottomNavItem(Icons.settings, true, () {
                      // Stay on settings page
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //same as rest of pages when i user is in setting , settings icon will be color of #E99E75 and rest are white
  Widget _buildBottomNavItem(
      IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? Color(0xFFE99E75) : Colors.white,
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: Color(0xFFE99E75),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
