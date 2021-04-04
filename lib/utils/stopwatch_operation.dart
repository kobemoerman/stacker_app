class StudyTimer {
  final Stopwatch _stopWatch = Stopwatch();
  Duration _initialOffset;

  StudyTimer({Duration initialOffset = Duration.zero})
      : _initialOffset = initialOffset;

  start() => _stopWatch.start();

  stop() => _stopWatch.stop();

  reset({Duration newInitialOffset}) {
    _stopWatch.reset();
    _initialOffset = newInitialOffset ?? _initialOffset;
  }

  set initialOffset(ms) => _initialOffset = Duration(milliseconds: ms);
  bool get isInitialised => _initialOffset != Duration.zero;
  Duration get elapsed => _stopWatch.elapsed + _initialOffset;
  int get getMilliseconds =>
      (_stopWatch.elapsedMilliseconds ?? 0) + _initialOffset.inMilliseconds;
}
