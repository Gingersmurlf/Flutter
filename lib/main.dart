import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importerer internet-værktøjet
import 'dart:convert'; // Gør det muligt at læse JSON-data fra API'et

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Weather Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WeatherDashboard(),
    );
  }
}

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  String byNavn = "København";
  String temperatur = "--";
  String vejrBeskrivelse = "Henter live data...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    hentRigtigVejrData(); // Kalder det ægte API med det samme
  }

  // DET NYE API-KALD
  Future<void> hentRigtigVejrData() async {
    // URL til Open-Meteo API med koordinaterne på København
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=55.6759&longitude=12.5655&current=temperature_2m,weather_code',
    );

    try {
      // 1. Send anmodning til internettet og vent på svar
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 2. Hvis alt er OK (status 200), så oversæt teksten til noget Dart forstår (JSON)
        final data = jsonDecode(response.body);

        // 3. Hent den specifikke temperatur ud af JSON-filen
        // 3. Hent den specifikke temperatur ud af JSON-filen
        final nuvaerendeTemperatur = data['current']['temperature_2m'];
        final weatherCode = data['current']['weather_code'];

        // 4. Opdater skærmen med de rigtige tal
        setState(() {
          temperatur = "$nuvaerendeTemperatur°C";
          vejrBeskrivelse = tolkeVejrKode(
            weatherCode,
          ); // Oversætter koder (f.eks. 0 = Solskin)
          isLoading = false;
        });
      } else {
        // Hvis API'et svarer med en fejl
        setState(() {
          vejrBeskrivelse =
              "Kunne ikke hente data (Fejl ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      // Hvis der slet ikke er internetforbindelse
      setState(() {
        vejrBeskrivelse = "Ingen internetforbindelse";
        isLoading = false;
      });
    }
  }

  // En lille hjælpe-funktion der oversætter API'ets tal-koder til dansk tekst
  String tolkeVejrKode(int kode) {
    if (kode == 0) return "Skyfrit og solskin ☀️";
    if (kode >= 1 && kode <= 3) return "Lidt skyet 🌤️";
    if (kode >= 45 && kode <= 48) return "Tåget 🌫️";
    if (kode >= 51 && kode <= 65) return "Regnvejr 🌧️";
    if (kode >= 71 && kode <= 77) return "Snevejr ❄️";
    return "Skiftende vejrskifte";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Live Weather Dashboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_sync, // Nyt ikon der passer til live data
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    byNavn,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    temperatur,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: Colors.blue[900],
                    ),
                  ),
                  Text(
                    vejrBeskrivelse,
                    style: const TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      hentRigtigVejrData();
                    },
                    child: const Text('Hent Friske Data'),
                  ),
                ],
              ),
      ),
    );
  }
}
