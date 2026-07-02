import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/services/voice_service.dart';
import 'package:feelview/widgets/widgets.dart';
import 'package:feelview/widgets/accessible_button.dart';
import 'package:feelview/widgets/accessible_text.dart';

class ChatConversation extends ConsumerStatefulWidget {
  const ChatConversation({super.key});

  @override
  ConsumerState<ChatConversation> createState() => _ChatConversationState();
}

class _ChatConversationState extends ConsumerState<ChatConversation> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _isListening = false;

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

  void _listen() async {
    if (_isListening) {
      await VoiceService.stopListening();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    await VoiceService.startListening(
      onResult: (words) {
        setState(() {
          _ctrl.text = words;
          _isListening = false;
        });
      },
    );
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
    if (thread == null) return const Scaffold(body: Center(child: ElderBody('Thread not found')));

    final profile = ref.watch(activeProfileProvider);
    final messagesAsync = ref.watch(messagesProvider(thread.id));

    return Scaffold(
      appBar: AppBar(title: Text(thread.isGroup ? 'Family Chat' : 'Conversation')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const CalmLoadingIndicator(),
              error: (err, _) => Center(child: ElderBody('Error: $err')),
              data: (msgs) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
                });
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final isMe = m.senderId == profile?.id;
                    final canDelete = profile?.role == UserRole.admin || isMe;
                    if (m.voiceNoteUrl != null) {
                      return VoiceNoteBubble(voiceNoteUrl: m.voiceNoteUrl!, isMe: isMe);
                    }
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (canDelete && isMe)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                              tooltip: 'Delete message',
                              onPressed: () => _confirmDelete(context, thread.id, m.id),
                            ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF16A34A) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                              ),
                              border: isMe ? null : Border.all(color: const Color(0xFFD1FAE5), width: 1.5),
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
                                fontSize: 20,
                                color: isMe ? Colors.white : const Color(0xFF064E3B),
                                height: 1.4,
                              ),
                            ),
                          ),
                          if (canDelete && !isMe)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
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
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                AccessibleIconButton(
                  icon: _isListening ? Icons.mic_off : Icons.mic,
                  semanticLabel: 'Voice Dictation',
                  onPressed: _listen,
                  color: _isListening ? Colors.red : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AccessibleIconButton(
                  icon: Icons.send,
                  semanticLabel: 'Send message',
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
