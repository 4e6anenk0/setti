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
    this.stackTrace,
  });

  final String msg;
  final String solutionMsg;
  final String label;

  final StackTrace? stackTrace;

  SettiWarning.withStackTrace({
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
