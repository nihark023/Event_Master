import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../providers/event_provider.dart';
import '../screens/event_details_screen.dart';
import '../screens/add_edit_event_screen.dart';

class EventListItem extends StatelessWidget {
  final Event event;

  const EventListItem({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate if the event is overdue
    final isOverdue = !event.isCompleted && 
                       event.dueDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Slidable(
        // Slide actions
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            // Edit action
            SlidableAction(
              onPressed: (context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditEventScreen(event: event),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            // Delete action
            SlidableAction(
              onPressed: (context) => _deleteEvent(context),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        
        // Event card
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isOverdue
                ? const BorderSide(color: Colors.red, width: 1.5)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(event: event),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Checkbox for completion status
                  Checkbox(
                    value: event.isCompleted,
                    onChanged: (value) {
                      if (value != null) {
                        _toggleEventCompletion(context, value);
                      }
                    },
                    activeColor: _getCategoryColor(event.category),
                  ),
                  const SizedBox(width: 8),
                  
                  // Event details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event title
                        Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: event.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                            color: event.isCompleted 
                                ? Colors.grey 
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Event category and time
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(event.category),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                event.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: isOverdue ? Colors.red : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('h:mm a').format(event.dueDate),
                              style: TextStyle(
                                color: isOverdue ? Colors.red : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleEventCompletion(BuildContext context, bool isCompleted) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.toggleEventCompletion(event.id!, isCompleted);
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.deleteEvent(event.id!);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.green;
      case 'Health':
        return Colors.red;
      case 'Shopping':
        return Colors.purple;
      case 'Social':
        return Colors.orange;
      case 'Study':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
