class SelectedAssignee {
  final String employeeId;
  final String name;
  final String? email;
  final bool isSelected;

  SelectedAssignee({
    required this.employeeId,
    required this.name,
    this.email,
    this.isSelected = false,
  });

  SelectedAssignee copyWith({
    String? employeeId,
    String? name,
    String? email,
    bool? isSelected,
  }) {
    return SelectedAssignee(
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() => name;
}