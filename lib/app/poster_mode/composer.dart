import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/widgets/accessible_button.dart';
import 'package:feelview/providers/app_providers.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/services/storage_service.dart';
import 'package:feelview/utils/narration_generator.dart';

const _kDraftCaption = 'draft_caption';
const _kDraftOccasion = 'draft_occasion';

const _occasions = <String>[
  'Birthday',
  'Graduation',
  'Holiday',
  'Everyday Moment',
  'Other',
];

class PostComposer extends ConsumerStatefulWidget {
  const PostComposer({super.key});

  @override
  ConsumerState<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends ConsumerState<PostComposer> {
  XFile? _pickedImage;
  final _captionCtrl = TextEditingController();
  final _customOccasionCtrl = TextEditingController();
  String? _occasion;
  List<MemberModel> _taggedMembers = [];
  final Map<String, String> _positionNotes = {};
  bool _isPosting = false;
  String _narrationPreview = '';
  List<MemberModel> _allMembers = [];

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _captionCtrl.addListener(_updateNarration);
    _customOccasionCtrl.addListener(_updateNarration);
    _loadMembers();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final caption = prefs.getString(_kDraftCaption) ?? '';
    final occasion = prefs.getString(_kDraftOccasion);
    if (mounted) {
      _captionCtrl.text = caption;
      setState(() => _occasion = occasion);
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDraftCaption, _captionCtrl.text);
    if (_occasion != null) {
      await prefs.setString(_kDraftOccasion, _occasion!);
    } else {
      await prefs.remove(_kDraftOccasion);
    }
  }

  Future<void> _loadMembers() async {
    final familyId = ref.read(activeFamilyIdProvider);
    if (familyId == null) return;
    final members = await FirestoreService.getFamilyMembers(familyId);
    if (mounted) setState(() => _allMembers = members);
  }

  void _updateNarration() {
    final profile = ref.read(activeProfileProvider);
    final caption = _captionCtrl.text;
    if (caption.isEmpty && _taggedMembers.isEmpty) {
      setState(() => _narrationPreview = '');
      return;
    }
    final effectiveOccasion = _occasion == 'Other'
        ? (_customOccasionCtrl.text.trim().isNotEmpty ? _customOccasionCtrl.text.trim() : 'Other')
        : _occasion;
    final narration = generateNarration(
      posterName: profile?.displayName ?? 'Someone',
      relationshipLabel: 'your family member',
      caption: caption,
      taggedNames: _taggedMembers.map((m) => m.displayName).toList(),
      occasion: effectiveOccasion,
    );
    setState(() => _narrationPreview = narration);
    _saveDraft();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _pickedImage = file);
  }

  void _showTagSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _allMembers.length,
          itemBuilder: (ctx, i) {
            final m = _allMembers[i];
            final tagged = _taggedMembers.any((t) => t.id == m.id);
            return CheckboxListTile(
              title: Text(m.displayName),
              subtitle: Text(m.fullName),
              value: tagged,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _taggedMembers = [..._taggedMembers, m];
                  } else {
                    _taggedMembers = _taggedMembers.where((t) => t.id != m.id).toList();
                    _positionNotes.remove(m.id);
                  }
                });
                _updateNarration();
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _post() async {
    if (_pickedImage == null && _captionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a photo or caption before posting.')),
      );
      return;
    }

    final profile = ref.read(activeProfileProvider);
    final familyId = ref.read(activeFamilyIdProvider);
    if (profile == null || familyId == null) return;

    setState(() => _isPosting = true);

    try {
      String? mediaUrl;
      if (_pickedImage != null) {
        final path =
            'families/$familyId/posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
        mediaUrl = await StorageService.uploadMedia(File(_pickedImage!.path), path);
      }

      final effectiveOccasion = _occasion == 'Other'
          ? (_customOccasionCtrl.text.trim().isNotEmpty ? _customOccasionCtrl.text.trim() : 'Other')
          : _occasion;

      final post = PostModel(
        id: '',
        authorId: profile.id,
        familyId: familyId,
        type: mediaUrl != null ? PostType.photo : PostType.text,
        caption: _captionCtrl.text.trim(),
        mediaUrl: mediaUrl,
        source: PostSource.native,
        occasion: effectiveOccasion,
        aiNarrationText: _narrationPreview,
        createdAt: DateTime.now(),
      );

      final postId = await FirestoreService.createPost(post);

      for (final member in _taggedMembers) {
        await FirestoreService.createPostTag(PostTagModel(
          id: '',
          postId: postId,
          taggedMemberId: member.id,
          positionNote: _positionNotes[member.id],
        ));
      }

      // Clear draft
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kDraftCaption);
      await prefs.remove(_kDraftOccasion);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _customOccasionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: _isPosting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Media picker ──────────────────────────────────────────
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                        style: BorderStyle.none,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_pickedImage!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.outline),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add a photo',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.outline),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Caption ───────────────────────────────────────────────
                TextField(
                  controller: _captionCtrl,
                  maxLines: null,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "What's happening?",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Occasion ──────────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: _occasion,
                  decoration: const InputDecoration(
                    labelText: 'Occasion (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('None')),
                    ..._occasions.map((o) =>
                        DropdownMenuItem(value: o, child: Text(o))),
                  ],
                  onChanged: (v) {
                    setState(() => _occasion = v);
                    _updateNarration();
                  },
                ),
                if (_occasion == 'Other') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customOccasionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Specify Custom Occasion',
                      hintText: 'e.g., Anniversary, Camping Trip, Reunion...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.celebration_rounded),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // ── Tag people ────────────────────────────────────────────
                Row(
                  children: [
                    const Text('Tag people',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showTagSheet,
                      icon: const Icon(Icons.person_add_rounded),
                      label: const Text('+ Tag a Person'),
                    ),
                  ],
                ),
                ..._taggedMembers.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Chip(
                            label: Text(m.displayName),
                            onDeleted: () {
                              setState(() {
                                _taggedMembers = _taggedMembers
                                    .where((t) => t.id != m.id)
                                    .toList();
                                _positionNotes.remove(m.id);
                              });
                              _updateNarration();
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Position note (e.g. on the left)',
                                isDense: true,
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              onChanged: (v) => _positionNotes[m.id] = v,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),

                // ── Narration preview ─────────────────────────────────────
                if (_narrationPreview.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'The elder will hear:',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _narrationPreview,
                          style: const TextStyle(
                              fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Post button ───────────────────────────────────────────
                AccessibleButton(
                  label: 'Post',
                  isLarge: true,
                  onPressed: _post,
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
