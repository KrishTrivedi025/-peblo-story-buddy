import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';

enum QuizState { hidden, visible, wrong, correct }

class QuizProvider extends ChangeNotifier {
  static final List<QuizQuestion> _questions = [
    QuizQuestion.fromJson({
      'question': 'What colour was Peblo the Robot\'s lost bag?',
      'options': ['Red', 'Green', 'Blue', 'Yellow'],
      'answer': 'Yellow',
    }),
    QuizQuestion.fromJson({
      'question': 'What is the name of the robot?',
      'options': ['Raga', 'Masti', 'Peblo', 'Vidya'],
      'answer': 'Peblo',
    }),
  ];

  int _currentIndex = 0;
  QuizState _state = QuizState.hidden;
  String? _selectedAnswer;

  QuizState get state => _state;
  String? get selectedAnswer => _selectedAnswer;
  bool get isVisible => _state != QuizState.hidden;
  bool get isCorrect => _state == QuizState.correct;
  bool get isWrong => _state == QuizState.wrong;
  QuizQuestion get question => _questions[_currentIndex];
  int get currentIndex => _currentIndex;
  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  void reveal() {
    _currentIndex = 0;
    _state = QuizState.visible;
    _selectedAnswer = null;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (_state == QuizState.correct) return;
    _selectedAnswer = answer;
    _state = answer == question.answer ? QuizState.correct : QuizState.wrong;
    notifyListeners();
  }

  void resetWrong() {
    if (_state == QuizState.wrong) {
      _state = QuizState.visible;
      _selectedAnswer = null;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _state = QuizState.visible;
      _selectedAnswer = null;
      notifyListeners();
    }
  }

  void reset() {
    _currentIndex = 0;
    _state = QuizState.hidden;
    _selectedAnswer = null;
    notifyListeners();
  }
}
