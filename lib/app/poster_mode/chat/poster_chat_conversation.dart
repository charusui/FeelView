import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/services/firestore_service.dart';

class PosterChatConversation extends ConsumerStatefulWidget {
  const PosterChatConversation({super.key});

  @override
  ConsumerState<PosterChatConversation> createState() => _PosterChatConversationState();
}

class _PosterChatConversationState extends ConsumerState<PosterChatConversation> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    final thread = ModalRoute.of(context)?.settings.arguments as ChatThreadModel?;
    final profile = ref.read(activeProfileProvider);
    if (text.isEmpty || thread == null || profile == null) return;

    final msg = ChatMessageModel(
      id: '',
      threadId: thread.id,
      senderId: profile.id,
      content: text,
      createdAt: DateTime.now(),
    );
    FirestoreService.sendMessage(msg);
    _ctrl.clear();
  }

  void _confirmDelete(BuildContext context, String threadId, String msgId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('Are you sure you want to remove this message?'),
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
      await FirestoreService.deleteMessage(threadId, msgId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message removed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = ModalRoute.of(context)?.settings.arguments as ChatThreadModel?;
    if (thread == null) return const Scaffold(body: Center(child: Text('Thread not found')));

    final profile = ref.watch(activeProfileProvider);
    final messagesAsync = ref.watch(messagesProvider(thread.id));

    return Scaffold(
      appBar: AppBar(title: Text(thread.isGroup ? 'Family Group Chat' : 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (msgs) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
                });
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final isMe = m.senderId == profile?.id;
                    final canDelete = profile?.role == UserRole.admin || isMe;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (canDelete && isMe)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              tooltip: 'Delete message',
                              onPressed: () => _confirmDelete(context, thread.id, m.id),
                            ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF2563EB) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                              ),
                              border: isMe ? null : Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              m.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: isMe ? Colors.white : const Color(0xFF1E3A5F),
                                height: 1.4,
                              ),
                            ),
                          ),
                          if (canDelete && !isMe)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              tooltip: 'Delete message',
                              onPressed: () => _confirmDelete(context, thread.id, m.id),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Message family...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
