import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/app/router.dart';

class MyPosts extends ConsumerWidget {
  const MyPosts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return const Scaffold(body: Center(child: Text('No profile')));

    final postsAsync = ref.watch(memberPostsProvider(profile.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppRouter.posterCompose),
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('You haven\'t posted anything yet. Tap + to share!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final p = posts[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(p.caption.isNotEmpty ? p.caption : (p.occasion ?? 'Photo post')),
                  subtitle: Text('Posted on ${p.createdAt.toString().split(" ")[0]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => FirestoreService.deletePost(p.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.posterCompose),
        child: const Icon(Icons.add),
      ),
    );
  }
}
