import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Tính năng báo cáo đang được phát triển!',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Icon(Icons.bar_chart, size: 80, color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}
