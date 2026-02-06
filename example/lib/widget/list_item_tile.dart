import 'package:flutter/material.dart';

/// A list tile widget for vertical list items.
class ListItemTile extends StatelessWidget {
  const ListItemTile({
    super.key,
    required this.title,
    required this.index,
  });

  /// The title text to display.
  final String title;

  /// The index of the item.
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(title),
      subtitle: Text('Index $index'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
