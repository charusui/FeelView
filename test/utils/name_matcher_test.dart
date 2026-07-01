import 'package:flutter_test/flutter_test.dart';
import 'package:feelview/utils/name_matcher.dart';
import 'package:feelview/models/models.dart';

// Minimal stub members for testing
MemberModel _member(String id, String full, String display, [String hint = '']) =>
    MemberModel(
      id: id,
      familyId: 'fam1',
      fullName: full,
      displayName: display,
      role: UserRole.poster,
      relationshipLabelFromElder: const {},
      isMinor: false,
      voicePronunciationHint: hint,
      treePosition: const TreePosition(generation: 1, order: 0),
      isCoreCircleFor: const [],
      createdAt: DateTime(2024),
    );

void main() {
  final members = [
    _member('1', 'John Smith', 'John', 'Johnny'),
    _member('2', 'Maria Garcia', 'Maria'),
    _member('3', 'David Alvarez', 'David'),
    _member('4', 'Jonathan Lee', 'Jonathan'),
    _member('5', 'Rosa Alvarez', 'Grandma Rosa'),
  ];

  test('exact match on displayName returns first', () {
    final results = findMatches('Maria', members);
    expect(results.first.id, '2');
  });

  test('exact match on fullName', () {
    final results = findMatches('David Alvarez', members);
    expect(results.first.id, '3');
  });

  test('pronunciation hint match', () {
    final results = findMatches('Johnny', members);
    expect(results.map((m) => m.id), contains('1'));
  });

  test('fuzzy match handles one typo: Jon -> John', () {
    final results = findMatches('Jon', members);
    expect(results.map((m) => m.id), contains('1'));
  });

  test('returns empty for no match', () {
    final results = findMatches('Zxylophone', members);
    expect(results, isEmpty);
  });

  test('returns multiple when ambiguous: John vs Jonathan', () {
    final results = findMatches('John', members);
    expect(results.length, greaterThan(1));
    // John should rank above Jonathan (exact substring)
    expect(results.first.displayName, 'John');
  });

  test('empty query returns empty', () {
    expect(findMatches('', members), isEmpty);
  });

  test('case insensitive', () {
    final results = findMatches('MARIA', members);
    expect(results.first.id, '2');
  });

  test('handles punctuation in query', () {
    final results = findMatches("David!", members);
    expect(results.first.id, '3');
  });

  test('grandma rosa matches on partial display name', () {
    final results = findMatches('Rosa', members);
    expect(results.map((m) => m.id), contains('5'));
  });
}
