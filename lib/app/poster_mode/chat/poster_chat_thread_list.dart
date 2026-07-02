import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/app/router.dart';

class PosterChatThreadList extends ConsumerWidget {
  const PosterChatThreadList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(chatThreadsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Family Chat')),
      body: threadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (threads) {
          if (threads.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }
          return ListView.separated(
            itemCount: threads.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final t = threads[i];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(t.isGroup ? Icons.group : Icons.person),
                ),
                title: Text(t.isGroup ? 'Family Group Chat' : 'Direct Message'),
                subtitle: const Text('Tap to open conversation'),
                onTap: () => Navigator.pushNamed(context, AppRouter.posterChatConversation, arguments: t),
              );
            },
          );
        },
      ),
    );
  }
}
