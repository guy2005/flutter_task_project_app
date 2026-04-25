import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('📊 ภาพรวมงาน', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent),
      body: AnimatedBuilder(
        animation: taskController,
        builder: (context, child) {
          final tasks = taskController.tasks;
          final total = tasks.length;
          final done = tasks.where((t) => t.isDone).length;
          final percent = total == 0 ? 0.0 : done / total;

          String statusText = 'สู้ๆ ใกล้เสร็จแล้ว!';
          if (total == 0) statusText = 'ยังไม่มีงาน เริ่มเลย!';
          else if (done == total) statusText = 'เสร็จทั้งหมดแล้ว! 🏆';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade800]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.deepPurple.withAlpha(80), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80, height: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(value: percent, strokeWidth: 8, backgroundColor: Colors.white.withAlpha(50), color: Colors.white),
                            Center(child: Text('${(percent * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ความคืบหน้า', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildStatCard('ทั้งหมด', total.toString(), Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatCard('เสร็จแล้ว', done.toString(), Colors.green),
                    const SizedBox(width: 16),
                    _buildStatCard('ค้างส่ง', (total - done).toString(), Colors.orange),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.shade200), boxShadow: [BoxShadow(color: color.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(children: [Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color.shade700)), Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700]))]),
      ),
    );
  }
}