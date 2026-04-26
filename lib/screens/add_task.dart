import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  Set<String> _difficulty = {'Normal'}; 
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveNewTask() async {
    if (_titleController.text.isEmpty || _subjectController.text.isEmpty) return;
    await taskController.addTask(_titleController.text, _subjectController.text, _difficulty.first, _selectedDate);
    if (mounted) Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 เพิ่มงานใหม่')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'ชื่องาน', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 16),
            TextField(controller: _subjectController, decoration: InputDecoration(labelText: 'วิชา/หมวดหมู่', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 16),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(_selectedDate == null ? 'ตั้งวันส่งงาน (เดดไลน์)' : 'ส่งวันที่: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}'),
                leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                onTap: _pickDate,
                trailing: const Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: 24),

            const Text('ระดับความยากของงาน:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Easy', label: Text('🌱 ง่าย')), 
                ButtonSegment(value: 'Normal', label: Text('📝 ปานกลาง')), 
                ButtonSegment(value: 'Hard', label: Text('🔥 ยาก'))
              ],
              selected: _difficulty, onSelectionChanged: (newSelection) => setState(() => _difficulty = newSelection),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _saveNewTask,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('บันทึกงาน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}