/// Увага, для виводу у логи.
///
/// `[msg]` - опис уваги.
/// `[solutionMsg]` - підказка для вирішення.
/// `[label]` - категорія.
/// `[isPretty]` - чи форматувати повідомлення з емодзі.
class SettiWarning {
  const SettiWarning({
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

  final StackTrace? stackTrace;

  SettiWarning.withStackTrace({
    required this.msg,
    required this.label,
    this.solutionMsg = "",
    this.isPretty = false,
    StackTrace? stackTrace,
  }) : stackTrace = stackTrace ?? StackTrace.current;

  String prettifyMsg() {
    final solutionPart =
        solutionMsg.isNotEmpty ? "\n💡 Solution: $solutionMsg" : "";
    return "🚨 $label: $msg\n$solutionPart";
  }

  @override
  String toString() {
    final stackPart = stackTrace != null ? "\nStackTrace: $stackTrace" : "";
    final solutionPart =
        solutionMsg.isNotEmpty ? "\nSolution: $solutionMsg" : "";
    return isPretty
        ? prettifyMsg() + stackPart
        : "$label: $msg $solutionPart $stackTrace";
  }
}
