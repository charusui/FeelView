import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/services/voice_service.dart';
import 'package:feelview/widgets/widgets.dart';
import 'package:feelview/widgets/accessible_button.dart';
import 'package:feelview/widgets/accessible_text.dart';
import 'package:feelview/app/elder_mode/elder_shell.dart';
import 'package:feelview/app/router.dart';

class FamilyTreeHome extends ConsumerStatefulWidget {
  const FamilyTreeHome({super.key});

  @override
  ConsumerState<FamilyTreeHome> createState() => _FamilyTreeHomeState();
}

class _FamilyTreeHomeState extends ConsumerState<FamilyTreeHome> {
  int _navIndex = 0;

  void _onNavTap(int index) {
    if (index == 0) return;
    if (index == 1) Navigator.pushNamed(context, AppRouter.posterCompose);
    if (index == 2) Navigator.pushNamed(context, AppRouter.elderChat);
    if (index == 3) Navigator.pushNamed(context, AppRouter.elderSettings);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider);
    final coreAsync = ref.watch(coreCircleMembersProvider);
    final allMembersAsync = ref.watch(familyMembersProvider);

    final greeting = profile != null ? 'Hello, ${profile.displayName}!' : 'Hello!';

    return ElderShell(
      title: greeting,
      currentIndex: _navIndex,
      onTap: _onNavTap,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.devRoot),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
            label: const Text('Switch Profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
      ],
      body: coreAsync.when(
        loading: () => const CalmLoadingIndicator(message: 'Loading your family...'),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Card(
              color: const Color(0xFFFEE2E2),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ElderBody('Something went wrong loading your family. Please check your connection.', textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
        data: (coreMembers) {
          if (coreMembers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.photo_library_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 24),
                        ElderHeading('Welcome to Your Family Tree!', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElderBody(
                          'Your family photos and voice notes will appear right here.\nAsk David or Maria to post some new photos for you!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final elderId = profile?.id ?? '';
          final hasMore = allMembersAsync.valueOrNull?.any(
                (m) => !m.isCoreCircleFor.contains(elderId),
              ) ??
              false;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Voice Finder Bar replacing old banner
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: VoiceFinderBar(elderId: elderId),
              ),
              // Vertical Family Tree
              Expanded(
                child: VerticalFamilyTree(
                  coreMembers: coreMembers,
                  elder: profile,
                  hasMore: hasMore,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── VoiceFinderBar ─────────────────────────────────────────────────────────────

class VoiceFinderBar extends ConsumerStatefulWidget {
  final String elderId;
  const VoiceFinderBar({super.key, required this.elderId});

  @override
  ConsumerState<VoiceFinderBar> createState() => _VoiceFinderBarState();
}

class _VoiceFinderBarState extends ConsumerState<VoiceFinderBar> {
  bool _isListening = false;
  String _statusText = 'Tap the microphone and say a name, like "Show me Sarah."';

  void _onMicTap() async {
    if (_isListening) {
      await VoiceService.stopListening();
      setState(() {
        _isListening = false;
        _statusText = 'Tap the microphone and say a name, like "Show me Sarah."';
      });
      return;
    }

    final available = await VoiceService.initialize();
    if (!available) {
      _showSimulationSheet();
      return;
    }

    setState(() {
      _isListening = true;
      _statusText = 'Listening… Say a family member\'s name';
    });

    await VoiceService.startListening(
      onResult: (words) {
        _matchAndNavigate(words);
      },
      onDone: () {
        if (mounted && _isListening) {
          setState(() {
            _isListening = false;
            if (_statusText.startsWith('Listening')) {
              _statusText = 'Tap the microphone and say a name, like "Show me Sarah."';
            }
          });
        }
      },
    );
  }

  void _matchAndNavigate(String words) {
    if (words.trim().isEmpty) return;
    final said = words.toLowerCase();
    final members = ref.read(familyMembersProvider).value ?? [];
    
    final match = members.where((m) {
      if (m.id == widget.elderId) return false;
      final nameMatch = m.displayName.toLowerCase().split(' ').any((part) => part.isNotEmpty && said.contains(part));
      final rel = (m.relationshipLabelFromElder[widget.elderId] ?? '').toLowerCase();
      final relMatch = rel.isNotEmpty && rel.split(' ').any((part) => part.length > 2 && said.contains(part));
      return nameMatch || relMatch;
    }).firstOrNull;

    setState(() {
      _isListening = false;
      if (match != null) {
        _statusText = 'Showing ${match.displayName}...';
      } else {
        _statusText = 'I heard "$words" but couldn\'t find that person.';
      }
    });

    if (match != null && mounted) {
      Navigator.pushNamed(context, AppRouter.elderPersonFeed, arguments: match);
    }
  }

  void _showSimulationSheet() {
    final members = ref.read(familyMembersProvider).value ?? [];
    final otherMembers = members.where((m) => m.id != widget.elderId).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ElderHeading('Voice Search Simulation'),
            const SizedBox(height: 8),
            const ElderBody('Select a family member to simulate speaking their name into the microphone:'),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: otherMembers.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final m = otherMembers[i];
                  final rel = m.getRelationshipTitleCase(widget.elderId);
                  return ListTile(
                    leading: const Icon(Icons.mic, color: Color(0xFFC99A2E), size: 28),
                    title: ElderBody('Say: "Show me ${m.displayName}"'),
                    subtitle: ElderCaption(rel.isNotEmpty ? rel : 'Family'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _matchAndNavigate(m.displayName);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        border: Border.all(color: const Color(0xFFDDD2B6), width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onMicTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _isListening ? const Color(0xFFC96B6B) : const Color(0xFFC99A2E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _statusText,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F3B2D),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── VerticalFamilyTree ─────────────────────────────────────────────────────────

class VerticalFamilyTree extends StatelessWidget {
  final List<MemberModel> coreMembers;
  final MemberModel? elder;
  final bool hasMore;

  const VerticalFamilyTree({
    super.key,
    required this.coreMembers,
    required this.elder,
    required this.hasMore,
  });

  static const List<Color> _avatarColors = [
    Color(0xFF5C8368), // Branch green
    Color(0xFF3F6B4F), // Forest green
    Color(0xFFC96B6B), // Warm rose
    Color(0xFF7B6BA8), // Muted purple
    Color(0xFFD98B54), // Warm orange
    Color(0xFF4A7C59), // Sage green
    Color(0xFFA86258), // Terracotta
  ];

  static Color _getAvatarColor(String id) {
    final hash = id.hashCode.abs();
    return _avatarColors[hash % _avatarColors.length];
  }

  String _getGenerationLabel(int gen) {
    switch (gen) {
      case -1:
        return 'YOUR PARENTS';
      case 0:
        return 'YOUR GENERATION';
      case 1:
        return 'YOUR CHILDREN';
      case 2:
        return 'YOUR GRANDCHILDREN';
      case 3:
        return 'YOUR GREAT-GRANDCHILDREN';
      default:
        if (gen > 3) return 'GENERATION $gen';
        return 'FAMILY';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group members by generation
    final Map<int, List<MemberModel>> byGen = {};
    for (final m in coreMembers) {
      final gen = m.treePosition.generation;
      byGen.putIfAbsent(gen, () => []).add(m);
    }

    // Ensure elder is in generation 0 if not present in coreMembers list
    if (elder != null) {
      byGen.putIfAbsent(0, () => []);
      if (!byGen[0]!.any((m) => m.id == elder!.id)) {
        byGen[0]!.insert(0, elder!);
      }
    }

    final sortedGens = byGen.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Trunk line
          Positioned.fill(
            child: Center(
              child: Container(
                width: 4,
                color: const Color(0xFF5C8368),
              ),
            ),
          ),
          // Generations content
          Column(
            children: [
              const SizedBox(height: 12),
              for (int i = 0; i < sortedGens.length; i++) ...[
                if (i > 0) ...[
                  // Connector
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF5C8368),
                  ),
                  // Gen Label
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF5),
                      border: Border.all(color: const Color(0xFF5C8368), width: 2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      _getGenerationLabel(sortedGens[i]),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF3F5C4C),
                      ),
                    ),
                  ),
                ],
                // Generation nodes
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 28,
                  children: byGen[sortedGens[i]]!.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final member = entry.value;
                    final isSelf = member.id == elder?.id;
                    final rel = isSelf ? 'Your profile' : member.getRelationshipTitleCase(elder?.id);
                    final hasNew = !isSelf && (idx == 0 || idx == 1);
                    final avatarBg = isSelf ? const Color(0xFFC99A2E) : _getAvatarColor(member.id);
                    final outlineColor = isSelf ? const Color(0xFF93701E) : const Color(0xFF5C8368);

                    return LargeTapTarget(
                      minWidth: 130,
                      minHeight: 160,
                      onTap: isSelf
                          ? null
                          : () => Navigator.pushNamed(
                                context,
                                AppRouter.elderPersonFeed,
                                arguments: member,
                              ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  color: avatarBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFFFCF5), width: 5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: outlineColor.withOpacity(0.4),
                                      spreadRadius: 3,
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    isSelf ? 'You' : (member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : '?'),
                                    style: TextStyle(
                                      fontSize: isSelf ? 26 : 38,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (hasNew)
                                Positioned(
                                  bottom: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC96B6B),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFFFFCF5), width: 2),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    child: Text(
                                      idx == 0 ? '3 new' : 'New',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFCF5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFDDD2B6), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isSelf ? (elder?.displayName ?? 'You') : member.displayName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F3B2D),
                                    letterSpacing: -0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  rel.isNotEmpty ? rel : 'Family',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF3F5C4C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),
              ],
              if (hasMore) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: AccessibleButton(
                    label: 'See Extended Family Tree',
                    icon: Icons.people_alt_rounded,
                    onPressed: () => Navigator.pushNamed(context, AppRouter.elderSeeMore),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
