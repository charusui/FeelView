import 'package:flutter/material.dart';

/// Scaffold for Poster/Admin mode.
/// Caller manages [currentIndex] and [onTap]; body is supplied as [child].
class PosterShell extends StatelessWidget {
  const PosterShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FeelView',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'DEV MODE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Family'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded), label: 'New Post'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'My Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }
}
