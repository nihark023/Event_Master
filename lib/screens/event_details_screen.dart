import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../providers/event_provider.dart';
import 'add_edit_event_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditEventScreen(event: event),
                ),
              ).then((_) {
                // Refresh the event details when returning from edit screen
                Provider.of<EventProvider>(context, listen: false).refreshEvents();
                Navigator.pop(context); // Go back to previous screen
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Event category
            Row(
              children: [
                Chip(
                  label: Text(event.category),
                  backgroundColor: _getCategoryColor(event.category),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                event.isCompleted
                    ? const Chip(
                        label: Text('Completed'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : const Chip(
                        label: Text('Pending'),
                        backgroundColor: Colors.orange,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
              ],
            ),
            const SizedBox(height: 16),

            // Due date
            _buildInfoRow(
              Icons.event,
              'Due Date',
              DateFormat('EEEE, MMMM d, yyyy').format(event.dueDate),
            ),
            const SizedBox(height: 8),

            // Due time
            _buildInfoRow(
              Icons.access_time,
              'Due Time',
              DateFormat('h:mm a').format(event.dueDate),
            ),
            const SizedBox(height: 24),

            // Description header
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Description content
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                event.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),

            // Toggle completion button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  event.isCompleted ? Icons.refresh : Icons.check_circle,
                ),
                label: Text(
                  event.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor:
                      event.isCompleted ? Colors.orange : Colors.green,
                ),
                onPressed: () => _toggleEventCompletion(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Future<void> _toggleEventCompletion(BuildContext context) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final success = await eventProvider.toggleEventCompletion(
      event.id!,
      !event.isCompleted,
    );

    if (success) {
      // If successful, go back to previous screen
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      // Show error if failed
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventProvider.error ?? 'Failed to update event status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              final eventProvider =
                  Provider.of<EventProvider>(context, listen: false);
              final success = await eventProvider.deleteEvent(event.id!);

              if (success && context.mounted) {
                Navigator.pop(context); // Go back to previous screen
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      eventProvider.error ?? 'Failed to delete event',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
