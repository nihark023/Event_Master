class Event {
  final int? id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final bool isCompleted;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Create a copy of the event with potential changes
  Event copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert Event to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Create Event from a Map (from database)
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, category: $category, dueDate: $dueDate, isCompleted: $isCompleted)';
  }
}

// Predefined categories for events
class EventCategories {
  static const String work = 'Work';
  static const String personal = 'Personal';
  static const String health = 'Health';
  static const String shopping = 'Shopping';
  static const String social = 'Social';
  static const String study = 'Study';
  static const String other = 'Other';

  static List<String> getAll() {
    return [work, personal, health, shopping, social, study, other];
  }
}
