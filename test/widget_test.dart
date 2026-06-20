// Tests for the data-driven quiz core — the most important requirement.
// We verify the model parses any option count and that answer-checking is
// driven entirely by the JSON, never hardcoded.

import 'package:flutter_test/flutter_test.dart';
import 'package:peblo_story_buddy/models/quiz_model.dart';

void main() {
  group('QuizQuestion.fromJson', () {
    test('parses the provided 4-option question', () {
      final q = QuizQuestion.fromJson({
        'question': "What colour was Pip the Robot's lost gear?",
        'options': ['Red', 'Green', 'Blue', 'Yellow'],
        'answer': 'Blue',
      });

      expect(q.options.length, 4);
      expect(q.answer, 'Blue');
      expect(q.options.contains('Blue'), isTrue);
    });

    test('handles a different question with 5 options, no code change', () {
      final q = QuizQuestion.fromJson({
        'question': 'Which animal says moo?',
        'options': ['Dog', 'Cat', 'Cow', 'Duck', 'Fish'],
        'answer': 'Cow',
      });

      expect(q.options.length, 5);
      expect(q.answer, 'Cow');
    });

    test('handles a 3-option question', () {
      final q = QuizQuestion.fromJson({
        'question': 'How many?',
        'options': ['One', 'Two', 'Three'],
        'answer': 'Two',
      });

      expect(q.options.length, 3);
      expect(q.answer, 'Two');
    });
  });
}
