/// Помилка, яка виникає при помилках у налаштуваннях.
///
/// `[msg]` - опис помилки.
/// `[solutionMsg]` - підказка для вирішення.
/// `[label]` - категорія помилки.
/// `[isPretty]` - чи форматувати повідомлення з емодзі.
class SettiError implements Error {
  const SettiError({
    required this.msg,
    this.solutionMsg = "",
    required this.label,
    this.isPretty = false,
    this.stackTrace,
  });

  final String msg;
  final String solutionMsg;
  final String label;

  final bool isPretty;

  @override
  final StackTrace? stackTrace;

  SettiError.withStackTrace({
    required this.msg,
    required this.label,
    this.solutionMsg = "",
    this.isPretty = false,
    StackTrace? stackTrace,
  }) : stackTrace = stackTrace ?? StackTrace.current;

  String prettifyMsg() {
    final solutionPart =
        solutionMsg.isNotEmpty ? "\n💡 Solution: $solutionMsg" : "";
    return "❌ $label: $msg\n$solutionPart";
  }

  @override
  String toString() {
    final stackPart = stackTrace != null ? "\nStackTrace: $stackTrace" : "";
    final solutionPart =
        solutionMsg.isNotEmpty ? "\nSolution: $solutionMsg" : "";
    return isPretty
        ? prettifyMsg() + stackPart
        : "$label: $msg $solutionPart $stackPart";
  }
}
