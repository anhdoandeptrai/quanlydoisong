import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getRecords(String filter) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    final now = DateTime.now();
    DateTime startDate;
    DateTime? endDate;

    switch (filter) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 'week':
        startDate = now.subtract(
            Duration(days: now.weekday - 1)); // Start of the week (Monday)
        endDate =
            startDate.add(const Duration(days: 7)); // End of the week (Sunday)
        break;
      case 'month':
      default:
        startDate = DateTime(now.year, now.month, 1); // Start of the month
        endDate = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(days: 1)); // End of the month
        break;
    }

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('attendanceRecords')
        .where('timestamp', isGreaterThanOrEqualTo: startDate);

    query = query.where('timestamp', isLessThan: endDate);

    return query.orderBy('timestamp', descending: true).snapshots();
  }

  Widget _buildWeekList(QuerySnapshot snapshot) {
    Map<int, List<QueryDocumentSnapshot>> groupedWeeks = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final weekNumber =
          ((timestamp.day - 1) ~/ 7) + 1; // Calculate week number

      groupedWeeks.putIfAbsent(weekNumber, () => []).add(doc);
    }

    return ListView.builder(
      itemCount: groupedWeeks.keys.length,
      itemBuilder: (context, index) {
        final weekNumber = groupedWeeks.keys.elementAt(index);
        final records = groupedWeeks[weekNumber]!;

        return ExpansionTile(
          title: Text('Tuần $weekNumber'),
          children: records.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = data['date'] ?? 'Không xác định';
            final hoursWorked = (data['hoursWorked'] ?? 0.0).toStringAsFixed(2);
            final totalEarnings =
                (data['totalEarnings'] ?? 0.0).toStringAsFixed(2);

            return ListTile(
              title: Text('Ngày: $date'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Số giờ làm: $hoursWorked giờ'),
                  Text('Tổng tiền: $totalEarnings VND'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteRecord(doc.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMonthList(QuerySnapshot snapshot) {
    Map<int, List<QueryDocumentSnapshot>> groupedMonths = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final monthNumber = timestamp.month; // Group by month

      groupedMonths.putIfAbsent(monthNumber, () => []).add(doc);
    }

    return ListView.builder(
      itemCount: groupedMonths.keys.length,
      itemBuilder: (context, index) {
        final monthNumber = groupedMonths.keys.elementAt(index);
        final records = groupedMonths[monthNumber]!;

        return ExpansionTile(
          title: Text('Tháng $monthNumber'),
          children: records.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = data['date'] ?? 'Không xác định';
            final hoursWorked = (data['hoursWorked'] ?? 0.0).toStringAsFixed(2);
            final totalEarnings =
                (data['totalEarnings'] ?? 0.0).toStringAsFixed(2);

            return ListTile(
              title: Text('Ngày: $date'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Số giờ làm: $hoursWorked giờ'),
                  Text('Tổng tiền: $totalEarnings VND'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteRecord(doc.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _deleteRecord(String recordId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bản ghi này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('attendanceRecords')
          .doc(recordId)
          .delete();
    }
  }

  Widget _buildRecordList(String filter) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getRecords(filter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Không có lịch sử.'));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = data['date'] ?? 'Không xác định';
            final hoursWorked = (data['hoursWorked'] ?? 0.0).toStringAsFixed(2);
            final totalEarnings =
                (data['totalEarnings'] ?? 0.0).toStringAsFixed(2);

            return ListTile(
              title: Text('Ngày: $date'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Số giờ làm: $hoursWorked giờ'),
                  Text('Tổng tiền: $totalEarnings VND'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteRecord(doc.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Làm Việc'),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ngày'),
            Tab(text: 'Tuần'),
            Tab(text: 'Tháng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordList('day'),
          StreamBuilder<QuerySnapshot>(
            stream: _getRecords('week'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Không có lịch sử.'));
              }
              return _buildWeekList(snapshot.data!);
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _getRecords('month'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Không có lịch sử.'));
              }
              return _buildMonthList(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}
