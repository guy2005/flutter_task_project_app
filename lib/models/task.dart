class Task {
  String id;
  String title;
  String subject;
  String difficulty;
  bool isDone;
  int totalSeconds;
  DateTime? dueDate;

  Task({
    required this.id, 
    required this.title, 
    required this.subject, 
    required this.difficulty, 
    this.isDone = false,
    this.totalSeconds = 0,
    this.dueDate,
  });

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'], 
    title: map['title'], 
    subject: map['subject'], 
    difficulty: map['difficulty'],
    isDone: map['is_done'] ?? false,
    totalSeconds: map['total_seconds'] ?? 0,
    dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
  );

  Map<String, dynamic> toMap() => {
    'title': title, 
    'subject': subject, 
    'difficulty': difficulty, 
    'is_done': isDone, 
    'total_seconds': totalSeconds,
    'due_date': dueDate?.toIso8601String(),
  };
  
  int get daysLeft {
    if (dueDate == null) return 999;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(today).inDays;
  }
}