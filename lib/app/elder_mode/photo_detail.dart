import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/services/tts_service.dart';
import 'package:feelview/widgets/widgets.dart';
import 'package:feelview/widgets/accessible_text.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/services/firestore_service.dart';

class PhotoDetail extends ConsumerStatefulWidget {
  const PhotoDetail({super.key});

  @override
  ConsumerState<PhotoDetail> createState() => _PhotoDetailState();
}

class _PhotoDetailState extends ConsumerState<PhotoDetail> {
  bool _isSpeaking = false;

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  Future<void> _toggleSpeak(String text) async {
    if (_isSpeaking) {
      await TtsService.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await TtsService.speak(text);
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    PostModel? post;
    MemberModel? member;
    if (args is Map) {
      post = args['post'] as PostModel?;
      member = args['member'] as MemberModel?;
    } else if (args is PostModel) {
      post = args;
    }

    if (post == null) {
      return const Scaffold(body: Center(child: ElderBody('Photo not found')));
    }

    final theme = Theme.of(context);
    final narration = post.aiNarrationText.isNotEmpty
        ? post.aiNarrationText
        : post.caption.isNotEmpty
            ? post.caption
            : 'A photo shared by your family.';

    final activeProfile = ref.watch(activeProfileProvider);
    final canDelete = activeProfile?.role == UserRole.admin || activeProfile?.id == post.authorId;

    return Scaffold(
      appBar: AppBar(
        title: Text(member?.displayName ?? 'Photo'),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
              tooltip: 'Delete Photo',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Photo?'),
                    content: const Text('Are you sure you want to delete this photo memory?'),
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
                  await FirestoreService.deletePost(post!.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo deleted')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                if (post.mediaUrl != null)
                  CachedNetworkImage(
                    imageUrl: post.mediaUrl!,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox(
                      height: 300,
                      child: CalmLoadingIndicator(),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 300,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () => _toggleSpeak(narration),
                    backgroundColor: _isSpeaking ? theme.colorScheme.error : theme.colorScheme.primary,
                    icon: Icon(_isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded, color: Colors.white),
                    label: Text(_isSpeaking ? 'Stop' : 'Listen', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (member != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElderHeading(member.displayName),
                              if (member.relationshipLabelFromElder.isNotEmpty)
                                ElderBody(member.relationshipLabelFromElder.values.first.toTitleCase(), color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (post.caption.isNotEmpty) ...[
                    ElderHeading(post.caption),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElderCaption('Narration / Description:', color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        ElderBody(narration),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
