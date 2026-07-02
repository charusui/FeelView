import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/widgets/accessible_text.dart';

/// Ensures any child meets the 64×64pt accessibility minimum.
/// Wraps with GestureDetector when [onTap] is provided.
class LargeTapTarget extends StatelessWidget {
  const LargeTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minWidth = 64,
    this.minHeight = 64,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double minWidth;
  final double minHeight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget w = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
      child: child,
    );
    if (onTap != null) {
      w = Semantics(
        label: semanticLabel,
        button: semanticLabel != null,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap!();
          },
          child: w,
        ),
      );
    }
    return w;
  }
}

/// Large tappable tile showing a family member's avatar + display name.
/// Used in Core Circle and See More Family screens.
class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.member,
    required this.onTap,
    this.relationshipLabel,
    this.hasRecentPost = false,
    this.size = 120,
  });

  final MemberModel member;
  final VoidCallback onTap;
  /// e.g. "Your Grandson" — shown below the name in elder mode.
  final String? relationshipLabel;
  /// Shows a subtle activity glow when true.
  final bool hasRecentPost;
  /// Width/height of the avatar circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '${member.displayName}${relationshipLabel != null ? ", $relationshipLabel" : ""}. Tap to see their photos.',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: SizedBox(
          width: size + 16,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Luxurious Avatar with glowing ring and shadow
                Container(
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: hasRecentPost
                          ? [const Color(0xFF34D399), const Color(0xFF10B981)]
                          : [theme.colorScheme.outline.withOpacity(0.5), theme.colorScheme.outline.withOpacity(0.2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: hasRecentPost
                            ? const Color(0xFF10B981).withOpacity(0.4)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        spreadRadius: hasRecentPost ? 4 : 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _InitialAvatar(member: member, size: size),
                  ),
                ),
                const SizedBox(height: 10),
                ElderBody(
                  member.displayName,
                  textAlign: TextAlign.center,
                ),
                if (relationshipLabel != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      relationshipLabel!.toTitleCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                if (hasRecentPost)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NEW PHOTO',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback avatar: Coloured gradient circle with member's initials.
class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.member, required this.size});
  final MemberModel member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(member.displayName);
    final gradient = _gradientForName(member.displayName);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  List<Color> _gradientForName(String name) {
    const palette = [
      [Color(0xFF10B981), Color(0xFF059669)], // Emerald
      [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Royal Blue
      [Color(0xFF8B5CF6), Color(0xFF6D28D9)], // Purple
      [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber Warm
      [Color(0xFFEC4899), Color(0xFFBE185D)], // Rose
      [Color(0xFF06B6D4), Color(0xFF0E7490)], // Cyan
    ];
    return palette[name.codeUnits.fold(0, (a, b) => a + b) % palette.length];
  }
}

/// Always-visible floating Home button shown on every Elder Mode screen
/// except the family tree home itself.
class HomeButton extends StatelessWidget {
  const HomeButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Semantics(
        label: 'Go to Family Tree Home',
        button: true,
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          icon: const Icon(Icons.home_rounded, size: 28),
          label: const Text(
            'Home',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          heroTag: 'home_fab',
        ),
      ),
    );
  }
}

/// Feed card for a photo/video/text post.
/// Tap the whole card → navigates to photo detail.
class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.post,
    required this.onTap,
    this.showNarrateHint = true,
  });

  final PostModel post;
  final VoidCallback onTap;
  final bool showNarrateHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Photo post. ${post.caption.isNotEmpty ? post.caption : "No caption"}. Tap to hear about this photo.',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Media
              if (post.mediaUrl != null)
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: post.mediaUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 80,
                  color: theme.colorScheme.primaryContainer,
                  child: Center(
                    child: Icon(Icons.article_rounded, size: 40,
                        color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              // Caption + narrate hint
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.occasion != null)
                      Chip(
                        label: Text(post.occasion!),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                        padding: EdgeInsets.zero,
                      ),
                    if (post.caption.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ElderBody(post.caption, maxLines: 3),
                    ],
                    if (showNarrateHint) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.volume_up_rounded,
                              color: theme.colorScheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElderCaption('Tap to hear about this photo',
                                color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              color: theme.colorScheme.secondary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElderCaption('3 Family Comments • Tap to read & reply',
                                color: theme.colorScheme.secondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chat bubble for voice note messages.
class VoiceNoteBubble extends StatelessWidget {
  const VoiceNoteBubble({
    super.key,
    required this.voiceNoteUrl,
    required this.isMe,
    this.onPlay,
    this.isPlaying = false,
  });

  final String voiceNoteUrl;
  final bool isMe;
  final VoidCallback? onPlay;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHigh;
    final fg = isMe ? Colors.white : theme.colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LargeTapTarget(
              onTap: onPlay,
              semanticLabel: isPlaying ? 'Stop voice note' : 'Play voice note',
              child: Icon(
                isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_filled_rounded,
                color: fg,
                size: 40,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text('Voice message',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calm pulsing loading indicator — no spinning anxiety for elders.
class CalmLoadingIndicator extends StatefulWidget {
  const CalmLoadingIndicator({super.key, this.message});
  final String? message;

  @override
  State<CalmLoadingIndicator> createState() => _CalmLoadingIndicatorState();
}

class _CalmLoadingIndicatorState extends State<CalmLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _anim,
            child: Icon(Icons.favorite_rounded,
                color: theme.colorScheme.primary, size: 48),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            ElderBody(widget.message!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
