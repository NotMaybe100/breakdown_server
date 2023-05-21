import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io/socket_io.dart';

void main() {
  runApp(const ServerApp());
}

class ServerApp extends StatelessWidget {
  const ServerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus 1',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
      ),
      home: const ServerPage(),
    );
  }
}

class ServerPage extends StatefulWidget {
  const ServerPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  List<Map<String, dynamic>> receivedValues = [];

  @override
  void initState() {
    super.initState();
    startServer();
  }

  void startServer() {
    final server = Server();

    server.on('connection', (socket) {
      if (kDebugMode) {
        print('Client connected');
      }

      socket.on('values', (data) {
        if (kDebugMode) {
          print('Received values from client:');
          print(data);
        }

        final engineTemperature = data['engineTemperature'];
        final tirePressure = data['tirePressure'];
        final smokeDetector = data['smokeDetector'];
        final latitude = data['latitude'];
        final longitude = data['longitude'];
        final passengers = data['passengers'];

        final breakdownProbability = calculateBreakdownProbability(
          engineTemperature,
          tirePressure,
          smokeDetector,
        );

        final Map<String, dynamic> result = {
          'engineTemperature': engineTemperature,
          'tirePressure': tirePressure,
          'smokeDetector': smokeDetector,
          'latitude': latitude,
          'longitude': longitude,
          'passengers': passengers,
          'breakdownProbability': breakdownProbability,
        };

        setState(() {
          receivedValues = [result];
        });
      });
    });

    server.listen(3000);
    if (kDebugMode) {
      print('Server listening on port 3000');
    }
  }

  double calculateBreakdownProbability(
    double engineTemperature,
    double tirePressure,
    bool smokeDetector,
  ) {
    double breakdownProbability = 0.0;

    if (tirePressure < 50) {
      breakdownProbability += 2 * ((50 - tirePressure) / 100);
    } else if (tirePressure > 60) {
      breakdownProbability += 2 * ((tirePressure - 60) / 100);
    }

    if (engineTemperature > 90) {
      breakdownProbability += (engineTemperature - 90) / 100;
    }

    if (smokeDetector) {
      breakdownProbability += 0.5;
    }

    return breakdownProbability;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus 1')),
      body: ListView.builder(
        itemCount: receivedValues.length,
        itemBuilder: (context, index) {
          final value = receivedValues[index];
          final engineTemperature = value['engineTemperature'];
          final tirePressure = value['tirePressure'];
          final smokeDetector = value['smokeDetector'];
          final latitude = value['latitude'];
          final longitude = value['longitude'];
          final passengers = value['passengers'];
          final breakdownProbability = value['breakdownProbability'];

          final breakdownAlert =
              breakdownProbability >= 0.5 ? 'Breakdown Alert!' : '';

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Engine Temperature: $engineTemperature°C',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Tire Pressure: $tirePressure psi',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Smoke Detector: ${smokeDetector ? 'Yes' : 'No'}',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'GPS Coordinates: $latitude, $longitude',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Number of Passengers: $passengers',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Breakdown Probability: $breakdownProbability',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    breakdownAlert,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
