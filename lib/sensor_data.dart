class SensorData {
  // Singleton pattern to ensure only one if instance of SensorData exists
  static final SensorData _instance = SensorData._internal();
  // constructor to return the single instance of SensorData
  factory SensorData() {
    return _instance;
  }

  //constructor for internal use
  SensorData._internal();

  // Lists to store sensor readings
  List<int> temperatureReadings = []; //stores temperature readings
  List<int> humidityReadings = []; //stores humidity readings
  List<int> rainReadings = []; //stores rain readings
  List<int> uvReadings = []; //stores uv readings
  List<int> gasDetectionReadings = []; // Added for gas detection
  List<int> flameDetectionReadings = []; // Added for flame detection
  bool isGasDetected = false; //if gas detected
  bool isFlameDetected = false; //if flame detected

  // Method to clear readings
  void clearReadings() {
    temperatureReadings.clear();
    humidityReadings.clear();
    rainReadings.clear();
    uvReadings.clear();
    gasDetectionReadings.clear();
    flameDetectionReadings.clear();
  }
}
