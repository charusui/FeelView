import 'package:flutter_test/flutter_test.dart';
import 'package:feelview/utils/narration_generator.dart';
import 'package:feelview/models/models.dart';

void main() {
  group('generateNarration', () {
    test('basic: name + caption, no occasion, no tags', () {
      final text = generateNarration(
        posterName: 'David',
        relationshipLabel: 'your grandson',
        caption: 'Had a great day at the park!',
        taggedNames: [],
      );
      expect(text, contains('your grandson David'));
      expect(text, contains('Had a great day at the park!'));
      expect(text, isNot(contains('also in this photo')));
    });

    test('with occasion', () {
      final text = generateNarration(
        posterName: 'Maria',
        relationshipLabel: 'your granddaughter',
        caption: 'Look at this cake!',
        taggedNames: [],
        occasion: 'Birthday',
      );
      expect(text, contains('Birthday photo'));
      expect(text, contains('your granddaughter Maria'));
    });

    test('single tagged person', () {
      final text = generateNarration(
        posterName: 'David',
        relationshipLabel: 'your grandson',
        caption: '',
        taggedNames: ['Uncle Tony'],
      );
      expect(text, contains('Uncle Tony is also in this photo'));
    });

    test('multiple tagged people joined correctly', () {
      final text = generateNarration(
        posterName: 'David',
        relationshipLabel: 'your grandson',
        caption: '',
        taggedNames: ['Maria', 'Carlos', 'Elena'],
      );
      expect(text, contains('Maria, Carlos and Elena are also in this photo'));
    });

    test('empty caption skipped gracefully', () {
      final text = generateNarration(
        posterName: 'Rosa',
        relationshipLabel: 'your daughter',
        caption: '',
        taggedNames: [],
      );
      expect(text, isNot(contains('says:')));
    });
  });

  group('answerWhoIsBeside', () {
    final tagA = PostTagModel(
      id: 't1', postId: 'p1', taggedMemberId: 'm1',
      positionNote: 'on the left next to the tree',
    );
    final tagB = PostTagModel(
      id: 't2', postId: 'p1', taggedMemberId: 'm2',
      positionNote: 'beside Ivan, wearing red',
    );

    final memberA = MemberModel(
      id: 'm1', familyId: 'f1', fullName: 'Anna Alvarez',
      displayName: 'Anna', role: UserRole.poster,
      relationshipLabelFromElder: const {}, isMinor: false,
      voicePronunciationHint: '',
      treePosition: const TreePosition(generation: 2, order: 0),
      isCoreCircleFor: const [], createdAt: DateTime(2024),
    );
    final memberB = MemberModel(
      id: 'm2', familyId: 'f1', fullName: 'Ivan Garcia',
      displayName: 'Ivan', role: UserRole.poster,
      relationshipLabelFromElder: const {}, isMinor: false,
      voicePronunciationHint: '',
      treePosition: const TreePosition(generation: 2, order: 1),
      isCoreCircleFor: const [], createdAt: DateTime(2024),
    );

    test('finds answer when name appears in positionNote', () {
      final answer = answerWhoIsBeside(
        askedAboutName: 'Ivan',
        tags: [tagA, tagB],
        members: [memberA, memberB],
      );
      expect(answer, isNotNull);
      expect(answer, contains('Ivan'));
    });

    test('returns null when name not found in any note', () {
      final answer = answerWhoIsBeside(
        askedAboutName: 'Zara',
        tags: [tagA, tagB],
        members: [memberA, memberB],
      );
      expect(answer, isNull);
    });

    test('case insensitive search in notes', () {
      final answer = answerWhoIsBeside(
        askedAboutName: 'IVAN',
        tags: [tagA, tagB],
        members: [memberA, memberB],
      );
      expect(answer, isNotNull);
    });
  });
}
