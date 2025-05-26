import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanlydoisong/controllers/dreams_controller.dart';
import 'package:quanlydoisong/view/dreamPage/add_dream_page.dart';
import 'package:quanlydoisong/view/dreamPage/dream_detail_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DreamsPage extends StatelessWidget {
  final DreamsController controller = Get.find();

  DreamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Màu nền sáng hơn
      appBar: AppBar(
        title: const Text(
          "Ước mơ & Dự định 💫",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Get.to(() => AddDreamPage(), transition: Transition.downToUp);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // Lọc danh sách bên ngoài Obx để tránh lỗi setState trong build
          final filteredDreams = controller.dreams
              .where((dream) =>
                  dream.title.isNotEmpty || dream.description.isNotEmpty)
              .toList();

          if (filteredDreams.isEmpty) {
            return const Center(
              child: Text(
                "Hãy bắt đầu bằng cách thêm một ước mơ mới! 🚀",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Hiển thị 2 cột
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: filteredDreams.length,
            itemBuilder: (context, index) {
              final dream = filteredDreams[index];
              return GestureDetector(
                onTap: () => Get.to(() => DreamDetailPage(index: index)),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: "dream_${dream.title}",
                          child: Icon(Icons.star_rounded,
                              size: 40, color: Colors.orangeAccent),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          dream.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        CircularPercentIndicator(
                          radius: 30,
                          lineWidth: 5,
                          percent: dream.progress,
                          center: Text(
                            "${(dream.progress * 100).toInt()}%",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          progressColor: Colors.blueAccent,
                          backgroundColor: Colors.grey[300]!,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
