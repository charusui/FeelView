import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/app/router.dart';
import 'package:feelview/widgets/post_interaction_bar.dart';

/// Rich Admin Dashboard and Family Management interface for Family Admins (Maria Alvarez).
class AdminHome extends ConsumerStatefulWidget {
  const AdminHome({super.key});

  @override
  ConsumerState<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends ConsumerState<AdminHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider);
    final theme = Theme.of(context);

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
            const Icon(Icons.shield_rounded, color: Color(0xFF6D28D9), size: 24),
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
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Color(0xFF6D28D9),
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
          _buildDashboardTab(context, profile),
          _buildFeedTab(context, profile),
          _buildChatTab(context, profile),
          _buildSettingsTab(context, profile),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRouter.posterCompose),
              backgroundColor: const Color(0xFF6D28D9),
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
          indicatorColor: const Color(0xFFEDE9FE),
          height: 72,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF6D28D9)),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.dynamic_feed_outlined),
              selectedIcon: Icon(Icons.dynamic_feed_rounded, color: Color(0xFF6D28D9)),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF6D28D9)),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF6D28D9)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 0: ADMIN DASHBOARD ───────────────────────────────────────────────

  Widget _buildDashboardTab(BuildContext context, MemberModel profile) {
    final membersAsync = ref.watch(familyMembersProvider);
    final postsAsync = ref.watch(familyPostsProvider);
    final memberCount = membersAsync.value?.length ?? 7;
    final postCount = postsAsync.value?.length ?? 12;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4C1D95), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6D28D9).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${profile.displayName}!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Alvarez Family Network Admin — You are managing elder accessibility and family privacy.',
                        style: TextStyle(fontSize: 13, color: Color(0xFFDDD6FE), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Overview Stats Grid
          const Text('Network Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard('Active Members', '$memberCount Family', Icons.people_alt_rounded, const Color(0xFF10B981), const Color(0xFFDCFCE7)),
              _buildStatCard('Elder Accessibility', '1 Active (Rosa)', Icons.favorite_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              _buildStatCard('Shared Memories', '$postCount Posts', Icons.photo_library_rounded, const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
              _buildStatCard('Subscription', 'FeelView Pro', Icons.workspace_premium_rounded, const Color(0xFF6D28D9), const Color(0xFFEDE9FE)),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text('Admin Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context,
                  title: 'Invite Member',
                  icon: Icons.person_add_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => _showInviteModal(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  context,
                  title: 'Elder Mode Settings',
                  icon: Icons.accessibility_new_rounded,
                  color: const Color(0xFFD97706),
                  onTap: () => _showElderSettingsModal(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  context,
                  title: 'Send Alert',
                  icon: Icons.campaign_rounded,
                  color: const Color(0xFF6D28D9),
                  onTap: () => _showBroadcastModal(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Member Management List
          const Text('Family Directory & Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          membersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (members) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (context, i) {
                  final m = members[i];
                  final isMe = m.id == profile.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: m.role == UserRole.admin ? const Color(0xFFEDE9FE) : const Color(0xFFF1F5F9),
                          child: Text(
                            m.displayName.isNotEmpty ? m.displayName[0].toUpperCase() : '?',
                            style: TextStyle(fontWeight: FontWeight.bold, color: m.role == UserRole.admin ? const Color(0xFF6D28D9) : const Color(0xFF334155)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A))),
                                  if (isMe) const Text(' (You)', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: m.role == UserRole.elder
                                          ? const Color(0xFFDCFCE7)
                                          : m.role == UserRole.admin
                                              ? const Color(0xFFEDE9FE)
                                              : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
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
                                  const SizedBox(width: 8),
                                  Text(
                                    m.role == UserRole.elder ? 'Voice search & simplified tree enabled' : 'Full social access',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showManageMemberModal(context, m),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6D28D9),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text('Manage', style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _buildStatCard(String label, String value, IconData icon, IconColor, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: IconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: FEED ──────────────────────────────────────────────────────────

  Widget _buildFeedTab(BuildContext context, MemberModel profile) {
    final postsAsync = ref.watch(familyPostsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(familyPostsProvider),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text('Family Memories Stream (Admin View)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ),
          ),
          postsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            data: (posts) {
              if (posts.isEmpty) return const SliverFillRemaining(child: Center(child: Text('No memories shared yet.')));
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: const Color(0xFFEDE9FE), child: Text(authorName[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D28D9)))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A))),
                  Text(post.createdAt.toString().split(' ')[0], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ]),
              ),
              if (post.occasion != null)
                Chip(label: Text(post.occasion!), backgroundColor: const Color(0xFFFEF3C7), labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)), padding: EdgeInsets.zero),
            ],
          ),
          const SizedBox(height: 12),
          if (post.mediaUrl != null)
            ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: post.mediaUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)),
          if (post.caption.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(post.caption, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), height: 1.4)),
          ],
          const SizedBox(height: 12),
          PostInteractionBar(post: post, profile: profile, authorName: authorName),
        ],
      ),
    );
  }

  // ─── TAB 2: CHAT ──────────────────────────────────────────────────────────

  Widget _buildChatTab(BuildContext context, MemberModel profile) {
    final threadsAsync = ref.watch(chatThreadsProvider);

    return Column(
      children: [
        // Create Group Chat Button Header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6D28D9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: const Color(0xFF6D28D9).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
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
                    Text('Create custom admin & family conversation circles', style: TextStyle(fontSize: 12, color: Color(0xFFEDE9FE))),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showCreateGroupChatModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6D28D9),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(radius: 24, backgroundColor: const Color(0xFFEDE9FE), child: Icon(t.isGroup ? Icons.groups_rounded : Icons.person_rounded, color: const Color(0xFF6D28D9))),
                      title: Text(t.title ?? (t.isGroup ? 'Family Group Chat' : 'Direct Conversation'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      subtitle: const Text('Tap to open admin messaging view'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
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
                      const Icon(Icons.group_add_rounded, color: Color(0xFF6D28D9), size: 28),
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
                              activeColor: const Color(0xFF6D28D9),
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
                            backgroundColor: Color(0xFF6D28D9),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D28D9),
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

  // ─── TAB 3: SETTINGS ──────────────────────────────────────────────────────

  Widget _buildSettingsTab(BuildContext context, MemberModel profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Family Network Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        _buildSettingCard('Subscription Plan', 'FeelView Pro — Active Unlimited Storage', Icons.workspace_premium_rounded, const Color(0xFF6D28D9)),
        _buildSettingCard('Data Encryption', 'End-to-End Private Family Sandbox', Icons.enhanced_encryption_rounded, const Color(0xFF10B981)),
        _buildSettingCard('Elder Accessibility Sandbox', 'Warm high-contrast palette enabled for Rosa', Icons.favorite_rounded, const Color(0xFFD97706)),
        _buildSettingCard('Export Family Archive', 'Download all photos, voice notes & trees as ZIP', Icons.cloud_download_rounded, const Color(0xFF0284C7)),
      ],
    );
  }

  Widget _buildSettingCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ]),
          ),
        ],
      ),
    );
  }

  // ─── MODALS ───────────────────────────────────────────────────────────────

  void _showInviteModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text('Invite Family Member'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send an invitation link via text or email so they can join the private Alvarez family network.'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email or Mobile Number',
                hintText: 'e.g., cousin@alvarez.family',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _showElderSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.accessibility_new_rounded, color: Color(0xFFD97706), size: 28),
                SizedBox(width: 10),
                Text('Elder Mode Settings (Rosa)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Configure remote accessibility features for Grandma Rosa\'s device:', style: TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            SwitchListTile(title: const Text('Voice Search Mic Button', style: TextStyle(fontWeight: FontWeight.w700)), value: true, onChanged: (_) {}),
            SwitchListTile(title: const Text('Large Typography (125%)', style: TextStyle(fontWeight: FontWeight.w700)), value: true, onChanged: (_) {}),
            SwitchListTile(title: const Text('Simplified Vertical Tree', style: TextStyle(fontWeight: FontWeight.w700)), value: true, onChanged: (_) {}),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Elder preferences saved remotely!')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6D28D9), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBroadcastModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Send Family Broadcast'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g., Don\'t forget Sunday family dinner at Rosa\'s house at 5 PM!',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent to all 7 members!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6D28D9), foregroundColor: Colors.white),
            child: const Text('Broadcast'),
          ),
        ],
      ),
    );
  }

  void _showManageMemberModal(BuildContext context, MemberModel member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage ${member.displayName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Current Role: ${member.role.name.toUpperCase()}', style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: Color(0xFF6D28D9)),
              title: const Text('Make Family Admin', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member.displayName} role updated!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline_rounded, color: Color(0xFF10B981)),
              title: const Text('Set as Elder Accessibility Mode', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member.displayName} set to Elder Mode!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF0284C7)),
              title: const Text('Set as Standard Poster', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member.displayName} set to Poster!')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
