import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanlydoisong/controllers/dreams_controller.dart';
import 'package:quanlydoisong/view/dreamPage/add_dream_page.dart';

import 'dream_detail_page.dart';

class DreamsPage extends StatelessWidget {
  final DreamsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ước mơ & Dự định",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Điều hướng đến trang thêm ước mơ
              Get.to(() => AddDreamPage());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Hãy theo đuổi ước mơ của bạn! ✨",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                final filteredDreams = controller.filteredDreams;
                if (filteredDreams.isEmpty) {
                  return const Center(
                    child: Text(
                      "Không có ước mơ nào.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredDreams.length,
                  itemBuilder: (context, index) {
                    final dream = filteredDreams[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      color: Colors.white,
                      child: ListTile(
                        onTap: () =>
                            Get.to(() => DreamDetailPage(index: index)),
                        leading: const Icon(
                          Icons.star,
                          color: Colors.orangeAccent,
                        ),
                        title: Text(
                          dream.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dream.description,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: dream.progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${(dream.progress * 100).toInt()}% hoàn thành",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
