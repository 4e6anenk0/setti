/// Помилка, яка виникає при помилках у налаштуваннях.
///
/// `[msg]` - опис помилки.
/// `[solutionMsg]` - підказка для вирішення.
/// `[label]` - категорія помилки.
class SettiError implements Error {
  const SettiError({
    required this.msg,
    this.solutionMsg = "",
    required this.label,
    this.stackTrace,
  });

  final String msg;
  final String solutionMsg;
  final String label;

  @override
  final StackTrace? stackTrace;

  SettiError.withStackTrace({
    required this.msg,
    required this.label,
    this.solutionMsg = "",
    StackTrace? stackTrace,
  }) : stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    final stackPart = stackTrace != null ? "\nStackTrace: $stackTrace" : "";
    final solutionPart =
        solutionMsg.isNotEmpty ? "\nSolution: $solutionMsg" : "";
    return "$label: $msg $solutionPart $stackPart";
  }
}
