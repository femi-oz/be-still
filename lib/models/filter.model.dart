import 'package:be_still/enums/status.dart';

class FilterType {
  final status;
  final isAnswered;
  final isArchived;
  final isSnoozed;

  const FilterType({
    this.status = Status.active,
    this.isAnswered = false,
    this.isArchived = false,
    this.isSnoozed = false,
  });
}
