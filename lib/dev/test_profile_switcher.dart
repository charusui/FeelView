import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/services/auth_service.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/dev/seed_data.dart';
import 'package:feelview/app/router.dart';

class TestProfileSwitcher extends ConsumerStatefulWidget {
  const TestProfileSwitcher({super.key});

  @override
  ConsumerState<TestProfileSwitcher> createState() => _TestProfileSwitcherState();
}

class _TestProfileSwitcherState extends ConsumerState<TestProfileSwitcher> {
  bool _seeding = false;

  final _profiles = [
    MemberModel(
      id: 'member-rosa', familyId: 'alvarez-family-001', fullName: 'Rosa Alvarez',
      displayName: 'Grandma Rosa', role: UserRole.elder, relationshipLabelFromElder: const {},
      isMinor: false, voicePronunciationHint: 'Rosa', treePosition: const TreePosition(generation: 0, order: 0),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
      isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-david', familyId: 'alvarez-family-001', fullName: 'David Alvarez',
      displayName: 'David Alvarez', role: UserRole.poster, relationshipLabelFromElder: const {},
      isMinor: false, voicePronunciationHint: 'David', treePosition: const TreePosition(generation: 2, order: 0),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
      isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-maria', familyId: 'alvarez-family-001', fullName: 'Maria Alvarez',
      displayName: 'Maria Alvarez', role: UserRole.admin, relationshipLabelFromElder: const {},
      isMinor: false, voicePronunciationHint: 'Maria', treePosition: const TreePosition(generation: 2, order: 1),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
      isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-junior', familyId: 'alvarez-family-001', fullName: 'Junior Garcia',
      displayName: 'Junior Garcia', role: UserRole.poster, relationshipLabelFromElder: const {},
      isMinor: true, minorPermissionTier: MinorPermissionTier.supervised, guardianUserId: 'member-elena',
      voicePronunciationHint: 'Junior', treePosition: const TreePosition(generation: 2, order: 2),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80',
      isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
  ];

  void _selectProfile(MemberModel profile) async {
    await AuthService.signInAnonymously();
    ref.read(activeProfileProvider.notifier).state = profile;
    ref.read(activeFamilyIdProvider.notifier).state = profile.familyId;
    if (!mounted) return;

    if (profile.role == UserRole.elder) {
      Navigator.pushReplacementNamed(context, AppRouter.elderHome);
    } else if (profile.role == UserRole.admin) {
      Navigator.pushReplacementNamed(context, AppRouter.adminHome);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.posterHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Clean, accessible Dev Environment Header Pill
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.developer_mode_rounded, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'DEV ENVIRONMENT — SPARKFEST 2026',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Warm, human-centered Title & Subtitle
            Text(
              'FeelView',
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Private Family Network Built for Elder Accessibility',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.75),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),

            // Profile Cards Grid with fixed mainAxisExtent to eliminate any overflow
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 210, // Fixed height guarantees zero vertical overflow
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final p = _profiles[index];
                  final isElder = p.role == UserRole.elder;
                  final accentColor = isElder ? const Color(0xFF0F5C43) : const Color(0xFF2563EB);
                  final badgeBg = isElder ? const Color(0xFFD1FAE5) : const Color(0xFFDBEAFE);
                  final badgeText = isElder ? const Color(0xFF064E3B) : const Color(0xFF1E40AF);

                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withOpacity(isElder ? 0.4 : 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectProfile(p),
                        borderRadius: BorderRadius.circular(20),
                        hoverColor: accentColor.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Clean, elegant avatar with subtle border
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: accentColor.withOpacity(0.6), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Text(
                                    p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: colorScheme.onPrimaryContainer,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                p.displayName,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isElder ? 'Elder Mode' : p.role.name.toUpperCase(),
                                  style: TextStyle(
                                    color: badgeText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Clean, prominent Seed Data Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _seeding
                        ? null
                        : () async {
                            setState(() => _seeding = true);
                            try {
                              await SeedData.seedAll(context);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle_outline, color: Colors.white),
                                        SizedBox(width: 12),
                                        Expanded(child: Text('Sample Alvarez Family seeded successfully!')),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF0F5C43),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.white),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text('Error seeding data: $e', style: const TextStyle(color: Colors.white))),
                                      ],
                                    ),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _seeding = false);
                              }
                            }
                          },
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _seeding
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'Seed Sample Family Data',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
