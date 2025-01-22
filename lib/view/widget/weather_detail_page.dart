import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherDetailPage extends StatefulWidget {
  @override
  _WeatherDetailPageState createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  String apiKey = "dcc2de573368d26d6ca37e9446e564ef";
  String temperature = "Đang tải...";
  String description = "Vui lòng chờ...";
  String cityName = "Đang xác định...";
  String iconCode = "01d"; // Mã biểu tượng thời tiết mặc định
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
      double lat = 10.7769;
      double lon = 106.7009;

      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi";
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
      } else {
        setState(() {
          temperature = "Không tải được";
          description = "Vui lòng kiểm tra API";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "Lỗi";
        description = "Không kết nối được";
      });
    }
  }

  Future<void> fetchForecast() async {
    try {
      double lat = 10.7769;
      double lon = 106.7009;

      final url =
          "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi";
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
    } catch (e) {
      print("Lỗi tải dữ liệu dự báo");
    }
  }

  Widget buildWeatherInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          cityName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          temperature,
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Độ ẩm: $humidity, Gió: $windSpeed",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget buildHourlyForecast() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: hourlyForecast
            .map((item) => Container(
                  width: 90, // Đặt chiều rộng để đồng đều
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(item['time']!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis)),
                      SizedBox(height: 5),
                      Image.network(
                        "http://openweathermap.org/img/wn/${item['icon']}@2x.png",
                        width: 50,
                        height: 50,
                      ),
                      Text(item['temp']!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildDailyForecast() {
    return Container(
      constraints: BoxConstraints(maxHeight: 250), // Hạn chế chiều cao
      child: ListView(
        shrinkWrap: true,
        children: dailyForecast
            .map((item) => Card(
                  color: Colors.white12,
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      "http://openweathermap.org/img/wn/${item['icon']}@2x.png",
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      item['date']!,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    trailing: Text(
                      item['temp']!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dự Báo Thời Tiết", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildWeatherInfo(),
              SizedBox(height: 20),
              Text(
                "Dự báo theo giờ",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 10),
              buildHourlyForecast(),
              SizedBox(height: 20),
              Text(
                "Dự báo các ngày tiếp theo",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 10),
              buildDailyForecast(),
            ],
          ),
        ),
      ),
    );
  }
}
