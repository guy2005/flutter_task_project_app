import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color _getDifficultyColor(String difficulty) {
    if (difficulty == 'Hard') return Colors.red;
    if (difficulty == 'Normal') return Colors.orange;
    return Colors.green; // Easy
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📅 ปฏิทินงาน')),
      body: AnimatedBuilder(
        animation: taskController,
        builder: (context, _) {
          final tasks = taskController.tasks;

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                },
                eventLoader: (day) => tasks.where((t) => t.dueDate != null && isSameDay(t.dueDate, day)).toList(),
                
                // ระบบเปลี่ยนสีจุดใต้วันที่ตามความยาก
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox();
                    
                    bool hasHard = events.any((e) => (e as Task).difficulty == 'Hard' && !e.isDone);
                    bool hasNormal = events.any((e) => (e as Task).difficulty == 'Normal' && !e.isDone);
                    bool hasEasy = events.any((e) => (e as Task).difficulty == 'Easy' && !e.isDone);
                    
                    if (!hasHard && !hasNormal && !hasEasy) return const SizedBox(); 

                    Color markerColor = Colors.green;
                    if (hasHard) markerColor = Colors.red;
                    else if (hasNormal) markerColor = Colors.orange;

                    return Positioned(
                      bottom: 1,
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: markerColor),
                        width: 8.0, height: 8.0,
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Expanded(child: _buildSelectedDayTasks(tasks)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayTasks(List<Task> tasks) {
    final dayTasks = tasks.where((t) => _selectedDay != null && isSameDay(t.dueDate, _selectedDay)).toList();
    if (dayTasks.isEmpty) return const Center(child: Text('ไม่มีงานที่ต้องส่งในวันนี้'));

    return ListView.builder(
      itemCount: dayTasks.length,
      itemBuilder: (context, i) {
        final task = dayTasks[i];
        final days = task.daysLeft;

        return Card(
          // เปลี่ยนสีแบคกราวด์การ์ดตามความยาก
          color: task.isDone ? Colors.white : _getDifficultyColor(task.difficulty).withAlpha(30),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(task.isDone ? 'เสร็จแล้ว 🎉' : 'เหลืออีก $days วัน'),
          ),
        );
      },
    );
  }
}