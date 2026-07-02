import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/widgets/widgets.dart';
import 'package:feelview/widgets/accessible_text.dart';
import 'package:feelview/widgets/accessible_button.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/app/router.dart';

class PersonFeed extends ConsumerStatefulWidget {
  const PersonFeed({super.key});

  @override
  ConsumerState<PersonFeed> createState() => _PersonFeedState();
}

class _PersonFeedState extends ConsumerState<PersonFeed> {
  @override
  Widget build(BuildContext context) {
    final member = ModalRoute.of(context)?.settings.arguments as MemberModel?;
    if (member == null) {
      return const Scaffold(body: Center(child: ElderBody('Member not found')));
    }

    final elder = ref.watch(activeProfileProvider);
    final relationship = member.getRelationshipTitleCase(elder?.id);
    final postsAsync = ref.watch(memberPostsProvider(member.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.displayName),
            if (relationship.isNotEmpty)
              Text(
                relationship,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AccessibleButton(
              onPressed: () async {
                if (elder == null) return;
                final thread = await FirestoreService.getOrCreateDirectThread(
                  elder.familyId,
                  elder.id,
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
              label: 'Message ${member.displayName}',
              icon: Icons.chat_bubble_rounded,
            ),
          ),
          Expanded(
            child: postsAsync.when(
              loading: () => const CalmLoadingIndicator(message: 'Loading photos...'),
              error: (err, _) => Center(child: ElderBody('Could not load photos: $err')),
              data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElderBody(
                  'No photos shared yet.\nCheck back soon!',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(memberPostsProvider(member.id));
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: posts.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 24),
              itemBuilder: (ctx, i) {
                final post = posts[i];
                return PhotoCard(
                  post: post,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.elderPhotoDetail,
                      arguments: {
                        'post': post,
                        'member': member,
                        'relationshipLabel': relationship,
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }
}
