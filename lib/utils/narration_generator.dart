import 'package:feelview/models/models.dart';

/// Generates AI narration text for a post, relative to a specific viewer (the elder).
/// All inputs are plain strings — caller resolves relationship labels before calling.
String generateNarration({
  required String posterName,
  required String relationshipLabel, // e.g. "your grandson"
  required String caption,
  required List<String> taggedNames, // display names of tagged people
  String? occasion,
}) {
  final buffer = StringBuffer();

  // Opening line.
  if (occasion != null && occasion.isNotEmpty) {
    buffer.write('Here is a $occasion photo from $relationshipLabel $posterName. ');
  } else {
    buffer.write('Here is a photo from $relationshipLabel $posterName. ');
  }

  // Caption.
  if (caption.isNotEmpty) {
    buffer.write('$posterName says: $caption ');
  }

  // Tagged people.
  if (taggedNames.isNotEmpty) {
    if (taggedNames.length == 1) {
      buffer.write('${taggedNames[0]} is also in this photo.');
    } else {
      final last = taggedNames.last;
      final others = taggedNames.sublist(0, taggedNames.length - 1).join(', ');
      buffer.write('$others and $last are also in this photo.');
    }
  }

  return buffer.toString().trim();
}

/// Answers a "who is beside X?" question from tag position notes.
/// Returns null if no matching note is found — caller should prompt the poster to add it.
String? answerWhoIsBeside({
  required String askedAboutName,
  required List<PostTagModel> tags,
  required List<MemberModel> members,
}) {
  final normalizedQuery = askedAboutName.toLowerCase();
  for (final tag in tags) {
    final note = (tag.positionNote ?? '').toLowerCase();
    if (note.contains(normalizedQuery)) {
      final member = members.firstWhere(
        (m) => m.id == tag.taggedMemberId,
        orElse: () => throw StateError('Tagged member ${tag.taggedMemberId} not found in member list'),
      );
      return 'According to the photo notes, ${member.displayName} is ${tag.positionNote}.';
    }
  }
  return null;
}
