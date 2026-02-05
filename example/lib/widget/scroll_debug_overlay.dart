import 'package:flutter/material.dart';

class ScrollDebugOverlay extends StatefulWidget {
  const ScrollDebugOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;
  final bool isLoading;

  @override
  State<ScrollDebugOverlay> createState() => _ScrollDebugOverlayState();
}

class _ScrollDebugOverlayState extends State<ScrollDebugOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 16,
          top: 16,
          child: Card(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Loading Status: ',
                      style: TextStyle(color: Colors.white)),
                  Icon(
                    widget.isLoading ? Icons.circle : Icons.circle_outlined,
                    color: widget.isLoading ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isLoading ? 'Loading...' : 'Idle',
                    style: TextStyle(
                      color: widget.isLoading ? Colors.green : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
