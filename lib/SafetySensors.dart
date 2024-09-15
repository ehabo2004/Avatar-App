import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package
import 'sensor_data.dart'; // Import the shared state
import 'mqtt.dart'; //import the mqtt client wrapper
import 'sensors_page.dart'; //import sensors_page
import 'settings.dart'; //import the settings page
import 'weathersensors.dart'; //import the Weather sensors page

class SafetySensors extends StatefulWidget {
  @override
  _SafetySensorsState createState() => _SafetySensorsState();
}

// create instance of MQTT client wrapper
class _SafetySensorsState extends State<SafetySensors> {
  late MQTTClientWrapper mqttClientWrapper;

//here we intialize the mqtt client wrapper and set the callback when message recieved
//prepare the mqtt for client and subscribe for topics
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

// callback function for handling received MQTT messages
  void _onMessageReceived(String topic, String message) {
    final sensorData = SensorData(); // Get the instance from sensor_data
    setState(() {
      //update the sensor data based on recieved topic
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

/*as same as the Weather sensor page , we make three dashboards for each sensor
UV,flame and gas, in uv dashboard prints current reading and min and max and average of readings
and in dashboards of flame and gas display if there is there detection of
flame or gas and turns the text to red color to warn user*/
  @override
  Widget build(BuildContext context) {
    final sensorData = SensorData(); // Get the singleton instance
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
                  'Safety Sensors',
                  style: TextStyle(
                    color: Color(0xFFE99E75),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            /*and here to display reading of UV and the detection of flame and gas, then there are
            graphs for each sensor in Safety Sensor , line chart show the continous data of UV
            and two bargraph for flame and gas , if there is detection , bar will rise to one,
            else if there wasn't any detection , bar returns to zero*/
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildSensorDashboard(
                    'UV',
                    sensorData.uvReadings,
                    'assets/uv.png',
                    showIndex: true,
                  ),
                  SizedBox(height: 8),
                  _buildSensorDashboard(
                    'Gas',
                    [], // No readings for Gas
                    'assets/gas.png',
                    showReading: false,
                    isDetected: sensorData.isGasDetected,
                  ),
                  SizedBox(height: 8),
                  _buildSensorDashboard(
                    'Flame',
                    [], // No readings for Flame
                    'assets/flame.png',
                    showReading: false,
                    isDetected: sensorData.isFlameDetected,
                  ),
                  SizedBox(height: 16),
                  _buildSensorGraph(
                    'UV Graph',
                    sensorData.uvReadings,
                    Colors.purple,
                    isBarChart: false,
                  ),
                  SizedBox(height: 16),
                  _buildSensorGraph(
                    'Gas Detection Graph',
                    sensorData.gasDetectionReadings,
                    Colors.red, // Color for Gas graph
                    isBarChart: true,
                  ),
                  SizedBox(height: 16),
                  _buildSensorGraph(
                    'Flame Detection Graph',
                    sensorData.flameDetectionReadings,
                    Colors.orange, // Color for Flame graph
                    isBarChart: true,
                  ),
                ],
              ),
            ),
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
                        builder: (context) => SensorDashboard(userName: ''),
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
                  _buildBottomNavItem(Icons.warning_amber_outlined, true, () {
                    // Handle navigation to warnings or stay on current page
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

  //the widget which is responsible of dashboards of display readings of uv and detection of gas or flame
  //and if there is detection , make text red
  Widget _buildSensorDashboard(
    String title,
    List<int> readings,
    String imagePath, {
    bool showReading = true,
    bool showIndex = false,
    bool isDetected = false,
  }) {
    final sensorData = SensorData(); // Get the singleton instance
    double average = readings.isNotEmpty
        ? readings.reduce((a, b) => a + b) / readings.length
        : 0.0;
    int max =
        readings.isNotEmpty ? readings.reduce((a, b) => a > b ? a : b) : 0;
    int min =
        readings.isNotEmpty ? readings.reduce((a, b) => a < b ? a : b) : 0;

    Color textColor = isDetected ? Colors.red : Color(0xFFBBAAB8);
    Color iconColor = isDetected ? Colors.red : Color(0xFFBBAAB8);

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
                Image.asset(imagePath, height: 40, color: iconColor),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (title == 'Gas' || title == 'Flame')
              Text(
                title == 'Gas'
                    ? (sensorData.isGasDetected ? 'Detected' : 'Not Detected')
                    : (sensorData.isFlameDetected
                        ? 'Detected'
                        : 'Not Detected'),
                style: TextStyle(color: textColor, fontSize: 16),
              )
            else if (showReading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Reading: ${readings.isNotEmpty ? readings.last.toString() + (title == 'UV' && showIndex ? ' index' : '') : 'N/A'}',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Average: ${average.toStringAsFixed(2)}' +
                        (title == 'UV' && showIndex ? ' index' : ''),
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Max: $max' + (title == 'UV' && showIndex ? ' index' : ''),
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Min: $min' + (title == 'UV' && showIndex ? ' index' : ''),
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ],
              )
            else
              Text(
                'Not Detected',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

// widget responsible for graphs
Widget _buildSensorGraph(String title, List<int> readings, Color color,
    {bool isBarChart = false}) {
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
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),  // Display as integer
                          style: TextStyle(
                            color: Colors.black, // Set the color to black
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),  // Display as integer
                          style: TextStyle(
                            color: Colors.black, // Set the color to black
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Color(0xFFBBAAB8),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: readings.length.toDouble() - 1,
                minY: readings.isNotEmpty
                    ? readings.reduce((a, b) => a < b ? a : b).toDouble()
                    : 0.0,
                maxY: readings.isNotEmpty
                    ? readings.reduce((a, b) => a > b ? a : b).toDouble()
                    : 1.0,
                lineBarsData: [
                  LineChartBarData(
                    spots: readings.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}




  //like rest of pages , when user is in safety page the icon of wanring will be orang #E99E75 and rest of icons are white
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
