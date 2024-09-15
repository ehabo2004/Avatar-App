import 'package:flutter/material.dart';
import 'mqtt.dart'; //import the Mqtt client wrapper
import 'settings.dart'; //import settings page
import 'weathersensors.dart'; //import Weather sensors page
import 'safetysensors.dart'; //import Safety sensors page
import 'sensor_data.dart'; // Import the shared state

class SensorDashboard extends StatefulWidget {
  final String userName;

  SensorDashboard({required this.userName});

  @override
  _SensorDashboardState createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  late MQTTClientWrapper mqttClientWrapper;
  final sensorData = SensorData(); // Create a single instance of SensorData

  @override
  void initState() {
    super.initState();
    mqttClientWrapper = MQTTClientWrapper();
    mqttClientWrapper.onMessageReceived = _onMessageReceived; //set up callback to for messsage reception and subscribe to various Topics
    mqttClientWrapper.prepareMqttClient().then((_) {
      mqttClientWrapper.subscribeToTopic('esp32/temperature');
      mqttClientWrapper.subscribeToTopic('esp32/humidity');
      mqttClientWrapper.subscribeToTopic('esp32/gas');
      mqttClientWrapper.subscribeToTopic('esp32/flame');
      mqttClientWrapper.subscribeToTopic('esp32/uv');
      mqttClientWrapper.subscribeToTopic('esp32/rain');
    });
  }

  /*callback to handle readings come from mqtt , for each topic 
  temperature , rain , humidity , uv and detection of flame and gas*/
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

  /* make background of colors #776483 and #292643 and start from left to right
  and add logo and name of app in the upper bar, then say prints welcome to the user
  when he entered,  then user can see six dashboards , one for temperature,rain,humidity,uv,flame and gas ,
  each dashboard show only the current reading (last reading)but on flame and gas show if they are detected or not
  then add navigators buttons one for settings , one for safety sensors and one for weather sensors page and the home sign is for sensors page*/
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 50,
                    ),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Color.fromARGB(255, 233, 158, 117),
                            Color(0xFF484472)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Avatar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to our app',
                        style: TextStyle(
                          color: Color(0xFFE99E75),
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: [
                          _buildSensorCard(
                            'Temperature',
                            sensorData.temperatureReadings.isNotEmpty
                                ? '${sensorData.temperatureReadings.last} °C'
                                : 'N/A',
                            'assets/temperature.png',
                            Color(0xFFBBAAB8),
                          ),
                          SizedBox(height: 8),
                          _buildSensorCard(
                            'Humidity',
                            sensorData.humidityReadings.isNotEmpty
                                ? '${sensorData.humidityReadings.last} %'
                                : 'N/A',
                            'assets/humidity.png',
                            Color(0xFFBBAAB8),
                          ),
                          SizedBox(height: 8),
                          _buildSensorCard(
                            'Rain',
                            sensorData.rainReadings.isNotEmpty
                                ? '${sensorData.rainReadings.last} mm'
                                : 'N/A',
                            'assets/rain.png',
                            Color(0xFFBBAAB8),
                          ),
                          SizedBox(height: 8),
                          _buildSensorCard(
                            'UV',
                            sensorData.uvReadings.isNotEmpty
                                ? '${sensorData.uvReadings.last} index'
                                : 'N/A',
                            'assets/uv.png',
                            Color(0xFFBBAAB8),
                          ),
                          SizedBox(height: 8),
                          _buildSensorCard(
                            'Gas',
                            sensorData.isGasDetected
                                ? 'Detected'
                                : 'Not Detected',
                            'assets/gas.png',
                            sensorData.isGasDetected
                                ? Colors.red
                                : Color(0xFFBBAAB8),
                          ),
                          SizedBox(height: 8),
                          _buildSensorCard(
                            'Flame',
                            sensorData.isFlameDetected
                                ? 'Detected'
                                : 'Not Detected',
                            'assets/flame.png',
                            sensorData.isFlameDetected
                                ? Colors.red
                                : Color(0xFFBBAAB8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom navigation bar
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(Icons.home, true, () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SensorDashboard(userName: widget.userName),
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
                    _buildBottomNavItem(Icons.settings, false, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* here is responsible for widgets of dashboard , give it color of #515175
  and the title here is one of sensors like rain and flame , value is the reading coming after subscriping to the topics*/
  Widget _buildSensorCard(
      String title, String value, String imagePath, Color textColor) {
    return Container(
      width: double.infinity, // Ensure the card takes the full width
      child: Card(
        color: Color(0xFF515175),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Increased padding inside card
          child: Row(
            children: [
              Image.asset(imagePath,
                  height: 60, color: textColor), // Slightly increased icon size
              SizedBox(width: 16), // Increased space between icon and text
              Expanded(
                child: Text(
                  '$title: $value',
                  style: TextStyle(
                      color: textColor, fontSize: 18), // Increased font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //here is responsible of the navigator icons, if i am in sensors_page , the home icon will be orange and the rest of icons will be white
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
