import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum AudioState { idle, loading, playing, done, error }

class AudioProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  AudioState _state = AudioState.idle;

  AudioState get state => _state;
  bool get isPlaying => _state == AudioState.playing;
  bool get isLoading => _state == AudioState.loading;
  bool get isDone => _state == AudioState.done;
  bool get hasError => _state == AudioState.error;

  AudioProvider() {
    _tts.setLanguage('en-IN');
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.1);

    _tts.setCompletionHandler(() {
      _state = AudioState.done;
      notifyListeners();
    });

    _tts.setErrorHandler((message) {
      _state = AudioState.error;
      notifyListeners();
    });
  }

  Future<void> speak(String text) async {
    if (_state == AudioState.playing) return;

    _state = AudioState.loading;
    notifyListeners();

    try {
      await _tts.speak(text);
      _state = AudioState.playing;
      notifyListeners();
    } catch (_) {
      _state = AudioState.error;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _state = AudioState.idle;
    notifyListeners();
  }

  void retry() {
    _state = AudioState.idle;
    notifyListeners();
  }

  void reset() {
    _tts.stop();
    _state = AudioState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
