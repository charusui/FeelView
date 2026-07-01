import 'dart:math' show min;
import 'package:feelview/models/models.dart';

/// Finds matching family members by spoken name.
/// Returns list sorted by match confidence (best first).
List<MemberModel> findMatches(String query, List<MemberModel> members) {
  final q = _normalize(query);
  if (q.isEmpty) return [];

  final scored = <({MemberModel member, int score})>[];
  for (final m in members) {
    final names = [
      _normalize(m.fullName),
      _normalize(m.displayName),
      if (m.voicePronunciationHint.isNotEmpty) _normalize(m.voicePronunciationHint),
    ];
    int best = 999;
    for (final name in names) {
      if (name == q) {
        best = 0;
        break;
      }
      if (name.contains(q) || q.contains(name)) {
        best = min(best, 1);
        continue;
      }
      final d = _levenshtein(q, name);
      best = min(best, d);
    }
    // Allow up to 2 edits for short names, 3 for longer ones.
    final threshold = q.length <= 4 ? 2 : 3;
    if (best <= threshold) scored.add((member: m, score: best));
  }
  scored.sort((a, b) => a.score.compareTo(b.score));
  return scored.map((e) => e.member).toList();
}

String _normalize(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').trim();

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final dp = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
  for (int i = 0; i <= a.length; i++) dp[i][0] = i;
  for (int j = 0; j <= b.length; j++) dp[0][j] = j;
  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      dp[i][j] = a[i - 1] == b[j - 1]
          ? dp[i - 1][j - 1]
          : 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce(min);
    }
  }
  return dp[a.length][b.length];
}
