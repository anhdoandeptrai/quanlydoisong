import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherDetailPage extends StatefulWidget {
  const WeatherDetailPage({super.key});

  @override
  _WeatherDetailPageState createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  final String apiKey = "dcc2de573368d26d6ca37e9446e564ef";
  String temperature = "Đang tải...";
  String description = "Vui lòng chờ...";
  String cityName = "Đang xác định...";
  String iconCode = "01d";
  String humidity = "Đang tải...";
  String windSpeed = "Đang tải...";
  List<Map<String, String>> hourlyForecast = [];
  List<Map<String, String>> dailyForecast = [];

  @override
  void initState() {
    super.initState();
    fetchWeather();
    fetchForecast();
  }

  Future<void> fetchWeather() async {
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/weather?q=Ho%20Chi%20Minh&appid=$apiKey&units=metric&lang=vi";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = "${data['main']['temp'].toStringAsFixed(1)}°C";
          description = data['weather'][0]['description'];
          cityName = data['name'];
          iconCode = data['weather'][0]['icon'];
          humidity = "${data['main']['humidity']}%";
          windSpeed = "${data['wind']['speed']} km/h";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "Không thể tải dữ liệu";
      });
    }
  }

  Future<void> fetchForecast() async {
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/forecast?q=Ho%20Chi%20Minh&appid=$apiKey&units=metric&lang=vi";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          hourlyForecast = List.generate(6, (index) {
            final forecast = data['list'][index];
            return {
              'time': forecast['dt_txt'].substring(11, 16),
              'temp': "${forecast['main']['temp'].toStringAsFixed(1)}°C",
              'icon': forecast['weather'][0]['icon']
            };
          });
          dailyForecast = List.generate(5, (index) {
            final forecast = data['list'][index * 8];
            return {
              'date': forecast['dt_txt'].substring(5, 10),
              'temp': "${forecast['main']['temp'].toStringAsFixed(1)}°C",
              'icon': forecast['weather'][0]['icon']
            };
          });
        });
      }
    } catch (e) {}
  }

  Widget buildGlassContainer(Widget child, {double opacity = 0.4}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 100, 222, 216).withOpacity(opacity),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dự Báo Thời Tiết",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(0, 223, 97, 19),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF60A5FA), Color(0xFF93C5FD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF60A5FA), Color(0xFF93C5FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildGlassContainer(
                Column(
                  children: [
                    Text(cityName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Image.network(
                        "http://openweathermap.org/img/wn/$iconCode@2x.png",
                        width: 80),
                    Text(temperature,
                        style: const TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold)),
                    Text(description, style: const TextStyle(fontSize: 18)),
                    Text("Độ ẩm: $humidity | Gió: $windSpeed",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Dự báo theo giờ",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: hourlyForecast
                      .map((item) => buildGlassContainer(
                            Column(
                              children: [
                                Text(item['time']!,
                                    style: const TextStyle(fontSize: 16)),
                                Image.network(
                                    "http://openweathermap.org/img/wn/${item['icon']}@2x.png",
                                    width: 50),
                                Text(item['temp']!,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Dự báo các ngày tới",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              Column(
                children: dailyForecast
                    .map((item) => buildGlassContainer(
                          ListTile(
                            leading: Image.network(
                                "http://openweathermap.org/img/wn/${item['icon']}@2x.png",
                                width: 50),
                            title: Text(item['date']!,
                                style: const TextStyle(fontSize: 16)),
                            trailing: Text(item['temp']!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
