/// Simple Result wrapper for safe execution and error handling.
class Result<T> {
  final T? value;
  final Object? error;
  final StackTrace? stackTrace;

  const Result._({this.value, this.error, this.stackTrace});

  bool get isOk => error == null;
  bool get isErr => error != null;

  static Result<T> ok<T>(T value) => Result._(value: value);
  static Result<T> err<T>(Object error, [StackTrace? st]) =>
      Result._(error: error, stackTrace: st);

  static Result<T> tryRun<T>(T Function() fn) {
    try {
      return Result.ok(fn());
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  static Future<Result<T>> tryRunAsync<T>(Future<T> Function() fn) async {
    try {
      final v = await fn();
      return Result.ok(v);
    } catch (e, st) {
      return Result.err(e, st);
    }
  }
}
