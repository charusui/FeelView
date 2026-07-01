import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/dev/seed_data.dart';
import 'package:feelview/main.dart';

/// The currently active test profile (drives Elder vs Poster mode).
final activeProfileProvider = StateProvider<MemberModel?>((ref) => null);

/// Current family ID (set when profile is selected).
final activeFamilyIdProvider = StateProvider<String?>((ref) => null);

/// Live family members — depends on [activeFamilyIdProvider].
final familyMembersProvider = StreamProvider<List<MemberModel>>((ref) {
  if (!useEmulator) return Stream.value(SeedData.sampleMembers);
  final familyId = ref.watch(activeFamilyIdProvider);
  if (familyId == null) return Stream.value(SeedData.sampleMembers);
  return FirestoreService.watchFamilyMembers(familyId)
      .handleError((_) => SeedData.sampleMembers)
      .map((list) => list.isEmpty ? SeedData.sampleMembers : list);
});

/// Core-circle members for the active elder profile.
final coreCircleMembersProvider = FutureProvider<List<MemberModel>>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return [];
  if (!useEmulator) {
    return SeedData.sampleMembers.where((m) => m.isCoreCircleFor.contains(profile.id)).toList();
  }
  final familyId = ref.watch(activeFamilyIdProvider);
  try {
    if (familyId != null) {
      final list = await FirestoreService.getCoreCircleMembers(familyId, profile.id);
      if (list.isNotEmpty) return list;
    }
  } catch (_) {}
  return SeedData.sampleMembers.where((m) => m.isCoreCircleFor.contains(profile.id)).toList();
});

/// Posts for a specific member — parameterized by memberId.
final memberPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, memberId) {
  if (!useEmulator) {
    return Stream.value(SeedData.samplePosts.where((p) => p.authorId == memberId).toList());
  }
  final familyId = ref.watch(activeFamilyIdProvider);
  if (familyId == null) {
    return Stream.value(SeedData.samplePosts.where((p) => p.authorId == memberId).toList());
  }
  return FirestoreService.watchMemberPosts(memberId, familyId)
      .handleError((_) => SeedData.samplePosts.where((p) => p.authorId == memberId).toList())
      .map((list) {
        if (list.isEmpty) {
          return SeedData.samplePosts.where((p) => p.authorId == memberId).toList();
        }
        return list;
      });
});

/// All posts across the entire active family.
final familyPostsProvider = StreamProvider<List<PostModel>>((ref) {
  final familyId = ref.watch(activeFamilyIdProvider);
  if (!useEmulator || familyId == null) {
    final list = List<PostModel>.from(SeedData.samplePosts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Stream.value(list);
  }
  return FirestoreService.watchFamilyPosts(familyId)
      .handleError((_) {
        final list = List<PostModel>.from(SeedData.samplePosts)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      })
      .map((list) {
        if (list.isEmpty) {
          final fallback = List<PostModel>.from(SeedData.samplePosts)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return fallback;
        }
        return list;
      });
});

/// Chat threads visible to the current user.
final chatThreadsProvider = StreamProvider<List<ChatThreadModel>>((ref) {
  if (!useEmulator) return Stream.value(SeedData.sampleThreads);
  final profile = ref.watch(activeProfileProvider);
  final familyId = ref.watch(activeFamilyIdProvider);
  if (profile == null || familyId == null) return Stream.value(SeedData.sampleThreads);
  return FirestoreService.watchUserThreads(profile.id, familyId)
      .handleError((_) => SeedData.sampleThreads)
      .map((list) => list.isEmpty ? SeedData.sampleThreads : list);
});

/// Messages in a thread — parameterized by threadId, ordered oldest-first.
final messagesProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, threadId) {
  if (!useEmulator) return Stream.value(SeedData.getSampleMessages(threadId));
  return FirestoreService.watchMessages(threadId)
      .handleError((_) => SeedData.getSampleMessages(threadId))
      .map((list) => list.isEmpty ? SeedData.getSampleMessages(threadId) : list);
});

/// App-wide text scaling factor (e.g. 1.0 = 100%, 1.25 = 125%, etc.)
final textScaleProvider = StateProvider<double>((ref) => 1.0);

/// Whether "Simplify Further" (ultra-minimal elder mode) is enabled.
final simplifyFurtherProvider = StateProvider<bool>((ref) => false);
