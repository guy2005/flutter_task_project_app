import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // อย่าลืม import ตัวนี้เพื่อจัดรูปแบบวันที่
import '../models/task.dart';
import '../controllers/task_controller.dart';
import 'add_task.dart';
import 'focus_timer.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  Color _getDifficultyColor(String difficulty) {
    if (difficulty == 'Hard') return Colors.red.shade50;
    if (difficulty == 'Normal') return Colors.orange.shade50;
    return Colors.green.shade50; 
  }

  void _showEditSheet(BuildContext context, Task task) {
    final titleCtrl = TextEditingController(text: task.title);
    final subjectCtrl = TextEditingController(text: task.subject);
    String currentDifficulty = task.difficulty;
    DateTime? currentDueDate = task.dueDate; // เก็บค่าวันที่ปัจจุบันของงานนี้ไว้

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✏️ แก้ไขงาน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), 
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'ชื่องาน')), 
              const SizedBox(height: 16),
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'วิชา')), 
              const SizedBox(height: 16),
              
              // --- เพิ่มส่วนเลือกวันที่ในหน้าแก้ไข ---
              const Text('วันกำหนดส่ง:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(currentDueDate == null ? 'ยังไม่ได้ตั้งวันส่ง' : DateFormat('dd MMM yyyy').format(currentDueDate!)),
                leading: const Icon(Icons.calendar_month, color: Colors.deepPurple),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: currentDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setModalState(() => currentDueDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),

              const Text('ระดับความยาก:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Easy', label: Text('🌱 ง่าย')), 
                  ButtonSegment(value: 'Normal', label: Text('📝 ปานกลาง')), 
                  ButtonSegment(value: 'Hard', label: Text('🔥 ยาก'))
                ],
                selected: {currentDifficulty}, 
                onSelectionChanged: (val) => setModalState(() => currentDifficulty = val.first),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: () { 
                    // ส่งค่าวันที่ใหม่ (currentDueDate) ไปที่ controller
                    taskController.editTask(task.id, titleCtrl.text, subjectCtrl.text, currentDifficulty, currentDueDate); 
                    Navigator.pop(ctx); 
                  }, 
                  child: const Text('อัปเดตข้อมูลและปฏิทิน')
                )
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('📋 รายการงาน', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent),
      body: AnimatedBuilder(
        animation: taskController,
        builder: (context, child) {
          final tasks = taskController.tasks;
          if (tasks.isEmpty) return const Center(child: Text('ไม่มีงาน ว่างจัดเลยตอนนี้! 🎉', style: TextStyle(fontSize: 18, color: Colors.grey)));

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), elevation: 1, 
                color: task.isDone ? Colors.grey.shade200 : _getDifficultyColor(task.difficulty), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: Checkbox(value: task.isDone, onChanged: (_) => taskController.toggleDone(index), activeColor: Colors.green, shape: const CircleBorder()),
                  title: Text(task.title, style: TextStyle(decoration: task.isDone ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold, color: task.isDone ? Colors.grey : Colors.black87)),
                  subtitle: Text('${task.subject} • ${task.dueDate == null ? "ไม่มีเดดไลน์" : "ส่ง: " + DateFormat('dd MMM').format(task.dueDate!)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.timer_outlined, color: Colors.orange), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FocusTimerScreen(task: task)))),
                      IconButton(icon: const Icon(Icons.edit_note, color: Colors.blueAccent), onPressed: () => _showEditSheet(context, task)),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => taskController.deleteTask(index)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())), label: const Text('เพิ่มงาน'), icon: const Icon(Icons.add), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
    );
  }
}