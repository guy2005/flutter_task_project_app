import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';

class FocusTimerScreen extends StatefulWidget {
  final Task task;
  const FocusTimerScreen({super.key, required this.task});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const int focusMinutes = 25; 
  int _secondsRemaining = focusMinutes * 60;
  Timer? _timer;
  bool _isRunning = false;

 void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          
          // --- บันทึกทุก 10 วินาที ---
          // เช็กว่าวินาทีที่เหลือ หารด้วย 10 ลงตัวหรือไม่ (และไม่ใช่ค่าเริ่มต้น)
          if (_secondsRemaining > 0 && _secondsRemaining % 10 == 0) {
            // สั่งบวกเวลาเข้า Database ทันที 10 วินาที
            taskController.addTimeSpent(widget.task.id, 10);
          }
        });
      } else {
        _stopTimer(completed: true);
      }
    });
  }

  void _stopTimer({bool completed = false}) {
    _timer?.cancel();
    setState(() => _isRunning = false);
    
    if (completed) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 เยี่ยมมาก!'),
        content: const Text('คุณตั้งใจทำงานครบ 25 นาทีแล้ว พักผ่อนสักครู่นะ'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ตกลง'))],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    if (hours > 0) return '${hours}ชม. ${minutes}นาที';
    return '${minutes}นาที ${seconds}วินาที';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1 - (_secondsRemaining / (focusMinutes * 60));

    return Scaffold(
      appBar: AppBar(title: Text('Focus: ${widget.task.title}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('กำลังโฟกัสกับวิชา ${widget.task.subject}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 250, height: 250, child: CircularProgressIndicator(value: progress, strokeWidth: 15, color: Colors.deepPurple, backgroundColor: Colors.grey.shade200)),
                Text('${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(onPressed: _isRunning ? null : _startTimer, icon: const Icon(Icons.play_arrow), label: const Text('เริ่มโฟกัส'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white)),
                const SizedBox(width: 20),
                OutlinedButton.icon(onPressed: _isRunning ? () => _stopTimer() : null, icon: const Icon(Icons.stop), label: const Text('หยุดก่อน')),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20), width: double.infinity, color: Colors.deepPurple.withAlpha(20),
              child: Column(
                children: [
                  const Text('⏱️ เวลาที่สะสมในงานนี้ทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: taskController,
                    builder: (context, _) {
                      final currentTask = taskController.tasks.firstWhere((t) => t.id == widget.task.id, orElse: () => widget.task);
                      return Text(_formatTime(currentTask.totalSeconds), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple));
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}