import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/services/firestore_service.dart';

class PostInteractionBar extends StatefulWidget {
  final PostModel post;
  final MemberModel profile;
  final String authorName;

  const PostInteractionBar({
    super.key,
    required this.post,
    required this.profile,
    required this.authorName,
  });

  @override
  State<PostInteractionBar> createState() => _PostInteractionBarState();
}

class _PostInteractionBarState extends State<PostInteractionBar> {
  bool _isLiked = false;
  int _likeCount = 3;
  final List<String> _comments = [
    'Grandma Rosa: So lovely! Seeing this made my day ❤️',
    'Maria Alvarez: Wish we could all be there together!',
    'Carlos Alvarez: Great memory! Sending big hugs!',
  ];
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_rounded, color: Color(0xFF0F5C43), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Comments on ${widget.authorName}\'s Post',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Comments list
                  Expanded(
                    child: _comments.isEmpty
                        ? const Center(child: Text('No comments yet. Be the first to comment!'))
                        : ListView.builder(
                            itemCount: _comments.length,
                            itemBuilder: (context, idx) {
                              final parts = _comments[idx].split(': ');
                              final name = parts.isNotEmpty ? parts[0] : 'Member';
                              final text = parts.length > 1 ? parts.sublist(1).join(': ') : _comments[idx];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(0xFFD1FAE5),
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F5C43)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                                          const SizedBox(height: 4),
                                          Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.3)),
                                        ],
                                      ),
                                    ),
                                    if (widget.profile.role == UserRole.admin || name == widget.profile.displayName)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                        tooltip: 'Delete comment',
                                        onPressed: () {
                                          setModalState(() {
                                            _comments.removeAt(idx);
                                          });
                                          setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Comment removed')),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Comment Input Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Comment as ${widget.profile.displayName}...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F5C43),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: () {
                            final text = _commentCtrl.text.trim();
                            if (text.isNotEmpty) {
                              setModalState(() {
                                _comments.add('${widget.profile.displayName}: $text');
                              });
                              setState(() {});
                              _commentCtrl.clear();
                              HapticFeedback.lightImpact();
                            }
                          },
                        ),
                      ),
                    ],
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: _toggleLike,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                Icon(
                  _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isLiked ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  _isLiked ? 'Liked by You & $_likeCount others' : 'Liked by $_likeCount family members',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: _isLiked ? FontWeight.w700 : FontWeight.w600,
                    color: _isLiked ? const Color(0xFFE11D48) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (widget.profile.role == UserRole.admin || widget.profile.id == widget.post.authorId)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
            tooltip: 'Delete post',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Memory?'),
                  content: const Text('Are you sure you want to delete this post?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await FirestoreService.deletePost(widget.post.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memory removed')),
                  );
                }
              }
            },
          ),
        TextButton.icon(
          onPressed: _showCommentsSheet,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0F5C43),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
          label: Text(
            '${_comments.length} Comments',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
