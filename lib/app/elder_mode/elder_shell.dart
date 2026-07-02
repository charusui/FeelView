import 'package:flutter/material.dart';

/// Scaffold wrapper for all Elder Mode screens.
/// Hosts a luxury warm emerald AppBar and a prominent 3-item bottom NavigationBar.
class ElderShell extends StatelessWidget {
  const ElderShell({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTap,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: automaticallyImplyLeading,
        title: title != null
            ? Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: Color(0xFF10B981), size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        actions: actions,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.colorScheme.primary.withOpacity(0.04),
            ],
          ),
        ),
        child: body,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 88,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 30),
              selectedIcon: Icon(Icons.home_rounded, size: 34, color: Color(0xFF0F5C43)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_a_photo_outlined, size: 30),
              selectedIcon: Icon(Icons.add_a_photo_rounded, size: 34, color: Color(0xFF0F5C43)),
              label: 'Post',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 30),
              selectedIcon: Icon(Icons.chat_bubble_rounded, size: 34, color: Color(0xFF0F5C43)),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 30),
              selectedIcon: Icon(Icons.settings_rounded, size: 34, color: Color(0xFF0F5C43)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
