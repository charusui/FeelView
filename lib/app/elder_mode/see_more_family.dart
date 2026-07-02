import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/widgets/widgets.dart';
import 'package:feelview/widgets/accessible_text.dart';
import 'package:feelview/app/router.dart';
import 'package:feelview/services/firestore_service.dart';

class SeeMoreFamily extends ConsumerWidget {
  const SeeMoreFamily({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    final allAsync = ref.watch(familyMembersProvider);
    final elderId = profile?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('More Family'),
        leading: LargeTapTarget(
          onTap: () => Navigator.pop(context),
          semanticLabel: 'Go back',
          child: const Icon(Icons.arrow_back_rounded, size: 28),
        ),
        automaticallyImplyLeading: false,
      ),
      body: allAsync.when(
        loading: () => const CalmLoadingIndicator(message: 'Loading family...'),
        error: (e, _) => Center(child: ElderBody('Something went wrong.')),
        data: (allMembers) {
          // Filter out core-circle members
          final nonCore = allMembers
              .where((m) => !m.isCoreCircleFor.contains(elderId))
              .toList();

          if (nonCore.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: ElderBody(
                  'No additional family members yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Group by familyBranchLabel; null → "Other Family"
          final grouped = <String, List<MemberModel>>{};
          for (final m in nonCore) {
            final key = m.familyBranchLabel ?? 'Other Family';
            grouped.putIfAbsent(key, () => []).add(m);
          }
          // Sort within each group alphabetically
          for (final list in grouped.values) {
            list.sort((a, b) => a.displayName.compareTo(b.displayName));
          }
          final sections = grouped.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: sections.length,
            itemBuilder: (context, i) {
              final section = sections[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ElderHeading(section.key),
                  ),
                  ...section.value.map((member) {
                    final rel = member.getRelationshipTitleCase(elderId);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.elderPersonFeed,
                            arguments: member,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElderHeading(member.displayName),
                                    if (rel.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          rel,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                iconSize: 32,
                                color: Theme.of(context).colorScheme.primary,
                                tooltip: 'Chat with ${member.displayName}',
                                icon: const Icon(Icons.chat_bubble_rounded),
                                onPressed: () async {
                                  if (elderId.isEmpty || profile?.familyId == null) return;
                                  final thread = await FirestoreService.getOrCreateDirectThread(
                                    profile!.familyId,
                                    elderId,
                                    member.id,
                                  );
                                  if (thread != null && context.mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.elderChatConversation,
                                      arguments: thread,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 24, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
