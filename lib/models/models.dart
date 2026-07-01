import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum UserRole { elder, poster, admin }
enum PostType { photo, video, text }
enum PostSource { native, instagram, facebook, tiktok, other }
enum MinorPermissionTier { supervised, trusted }

// ─── TreePosition ─────────────────────────────────────────────────────────────

class TreePosition {
  final int generation;
  final int order;

  const TreePosition({required this.generation, required this.order});

  factory TreePosition.fromMap(Map<String, dynamic> m) =>
      TreePosition(generation: (m['generation'] as num).toInt(), order: (m['order'] as num).toInt());

  Map<String, dynamic> toMap() => {'generation': generation, 'order': order};
}

// ─── FamilyModel ──────────────────────────────────────────────────────────────

class FamilyModel {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  factory FamilyModel.fromMap(String id, Map<String, dynamic> d) => FamilyModel(
        id: id,
        name: d['name'] as String,
        createdBy: d['createdBy'] as String,
        createdAt: (d['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// ─── MemberModel ──────────────────────────────────────────────────────────────

class MemberModel {
  final String id;
  final String familyId;
  final String fullName;
  final String displayName;
  final UserRole role;
  final Map<String, String> relationshipLabelFromElder; // elderId → label
  final DateTime? dateOfBirth;
  final bool isMinor;
  final String? guardianUserId;
  final MinorPermissionTier? minorPermissionTier;
  final String? profilePhotoUrl;
  final String voicePronunciationHint;
  final TreePosition treePosition;
  final List<String> isCoreCircleFor; // list of elder userIds
  final String? familyBranchLabel;
  final DateTime createdAt;

  const MemberModel({
    required this.id,
    required this.familyId,
    required this.fullName,
    required this.displayName,
    required this.role,
    required this.relationshipLabelFromElder,
    this.dateOfBirth,
    required this.isMinor,
    this.guardianUserId,
    this.minorPermissionTier,
    this.profilePhotoUrl,
    required this.voicePronunciationHint,
    required this.treePosition,
    required this.isCoreCircleFor,
    this.familyBranchLabel,
    required this.createdAt,
  });

  factory MemberModel.fromMap(String id, Map<String, dynamic> d) => MemberModel(
        id: id,
        familyId: d['familyId'] as String,
        fullName: d['fullName'] as String,
        displayName: d['displayName'] as String,
        role: UserRole.values.byName(d['role'] as String),
        relationshipLabelFromElder: Map<String, String>.from(
            (d['relationshipLabelFromElder'] as Map<String, dynamic>? ?? {})),
        dateOfBirth: d['dateOfBirth'] != null
            ? (d['dateOfBirth'] as Timestamp).toDate()
            : null,
        isMinor: d['isMinor'] as bool? ?? false,
        guardianUserId: d['guardianUserId'] as String?,
        minorPermissionTier: d['minorPermissionTier'] != null
            ? MinorPermissionTier.values.byName(d['minorPermissionTier'] as String)
            : null,
        profilePhotoUrl: d['profilePhotoUrl'] as String?,
        voicePronunciationHint: d['voicePronunciationHint'] as String? ?? '',
        treePosition: TreePosition.fromMap(
            (d['treePosition'] as Map<String, dynamic>?) ?? {'generation': 0, 'order': 0}),
        isCoreCircleFor: List<String>.from(d['isCoreCircleFor'] as List? ?? []),
        familyBranchLabel: d['familyBranchLabel'] as String?,
        createdAt: (d['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
        'familyId': familyId,
        'fullName': fullName,
        'displayName': displayName,
        'role': role.name,
        'relationshipLabelFromElder': relationshipLabelFromElder,
        if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
        'isMinor': isMinor,
        if (guardianUserId != null) 'guardianUserId': guardianUserId,
        if (minorPermissionTier != null) 'minorPermissionTier': minorPermissionTier!.name,
        if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
        'voicePronunciationHint': voicePronunciationHint,
        'treePosition': treePosition.toMap(),
        'isCoreCircleFor': isCoreCircleFor,
        if (familyBranchLabel != null) 'familyBranchLabel': familyBranchLabel,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// ─── UserModel ────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String authUid;
  final String loginType;
  final List<String> familyIds;

  const UserModel({
    required this.id,
    required this.authUid,
    required this.loginType,
    required this.familyIds,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> d) => UserModel(
        id: id,
        authUid: d['authUid'] as String,
        loginType: d['loginType'] as String,
        familyIds: List<String>.from(d['familyIds'] as List? ?? []),
      );

  Map<String, dynamic> toMap() => {
        'authUid': authUid,
        'loginType': loginType,
        'familyIds': familyIds,
      };
}

// ─── PostModel ────────────────────────────────────────────────────────────────

class PostModel {
  final String id;
  final String authorId;
  final String familyId;
  final PostType type;
  final String caption;
  final String? mediaUrl;
  final PostSource source;
  final String? occasion;
  final String aiNarrationText;
  final DateTime createdAt;
  final DateTime? editedAt;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.familyId,
    required this.type,
    required this.caption,
    this.mediaUrl,
    required this.source,
    this.occasion,
    required this.aiNarrationText,
    required this.createdAt,
    this.editedAt,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> d) => PostModel(
        id: id,
        authorId: d['authorId'] as String,
        familyId: d['familyId'] as String,
        type: PostType.values.byName(d['type'] as String),
        caption: d['caption'] as String? ?? '',
        mediaUrl: d['mediaUrl'] as String?,
        source: PostSource.values.byName(d['source'] as String? ?? 'native'),
        occasion: d['occasion'] as String?,
        aiNarrationText: d['aiNarrationText'] as String? ?? '',
        createdAt: (d['createdAt'] as Timestamp).toDate(),
        editedAt: d['editedAt'] != null ? (d['editedAt'] as Timestamp).toDate() : null,
      );

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'familyId': familyId,
        'type': type.name,
        'caption': caption,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
        'source': source.name,
        if (occasion != null) 'occasion': occasion,
        'aiNarrationText': aiNarrationText,
        'createdAt': Timestamp.fromDate(createdAt),
        if (editedAt != null) 'editedAt': Timestamp.fromDate(editedAt!),
      };
}

// ─── PostTagModel ─────────────────────────────────────────────────────────────

class PostTagModel {
  final String id;
  final String postId;
  final String taggedMemberId;
  final String? positionNote;

  const PostTagModel({
    required this.id,
    required this.postId,
    required this.taggedMemberId,
    this.positionNote,
  });

  factory PostTagModel.fromMap(String id, Map<String, dynamic> d) => PostTagModel(
        id: id,
        postId: d['postId'] as String,
        taggedMemberId: d['taggedMemberId'] as String,
        positionNote: d['positionNote'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'postId': postId,
        'taggedMemberId': taggedMemberId,
        if (positionNote != null) 'positionNote': positionNote,
      };
}

// ─── ChatThreadModel ──────────────────────────────────────────────────────────

class ChatThreadModel {
  final String id;
  final String familyId;
  final bool isGroup;
  final List<String> participantIds;
  final String? title;
  final String? lastMessagePreview;
  final DateTime? lastMessageTimestamp;

  const ChatThreadModel({
    required this.id,
    required this.familyId,
    required this.isGroup,
    required this.participantIds,
    this.title,
    this.lastMessagePreview,
    this.lastMessageTimestamp,
  });

  factory ChatThreadModel.fromMap(String id, Map<String, dynamic> d) => ChatThreadModel(
        id: id,
        familyId: d['familyId'] as String,
        isGroup: d['isGroup'] as bool? ?? false,
        participantIds: List<String>.from(d['participantIds'] as List? ?? []),
        title: d['title'] as String?,
        lastMessagePreview: d['lastMessagePreview'] as String?,
        lastMessageTimestamp: d['lastMessageTimestamp'] != null ? (d['lastMessageTimestamp'] as Timestamp).toDate() : null,
      );

  Map<String, dynamic> toMap() => {
        'familyId': familyId,
        'isGroup': isGroup,
        'participantIds': participantIds,
        if (title != null) 'title': title,
        if (lastMessagePreview != null) 'lastMessagePreview': lastMessagePreview,
        if (lastMessageTimestamp != null) 'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp!),
      };
}

// ─── ChatMessageModel ─────────────────────────────────────────────────────────

class ChatMessageModel {
  final String id;
  final String threadId;
  final String senderId;
  final String content;
  final String? voiceNoteUrl;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.content,
    this.voiceNoteUrl,
    required this.createdAt,
  });

  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> d) => ChatMessageModel(
        id: id,
        threadId: d['threadId'] as String,
        senderId: d['senderId'] as String,
        content: d['content'] as String? ?? '',
        voiceNoteUrl: d['voiceNoteUrl'] as String?,
        createdAt: (d['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
        'threadId': threadId,
        'senderId': senderId,
        'content': content,
        if (voiceNoteUrl != null) 'voiceNoteUrl': voiceNoteUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

extension TitleCaseExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}

extension MemberRelationshipExtension on MemberModel {
  String getRelationshipTitleCase(String? elderId) {
    if (elderId == null) return '';
    final raw = relationshipLabelFromElder[elderId] ?? '';
    return raw.toTitleCase();
  }
}
