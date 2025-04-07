/// Виняток, який виникає при винятках у налаштуваннях.
///
/// `[msg]` - опис винятку.
/// `[solutionMsg]` - підказка для вирішення.
/// `[label]` - категорія винятку.
/// `[isPretty]` - чи форматувати повідомлення з емодзі.
class SettiException implements Exception {
  const SettiException({
    required this.msg,
    required this.label,
    this.solutionMsg = "",
    this.isPretty = false,
    this.stackTrace,
  });

  final String msg;
  final String solutionMsg;
  final String label;

  final bool isPretty;

  final StackTrace? stackTrace;

  SettiException.withStackTrace({
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
