import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/app/router.dart';
import 'package:feelview/widgets/post_interaction_bar.dart';

/// Rich, dynamic social app interface for younger family members (Posters).
class PosterHome extends ConsumerStatefulWidget {
  const PosterHome({super.key});

  @override
  ConsumerState<PosterHome> createState() => _PosterHomeState();
}

class _PosterHomeState extends ConsumerState<PosterHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider);

    if (profile == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.devRoot),
            child: const Text('Return to Dev Switcher'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern slate background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_rounded, color: Color(0xFF10B981), size: 24),
            const SizedBox(width: 8),
            const Text(
              'FeelView',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'POSTER',
                style: TextStyle(
                  color: Color(0xFF3730A3),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.devRoot),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: Color(0xFF475569)),
              label: const Text(
                'Switch Profile',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155)),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildFeedTab(context, profile),
          _buildMembersTab(context, profile),
          _buildChatTab(context, profile),
          _buildProfileAndPostsTab(context, profile),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 3
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRouter.posterCompose),
              backgroundColor: const Color(0xFF0F5C43),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Share Memory', style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = idx);
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFD1FAE5),
          height: 72,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dynamic_feed_outlined),
              selectedIcon: Icon(Icons.dynamic_feed_rounded, color: Color(0xFF0F5C43)),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF0F5C43)),
              label: 'Family Tree',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF0F5C43)),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_pin_circle_outlined),
              selectedIcon: Icon(Icons.person_pin_circle_rounded, color: Color(0xFF0F5C43)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 0: FEED ──────────────────────────────────────────────────────────

  Widget _buildFeedTab(BuildContext context, MemberModel profile) {
    final membersAsync = ref.watch(familyMembersProvider);
    final postsAsync = ref.watch(familyPostsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(familyPostsProvider);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Welcome header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Hello, ${profile.displayName}!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
            ),
          ),
          // Stories / Highlights bar
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: membersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
                data: (members) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: members.length,
                    itemBuilder: (context, i) {
                      final m = members[i];
                      final isMe = m.id == profile.id;
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRouter.elderPersonFeed, arguments: m),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF10B981), Color(0xFF0F5C43)],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  child: Text(
                                    m.displayName.isNotEmpty ? m.displayName[0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F5C43)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isMe ? 'You' : m.displayName.split(' ')[0],
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider(height: 24)),
          // Feed title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                'Family Memories Stream',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ),
          ),
          // Posts list
          postsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            data: (posts) {
              if (posts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No memories shared yet. Tap "+ Share Memory" to get started!')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildPostCard(context, posts[i], profile),
                  childCount: posts.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post, MemberModel profile) {
    final membersAsync = ref.watch(familyMembersProvider);
    final authorName = membersAsync.value?.where((m) => m.id == post.authorId).firstOrNull?.displayName ?? 'Family Member';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFD1FAE5),
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5C43)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A))),
                      Text(
                        post.createdAt.toString().split(' ')[0],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (post.occasion != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.occasion!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                    ),
                  ),
              ],
            ),
          ),
          // Media photo
          if (post.mediaUrl != null)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: post.mediaUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFFF1F5F9), child: const Center(child: CircularProgressIndicator())),
                errorWidget: (_, __, ___) => Container(color: const Color(0xFFF1F5F9), child: const Icon(Icons.broken_image_rounded, size: 48)),
              ),
            )
          else
            Container(
              height: 120,
              color: const Color(0xFFF0FDF4),
              child: const Center(
                child: Icon(Icons.article_rounded, size: 48, color: Color(0xFF10B981)),
              ),
            ),
          // Caption
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.caption.isNotEmpty)
                  Text(
                    post.caption,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B), height: 1.4),
                  ),
                const SizedBox(height: 14),
                PostInteractionBar(post: post, profile: profile, authorName: authorName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: MEMBERS TREE (SEPARATE FROM YOUR PROFILE) ─────────────────────

  Widget _buildMembersTab(BuildContext context, MemberModel profile) {
    final membersAsync = ref.watch(familyMembersProvider);

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (members) {
        // Exclude the current user ("Your Profile") so they are separate!
        final otherMembers = members.where((m) => m.id != profile.id).toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: otherMembers.length,
          itemBuilder: (context, i) {
            final m = otherMembers[i];
            final rel = m.getRelationshipTitleCase(profile.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFE0F2FE),
                    child: Text(
                      m.displayName.isNotEmpty ? m.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m.displayName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: m.role == UserRole.elder
                                    ? const Color(0xFFDCFCE7)
                                    : m.role == UserRole.admin
                                        ? const Color(0xFFEDE9FE)
                                        : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                m.role.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: m.role == UserRole.elder
                                      ? const Color(0xFF15803D)
                                      : m.role == UserRole.admin
                                          ? const Color(0xFF6D28D9)
                                          : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(rel.isNotEmpty ? rel : 'Family Member', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pushNamed(context, AppRouter.elderPersonFeed, arguments: m),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── TAB 2: YOUR PROFILE & MY POSTS (COMBINED) ────────────────────────────

  Widget _buildProfileAndPostsTab(BuildContext context, MemberModel profile) {
    final postsAsync = ref.watch(memberPostsProvider(profile.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Profile Card (Combined with My Posts)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F5C43), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0F5C43).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    profile.displayName.isNotEmpty ? profile.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F5C43)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.displayName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              profile.role.name.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your Profile — Active Family Member',
                        style: TextStyle(fontSize: 14, color: Color(0xFFD1FAE5)),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildProfileStatBadge('Family Network', 'Alvarez'),
                          _buildProfileStatBadge('Status', 'Connected'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title
          const Row(
            children: [
              Icon(Icons.photo_library_rounded, color: Color(0xFF0F5C43)),
              SizedBox(width: 8),
              Text(
                'My Shared Memories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Posts List
          postsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (posts) {
              if (posts.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('You haven\'t posted anything yet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRouter.posterCompose),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5C43), foregroundColor: Colors.white),
                        icon: const Icon(Icons.add),
                        label: const Text('Share First Memory'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, i) {
                  final p = posts[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        if (p.mediaUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: p.mediaUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(width: 64, height: 64, color: const Color(0xFFF1F5F9)),
                            ),
                          )
                        else
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.article_rounded, color: Color(0xFF0F5C43)),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.caption.isNotEmpty ? p.caption : (p.occasion ?? 'Photo post'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('Shared on ${p.createdAt.toString().split(" ")[0]}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () {
                            FirestoreService.deletePost(p.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory deleted')));
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatBadge(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $val',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  // ─── TAB 3: CHAT & CREATE GROUP CHATS ─────────────────────────────────────

  Widget _buildChatTab(BuildContext context, MemberModel profile) {
    final threadsAsync = ref.watch(chatThreadsProvider);

    return Column(
      children: [
        // Create Group Chat Button Header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F5C43),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: const Color(0xFF0F5C43).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Family Group Chats', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Create custom conversation circles with Grandma Rosa & cousins', style: TextStyle(fontSize: 12, color: Color(0xFFD1FAE5))),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showCreateGroupChatModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F5C43),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('+ Create Group', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
        ),
        const Divider(height: 24),
        // Chat threads list
        Expanded(
          child: threadsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (threads) {
              if (threads.isEmpty) {
                return const Center(child: Text('No conversations yet. Tap "+ Create Group" above!'));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: threads.length,
                itemBuilder: (context, i) {
                  final t = threads[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: t.isGroup ? const Color(0xFFDCFCE7) : const Color(0xFFE0E7FF),
                        child: Icon(t.isGroup ? Icons.groups_rounded : Icons.person_rounded, color: t.isGroup ? const Color(0xFF15803D) : const Color(0xFF4338CA), size: 28),
                      ),
                      title: Text(t.title ?? (t.isGroup ? 'Family Group Chat' : 'Direct Conversation'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      subtitle: const Text('Tap to view messages & voice notes', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onTap: () => Navigator.pushNamed(context, AppRouter.posterChatConversation, arguments: t),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateGroupChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.group_add_rounded, color: Color(0xFF0F5C43), size: 28),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Create Family Group Chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)))),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Select family members to include (scroll to see extended family):', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Group Chat Name',
                      hintText: 'e.g., Sunday Dinner Planning, Cousins Chat...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Select Members (All Family Branches):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),

                  // Scrollable member list!
                  Expanded(
                    child: FutureBuilder<List<MemberModel>>(
                      future: FirestoreService.getFamilyMembers(ref.read(activeFamilyIdProvider) ?? 'alvarez-family-001'),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final members = snap.data!;
                        return ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, idx) {
                            final m = members[idx];
                            final branch = m.familyBranchLabel ?? (m.role == UserRole.elder ? 'Elder Circle' : 'Extended Family');
                            final roleLabel = m.role == UserRole.elder ? 'Elder' : (m.role == UserRole.admin ? 'Admin' : 'Poster');
                            return CheckboxListTile(
                              title: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              subtitle: Text('$roleLabel • $branch', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              value: true,
                              activeColor: const Color(0xFF0F5C43),
                              onChanged: (_) {},
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Group chat created! All selected family members invited.'),
                            backgroundColor: Color(0xFF0F5C43),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5C43),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Create Group Chat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
