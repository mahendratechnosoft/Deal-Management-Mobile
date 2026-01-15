import 'package:flutter/material.dart';
import '../bloc/model/assigne_model.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<SelectedAssignee> items;
  final List<SelectedAssignee> selectedItems;
  final Function(List<SelectedAssignee>) onSelectionChanged;
  final String hintText;
  final double? maxHeight;

  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.hintText = 'Select items',
    this.maxHeight = 300,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Selected Items Chips
        if (widget.selectedItems.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedItems.map((item) {
              return Chip(
                label: Text(item.name),
                avatar: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    item.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                onDeleted: () {
                  final updated = widget.selectedItems.where((i) => i.employeeId != item.employeeId).toList();
                  widget.onSelectionChanged(updated);
                },
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),

        const SizedBox(height: 8),

        /// Dropdown Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              /// Header
              ListTile(
                title: Text(
                  widget.hintText,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade600,
                ),
                dense: true,
                onTap: () => setState(() => isExpanded = !isExpanded),
              ),

              /// Dropdown List
              if (isExpanded)
                Container(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight!),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = widget.selectedItems.any((i) => i.employeeId == item.employeeId);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          final updated = List<SelectedAssignee>.from(widget.selectedItems);
                          if (value == true) {
                            updated.add(item);
                          } else {
                            updated.removeWhere((i) => i.employeeId == item.employeeId);
                          }
                          widget.onSelectionChanged(updated);
                        },
                        title: Text(item.name),
                        subtitle: item.email != null ? Text(item.email!) : null,
                        secondary: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            item.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}