import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class EventProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Event> _events = [];
  String _selectedCategory = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Event> get events => _events;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter events by completion status
  List<Event> get completedEvents => _events.where((event) => event.isCompleted).toList();
  List<Event> get pendingEvents => _events.where((event) => !event.isCompleted).toList();

  // Constructor - Load events when provider is initialized
  EventProvider() {
    refreshEvents();
  }

  // Load all events from database
  Future<void> refreshEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedCategory.isEmpty) {
        _events = await _databaseService.getEvents();
      } else {
        _events = await _databaseService.getEventsByCategory(_selectedCategory);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load events: ${e.toString()}';
      notifyListeners();
    }
  }

  // Filter events by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    refreshEvents();
  }

  // Reset category filter
  void resetCategoryFilter() {
    _selectedCategory = '';
    refreshEvents();
  }

  // Add a new event
  Future<bool> addEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Insert event into database
      final id = await _databaseService.insertEvent(event);
      
      // Create a new event with the generated ID
      final newEvent = event.copyWith(id: id);
      
      // Schedule notification for the event
      await _notificationService.scheduleEventNotification(newEvent);
      
      // Reload events to reflect changes
      await refreshEvents();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add event: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update an existing event
  Future<bool> updateEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update event in database
      await _databaseService.updateEvent(event);
      
      // Cancel previous notification and schedule new one
      if (event.id != null) {
        await _notificationService.cancelNotification(event.id!);
      }
      await _notificationService.scheduleEventNotification(event);
      
      // Reload events to reflect changes
      await refreshEvents();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update event: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Delete an event
  Future<bool> deleteEvent(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delete event from database
      await _databaseService.deleteEvent(id);
      
      // Cancel notification for the event
      await _notificationService.cancelNotification(id);
      
      // Reload events to reflect changes
      await refreshEvents();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete event: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Toggle event completion status
  Future<bool> toggleEventCompletion(int id, bool isCompleted) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update completion status in database
      await _databaseService.toggleEventCompletion(id, isCompleted);
      
      // If marked as completed, cancel notification
      if (isCompleted) {
        await _notificationService.cancelNotification(id);
      } else {
        // If marked as pending, reschedule notification
        final event = await _databaseService.getEvent(id);
        await _notificationService.scheduleEventNotification(event);
      }
      
      // Reload events to reflect changes
      await refreshEvents();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update event status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get a single event by ID
  Future<Event?> getEventById(int id) async {
    try {
      return await _databaseService.getEvent(id);
    } catch (e) {
      _error = 'Failed to get event: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
