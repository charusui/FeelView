import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/widgets/widgets.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/app/router.dart';

/// Poster's view of the family tree — grid of all members.
class FamilyTreeHomePoster extends ConsumerWidget {
  const FamilyTreeHomePoster({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manage Tree coming in Phase 4')),
              );
            },
            child: const Text('Manage Tree'),
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No family members yet.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 600 ? 4 : 3;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 170,
                ),
                itemCount: members.length,
                itemBuilder: (context, i) {
                  final m = members[i];
                  return MemberTile(
                    member: m,
                    size: 80,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.elderPersonFeed,
                      arguments: m.id,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
