import 'package:flutter/material.dart';
import 'package:metsnagna/models/popular_entity.dart';
import 'package:metsnagna/utils/text_preview.dart';
import 'package:metsnagna/utils/time_duration.dart';

class ProfileChallenge extends StatelessWidget {
  final VentEntity entity;
  final VoidCallback onDelete; // Callback for delete
  final Function onEdit; // Callback for edit/navigation

  const ProfileChallenge({
    Key? key,
    required this.entity,
    required this.onDelete,
    required this.onEdit, // Add this line
  }) : super(key: key);

  // Method to show a confirmation dialog when delete icon is pressed
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you really want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Call the onDelete callback
                onDelete();
                Navigator.of(context)
                    .pop(); // Close the dialog after the action
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.blue, // Border color
          width: 1, // Border width
        ),
      ),
      elevation: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 180,
          color: Colors.white, // Inside background color
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                textPreview(
                    entity.content, 30), // Display content from the entity
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              SizedBox(height: 10),
              Text(
                " ${timeAgo(entity.createdAt)}",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Spacer(),
              Row(
                children: [
                  IconButton(
                      onPressed: () => onEdit(), // Call the onEdit callback
                      icon: Icon(
                        Icons.edit,
                        color: Colors.grey[600],
                      )),
                  Spacer(),
                  IconButton(
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
