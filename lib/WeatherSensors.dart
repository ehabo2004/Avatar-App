import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package
import 'sensor_data.dart'; // Import the shared state
import 'mqtt.dart'; // import the mqtt client wrapper
import 'sensors_page.dart'; //import the home page
import 'settings.dart'; //import the settings page
import 'safetysensors.dart'; // import the safety sensors page

class WeatherSensors extends StatefulWidget {
  @override
  _WeatherSensorsState createState() => _WeatherSensorsState();
}

//set up the mqtt client for receivig sensor data and get shared state from sensor_data page
class _WeatherSensorsState extends State<WeatherSensors> {
  late MQTTClientWrapper mqttClientWrapper;
  final SensorData sensorData = SensorData(); // Shared state for sensor data

  // here function to subcripe to each topic of each sensor
  @override
  void initState() {
    super.initState();
    mqttClientWrapper = MQTTClientWrapper();
    mqttClientWrapper.onMessageReceived = _onMessageReceived;
    mqttClientWrapper.prepareMqttClient().then((_) {
      mqttClientWrapper.subscribeToTopic('esp32/temperature');
      mqttClientWrapper.subscribeToTopic('esp32/humidity');
      mqttClientWrapper.subscribeToTopic('esp32/gas');
      mqttClientWrapper.subscribeToTopic('esp32/flame');
      mqttClientWrapper.subscribeToTopic('esp32/uv');
      mqttClientWrapper.subscribeToTopic('esp32/rain');
    });
  }

  /* here as sensors_page takes readings from mqtt*/
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

  /* as same as sensors_page make a dashboards for each sensor in 
  weather sensors page, each dahsboard display the current reading
  and the maximum value has come from the topic and minimum value, and average of all readings of the sensor
  */
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
                  'Weather Sensors',
                  style: TextStyle(
                    color: Color(0xFFE99E75),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            /* and here we make graphs for each sensor
            we use line graphs here in weather sensor page, each graph is 
            continous graphs, we seperate dashboards of readings and max, min and average away 
            from dashboards of graphs , then there is naivgator to naivgate from page to another, from weather to rest pages */
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildSensorDashboard(
                    'Temperature',
                    sensorData.temperatureReadings,
                    'assets/temperature.png',
                  ),
                  SizedBox(height: 8),
                  _buildSensorDashboard(
                    'Humidity',
                    sensorData.humidityReadings,
                    'assets/humidity.png',
                  ),
                  SizedBox(height: 8),
                  _buildSensorDashboard(
                    'Rain',
                    sensorData.rainReadings,
                    'assets/rain.png',
                  ),
                  SizedBox(height: 16),
                  _buildSensorGraph(
                    'Temperature Graph',
                    sensorData.temperatureReadings,
                    Colors.red,
                  ),
                  SizedBox(height: 16),
                  _buildSensorGraph(
                    'Humidity Graph',
                    sensorData.humidityReadings,
                    Colors.blue,
                  ),
                  SizedBox(height: 16),
                  _buildSensorGraph(
                    'Rain Graph',
                    sensorData.rainReadings,
                    Colors.green,
                  ),
                ],
              ),
            ),
            // Bottom navigation bar with styled icons
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.home, false, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SensorDashboard(
                            userName: ''), // Pass the username if required
                      ),
                    );
                  }),
                  _buildBottomNavItem(Icons.cloud, true, () {
                    // Currently on WeatherSensors page, so no action needed
                  }),
                  _buildBottomNavItem(Icons.warning_amber_outlined, false, () {
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
    );
  }

  //here we add is responsible of max , min and average of readings and we put unit of each sensorreadin
  // like celsius for temperature , then set up the dashboards for the readings
  Widget _buildSensorDashboard(
      String title, List<int> readings, String imagePath) {
    double average = readings.isNotEmpty
        ? readings.reduce((a, b) => a + b) / readings.length
        : 0.0;
    int max =
        readings.isNotEmpty ? readings.reduce((a, b) => a > b ? a : b) : 0;
    int min =
        readings.isNotEmpty ? readings.reduce((a, b) => a < b ? a : b) : 0;

    String unit;
    if (title == 'Temperature') {
      unit = '°C';
    } else if (title == 'Humidity') {
      unit = '%';
    } else if (title == 'Rain') {
      unit = 'mm';
    } else {
      unit = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF515175),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(imagePath, height: 40, color: Color(0xFFBBAAB8)),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFFBBAAB8),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Current Reading: ${readings.isNotEmpty ? readings.last.toString() + unit : 'N/A'}',
              style: TextStyle(color: Color(0xFFBBAAB8), fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Average: ${average.toStringAsFixed(2)}$unit',
              style: TextStyle(color: Color(0xFFBBAAB8), fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Max: $max$unit',
              style: TextStyle(color: Color(0xFFBBAAB8), fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Min: $min$unit',
              style: TextStyle(color: Color(0xFFBBAAB8), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  //and here set up the dashboards for graphs for check the size of it and size of font and the color of dashboard
  Widget _buildSensorGraph(String title, List<int> readings, Color lineColor) {
    List<FlSpot> spots = [];
    for (int i = 0; i < readings.length; i++) {
      spots.add(FlSpot(i.toDouble(), readings[i].toDouble()));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF515175),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xFFBBAAB8),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Color(0xFFBBAAB8),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: lineColor,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minX: 0,
                  maxX: (readings.length - 1).toDouble(),
                  minY: readings.isNotEmpty
                      ? readings.reduce((a, b) => a < b ? a : b).toDouble()
                      : 0,
                  maxY: readings.isNotEmpty
                      ? readings.reduce((a, b) => a > b ? a : b).toDouble()
                      : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //here if i am in Weather sensor the icon of the cloud will be orange (selected) and other icons will be white (not selected)
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
