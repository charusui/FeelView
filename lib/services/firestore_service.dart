import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/main.dart';
import 'package:feelview/dev/seed_data.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static const _uuid = Uuid();

  // ─── Collections ──────────────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> _members(String familyId) =>
      _db.collection('families').doc(familyId).collection('members');

  static CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  static CollectionReference<Map<String, dynamic>> _tags(String postId) =>
      _db.collection('posts').doc(postId).collection('tags');

  static CollectionReference<Map<String, dynamic>> get _threads =>
      _db.collection('chatThreads');

  static CollectionReference<Map<String, dynamic>> _messages(String threadId) =>
      _db.collection('chatThreads').doc(threadId).collection('messages');

  // ─── Members ──────────────────────────────────────────────────────────────

  static Stream<List<MemberModel>> watchFamilyMembers(String familyId) {
    if (!useEmulator) return Stream.value(SeedData.sampleMembers);
    return _members(familyId).snapshots().map((s) =>
        s.docs.map((d) => MemberModel.fromMap(d.id, d.data())).toList());
  }

  static Future<List<MemberModel>> getFamilyMembers(String familyId) async {
    if (!useEmulator) return SeedData.sampleMembers;
    try {
      final snap = await _members(familyId).get();
      return snap.docs.map((d) => MemberModel.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return SeedData.sampleMembers;
    }
  }

  static Future<List<MemberModel>> getCoreCircleMembers(
      String familyId, String elderUserId) async {
    if (!useEmulator) {
      return SeedData.sampleMembers
          .where((m) => m.isCoreCircleFor.contains(elderUserId))
          .toList();
    }
    try {
      final snap = await _members(familyId)
          .where('isCoreCircleFor', arrayContains: elderUserId)
          .get();
      return snap.docs.map((d) => MemberModel.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return SeedData.sampleMembers
          .where((m) => m.isCoreCircleFor.contains(elderUserId))
          .toList();
    }
  }

  // ─── Posts ────────────────────────────────────────────────────────────────

  static Stream<List<PostModel>> watchMemberPosts(
          String authorId, String familyId) {
    if (!useEmulator) {
      return Stream.value(
          SeedData.samplePosts.where((p) => p.authorId == authorId).toList());
    }
    return _posts
        .where('authorId', isEqualTo: authorId)
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => PostModel.fromMap(d.id, d.data())).toList());
  }

  static Stream<List<PostModel>> watchFamilyPosts(String familyId) {
    if (!useEmulator) {
      final list = SeedData.samplePosts.where((p) => p.familyId == familyId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Stream.value(list);
    }
    return _posts
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => PostModel.fromMap(d.id, d.data())).toList());
  }

  static Future<String> createPost(PostModel post) async {
    final id = _uuid.v4();
    try {
      await _posts.doc(id).set(post.toMap());
    } catch (_) {}
    return id;
  }

  static Future<void> updatePost(PostModel post) async {
    try {
      await _posts.doc(post.id).update(post.toMap());
    } catch (_) {}
  }

  static Future<void> deletePost(String postId) async {
    try {
      await _posts.doc(postId).delete();
    } catch (_) {}
  }

  // ─── Post Tags ────────────────────────────────────────────────────────────

  static Future<List<PostTagModel>> getPostTags(String postId) async {
    try {
      final snap = await _tags(postId).get();
      return snap.docs.map((d) => PostTagModel.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> createPostTag(PostTagModel tag) async {
    final id = _uuid.v4();
    try {
      await _tags(tag.postId).doc(id).set(tag.toMap());
    } catch (_) {}
  }

  // ─── Chat Threads ─────────────────────────────────────────────────────────

  static Stream<List<ChatThreadModel>> watchUserThreads(
          String userId, String familyId) {
    if (!useEmulator) return Stream.value(SeedData.sampleThreads);
    return _threads
        .where('familyId', isEqualTo: familyId)
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ChatThreadModel.fromMap(d.id, d.data()))
            .toList());
  }

  static Future<ChatThreadModel?> getOrCreateDirectThread(
      String familyId, String userA, String userB) async {
    final participants = ([userA, userB]..sort());
    if (!useEmulator) {
      final existing = SeedData.sampleThreads.where((t) =>
          !t.isGroup &&
          t.participantIds.length == 2 &&
          t.participantIds.contains(userA) &&
          t.participantIds.contains(userB)).firstOrNull;
      if (existing != null) return existing;

      final otherUser = userA == 'member-rosa' ? userB : (userB == 'member-rosa' ? userA : userB);
      final otherMember = SeedData.sampleMembers.where((m) => m.id == otherUser).firstOrNull;
      final name = otherMember?.displayName ?? 'Family Member';
      final threadId = 'thread-${otherUser.replaceAll('member-', '')}';
      return ChatThreadModel(
        id: threadId,
        familyId: familyId,
        isGroup: false,
        title: '$name & Grandma Rosa ',
        participantIds: participants,
        lastMessagePreview: '$name: Hello! So great chatting with you!',
        lastMessageTimestamp: DateTime.now(),
      );
    }
    try {
      final snap = await _threads
          .where('familyId', isEqualTo: familyId)
          .where('isGroup', isEqualTo: false)
          .where('participantIds', isEqualTo: participants)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final d = snap.docs.first;
        return ChatThreadModel.fromMap(d.id, d.data());
      }

      final id = _uuid.v4();
      final thread = ChatThreadModel(
        id: id,
        familyId: familyId,
        isGroup: false,
        participantIds: participants,
      );
      await _threads.doc(id).set(thread.toMap());
      return thread;
    } catch (_) {
      final existing = SeedData.sampleThreads.where((t) =>
          !t.isGroup &&
          t.participantIds.length == 2 &&
          t.participantIds.contains(userA) &&
          t.participantIds.contains(userB)).firstOrNull;
      if (existing != null) return existing;

      final otherUser = userA == 'member-rosa' ? userB : (userB == 'member-rosa' ? userA : userB);
      final otherMember = SeedData.sampleMembers.where((m) => m.id == otherUser).firstOrNull;
      final name = otherMember?.displayName ?? 'Family Member';
      final threadId = 'thread-${otherUser.replaceAll('member-', '')}';
      return ChatThreadModel(
        id: threadId,
        familyId: familyId,
        isGroup: false,
        title: '$name & Grandma Rosa ',
        participantIds: participants,
        lastMessagePreview: '$name: Hello! So great chatting with you!',
        lastMessageTimestamp: DateTime.now(),
      );
    }
  }

  // ─── Messages ─────────────────────────────────────────────────────────────

  static Stream<List<ChatMessageModel>> watchMessages(String threadId) {
    if (!useEmulator) return Stream.value(SeedData.getSampleMessages(threadId));
    return _messages(threadId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ChatMessageModel.fromMap(d.id, d.data()))
            .toList());
  }

  static Future<void> sendMessage(ChatMessageModel message) async {
    final id = _uuid.v4();
    try {
      await _messages(message.threadId).doc(id).set(message.toMap());
    } catch (_) {}
  }
}
