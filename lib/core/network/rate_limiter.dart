import 'dart:async';
import 'dart:math';

/// Rate limiter to control API request frequency
/// Replicates chaoxing_py RateLimiter behavior
class RateLimiter {
  RateLimiter(this.callInterval);
  
  final Duration callInterval;
  DateTime _lastCall = DateTime.now();
  final _lock = Completer<void>()..complete();

  /// Limit rate of API calls
  /// Replicates chaoxing_py limit_rate method
  Future<void> limitRate({
    bool randomTime = false,
    double randomMin = 0.0,
    double randomMax = 1.0,
  }) async {
    // Wait for previous call to complete
    await _lock.future;
    
    final completer = Completer<void>();
    
    try {
      if (randomTime) {
        final random = Random();
        final waitTime = randomMin + random.nextDouble() * (randomMax - randomMin);
        await Future.delayed(Duration(milliseconds: (waitTime * 1000).toInt()));
      }
      
      final now = DateTime.now();
      final timeElapsed = now.difference(_lastCall);
      
      if (timeElapsed <= callInterval) {
        await Future.delayed(callInterval - timeElapsed);
        _lastCall = DateTime.now();
      } else {
        _lastCall = now;
      }
    } finally {
      completer.complete();
    }
    
    return completer.future;
  }
}
