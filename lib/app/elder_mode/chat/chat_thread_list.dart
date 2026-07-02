import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/widgets/widgets.dart';
import 'package:feelview/widgets/accessible_text.dart';
import 'package:feelview/widgets/accessible_button.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/app/router.dart';

class ChatThreadList extends ConsumerWidget {
  const ChatThreadList({super.key});

  void _showNewMessageDialog(BuildContext context, WidgetRef ref) {
    final elder = ref.read(activeProfileProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final members = ref.watch(familyMembersProvider).value ?? [];
          final otherMembers = members.where((m) => m.id != elder?.id).toList();
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ElderHeading('Select Family Member'),
                const SizedBox(height: 16),
                if (otherMembers.isEmpty)
                  const ElderBody('No other family members found.')
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: otherMembers.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final m = otherMembers[i];
                        final rel = m.getRelationshipTitleCase(elder?.id);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              m.displayName.isNotEmpty ? m.displayName[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: ElderBody(m.displayName),
                          subtitle: ElderCaption(rel.isNotEmpty ? rel : 'Family'),
                          trailing: const Icon(Icons.chat_bubble_rounded, size: 28, color: Color(0xFF0F5C43)),
                          onTap: () async {
                            Navigator.pop(ctx);
                            if (elder == null) return;
                            final thread = await FirestoreService.getOrCreateDirectThread(
                              elder.familyId,
                              elder.id,
                              m.id,
                            );
                            if (thread != null && context.mounted) {
                              Navigator.pushNamed(
                                context,
                                AppRouter.elderChatConversation,
                                arguments: thread,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(chatThreadsProvider);
    final elder = ref.watch(activeProfileProvider);
    final members = ref.watch(familyMembersProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewMessageDialog(context, ref),
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white, size: 28),
        label: const Text('New Message', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: threadsAsync.when(
        loading: () => const CalmLoadingIndicator(message: 'Loading messages...'),
        error: (err, _) => Center(child: ElderBody('Could not load messages: $err')),
        data: (threads) {
          if (threads.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ElderBody(
                      'No messages yet.\nStart a conversation with a family member!',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    AccessibleButton(
                      onPressed: () => _showNewMessageDialog(context, ref),
                      label: 'Start New Conversation',
                      icon: Icons.chat_bubble_rounded,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: threads.length,
            separatorBuilder: (_, __) => const Divider(height: 32, thickness: 2),
            itemBuilder: (context, index) {
              final t = threads[index];
              String title = 'Family Chat';
              String subtitle = 'Tap to view conversation';
              String initials = 'FC';
              bool isDirect = !t.isGroup;

              if (isDirect) {
                final otherId = t.participantIds.firstWhere((id) => id != elder?.id, orElse: () => '');
                final otherMember = members.where((m) => m.id == otherId).firstOrNull;
                if (otherMember != null) {
                  title = otherMember.displayName;
                  final rel = otherMember.getRelationshipTitleCase(elder?.id);
                  subtitle = rel.isNotEmpty ? '$rel • Tap to chat' : 'Family Member • Tap to chat';
                  initials = otherMember.displayName.isNotEmpty ? otherMember.displayName[0].toUpperCase() : '?';
                } else {
                  title = 'Family Member';
                  initials = '?';
                }
              }

              return LargeTapTarget(
                minHeight: 80,
                onTap: () => Navigator.pushNamed(context, AppRouter.elderChatConversation, arguments: t),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: isDirect
                          ? Text(
                              initials,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            )
                          : Icon(Icons.group, size: 32, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElderHeading(title),
                          const SizedBox(height: 4),
                          ElderCaption(subtitle),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 28),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
