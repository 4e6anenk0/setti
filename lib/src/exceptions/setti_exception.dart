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
    this.stackTrace,
  });

  final String msg;
  final String solutionMsg;
  final String label;

  final StackTrace? stackTrace;

  SettiException.withStackTrace({
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
