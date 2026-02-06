import 'package:flutter/material.dart';

/// A debug overlay that displays loading states for multiple sections.
class ScrollDebugOverlay extends StatelessWidget {
  const ScrollDebugOverlay({
    super.key,
    required this.child,
    this.loadingStates = const {},
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// A map of section names to their loading states.
  final Map<String, bool> loadingStates;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 16,
          top: 16,
          child: Card(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Loading Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...loadingStates.entries.map((entry) => _buildStatusRow(
                        entry.key,
                        entry.value,
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String name, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$name: ',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Icon(
            isLoading ? Icons.circle : Icons.circle_outlined,
            color: isLoading ? Colors.green : Colors.grey,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isLoading ? 'Loading...' : 'Idle',
            style: TextStyle(
              color: isLoading ? Colors.green : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
