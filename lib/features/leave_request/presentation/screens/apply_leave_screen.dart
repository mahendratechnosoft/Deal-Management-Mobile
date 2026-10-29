import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/di/injection_container.dart';
import 'package:xpertbiz/features/leave_request/bloc/leave_request_bloc.dart';
import 'package:xpertbiz/features/leave_request/bloc/leave_request_event.dart';
import 'package:xpertbiz/features/leave_request/bloc/leave_request_state.dart';
import 'package:xpertbiz/features/leave_request/data/models/leave_approver_model.dart';
import 'package:xpertbiz/features/leave_request/data/models/leave_request_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/employee_item_model.dart';

class ApplyLeaveScreen extends StatelessWidget {
  final LeaveRequestModel? initialLeave;

  const ApplyLeaveScreen({super.key, this.initialLeave});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LeaveRequestBloc>()..add(const LoadApplyFormDataEvent()),
      child: _ApplyLeaveView(initialLeave: initialLeave),
    );
  }
}

class _ApplyLeaveView extends StatefulWidget {
  final LeaveRequestModel? initialLeave;

  const _ApplyLeaveView({this.initialLeave});

  @override
  State<_ApplyLeaveView> createState() => _ApplyLeaveViewState();
}

class _ApplyLeaveViewState extends State<_ApplyLeaveView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  // Dropdown list options for leave type
  final List<String> _leaveTypes = ['Leave without Pay'];
  String _selectedLeaveType = 'Leave without Pay';

  // Persisted lists in State so they don't vanish during ApplyFormSubmitting
  List<LeaveApproverModel> _approvers = [];
  List<EmployeeItemModel> _handoverEmployees = [];

  // Use String ID for dropdown values to avoid object identity bugs
  String? _selectedApproverId;
  String? _selectedHandoverId;

  DateTime? _startDate;
  DateTime? _endDate;
  final List<LeaveDayModel> _leaveDays = [];

  PlatformFile? _pickedFile;
  String? _existingAttachmentUrl;
  bool _existingAttachmentRemoved = false;
  bool _initializedWithInitialLeave = false;

  bool get _isEditMode => widget.initialLeave != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final leave = widget.initialLeave!;
      _selectedLeaveType = leave.leaveType;
      if (!_leaveTypes.contains(leave.leaveType)) {
        _leaveTypes.add(leave.leaveType);
      }
      _selectedApproverId = leave.assignToId;
      _selectedHandoverId = leave.handoverId;
      _existingAttachmentUrl = leave.attachedFileUrl;
      _reasonController.text = leave.reason;

      try {
        _startDate = leave.startDate != null ? DateTime.parse(leave.startDate!) : DateTime.now();
        _endDate = leave.endDate != null ? DateTime.parse(leave.endDate!) : DateTime.now();
      } catch (_) {
        _startDate = DateTime.now();
        _endDate = DateTime.now();
      }

      if (leave.leaveDays.isNotEmpty) {
        _leaveDays.addAll(leave.leaveDays);
      } else {
        _generateLeaveDays(_startDate!, _endDate!);
      }
    } else {
      final today = DateTime.now();
      _startDate = today;
      _endDate = today;
      _generateLeaveDays(today, today);
    }
  }

  void _generateLeaveDays(DateTime start, DateTime end) {
    _leaveDays.clear();
    DateTime current = start;
    final formatter = DateFormat('yyyy-MM-dd');

    while (!current.isAfter(end)) {
      _leaveDays.add(LeaveDayModel(
        date: formatter.format(current),
        leaveDayType: 'FULL_DAY',
      ));
      current = current.add(const Duration(days: 1));
    }
  }

  double get _totalDaysCount {
    double total = 0.0;
    for (final day in _leaveDays) {
      if (day.leaveDayType == 'HALF_DAY') {
        total += 0.5;
      } else if (day.leaveDayType == 'FULL_DAY') {
        total += 1.0;
      }
    }
    return total;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _datePickerTheme(child!),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before new start date, adjust end date
        if (_endDate == null || _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
        _generateLeaveDays(_startDate!, _endDate!);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final initialDate = (_endDate != null && _startDate != null && !_endDate!.isBefore(_startDate!))
        ? _endDate!
        : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _datePickerTheme(child!),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        if (_startDate == null || _startDate!.isAfter(picked)) {
          _startDate = picked;
        }
        _generateLeaveDays(_startDate!, _endDate!);
      });
    }
  }

  Widget _datePickerTheme(Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          onPrimary: Colors.white,
          onSurface: Color(0xFF0F172A),
        ),
      ),
      child: child,
    );
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedApproverId == null || _selectedApproverId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an approver'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_leaveDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one leave day'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final selectedApprover = _approvers.firstWhere(
      (a) => a.employeeId == _selectedApproverId,
      orElse: () => LeaveApproverModel(
        employeeId: _selectedApproverId!,
        name: widget.initialLeave?.assignToName ?? 'Approver',
      ),
    );

    final payload = <String, dynamic>{
      'assignToId': selectedApprover.employeeId,
      'assignToName': selectedApprover.name,
      'leaveType': _selectedLeaveType,
      'reason': _reasonController.text.trim(),
      'startDate': _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null,
      'endDate': _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
      'leaveDays': _leaveDays
          .map((d) => {
                'date': d.date,
                'leaveDayType': d.leaveDayType,
              })
          .toList(),
    };

    if (_selectedHandoverId != null && _selectedHandoverId!.isNotEmpty) {
      final selectedHandover = _handoverEmployees.firstWhere(
        (h) => h.employeeId == _selectedHandoverId,
        orElse: () => EmployeeItemModel(
          employeeId: _selectedHandoverId!,
          name: widget.initialLeave?.handoverName ?? '',
        ),
      );
      payload['handoverId'] = selectedHandover.employeeId;
      payload['handoverName'] = selectedHandover.name;
    }

    if (_isEditMode &&
        _existingAttachmentUrl != null &&
        !_existingAttachmentRemoved &&
        _pickedFile == null) {
      payload['attachedFileUrl'] = _existingAttachmentUrl;
    }

    context.read<LeaveRequestBloc>().add(
          SubmitLeaveApplicationEvent(
            data: payload,
            localFilePath: _pickedFile?.path,
            localFileName: _pickedFile?.name,
            isEdit: _isEditMode,
            leaveRequestId: widget.initialLeave?.leaveRequestId,
          ),
        );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar(
        title: _isEditMode ? 'Edit Leave Request' : 'Apply for Leave',
      ),
      body: BlocConsumer<LeaveRequestBloc, LeaveRequestState>(
        listener: (context, state) {
          if (state is ApplyFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF16A34A),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ApplyFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ApplyFormDependenciesLoading && _approvers.isEmpty) {
            return SkeletonCard(isLoading: true, itemCount: 6);
          }

          if (state is ApplyFormDependenciesLoaded) {
            _approvers = List.from(state.approvers);
            _handoverEmployees = List.from(state.handoverEmployees);

            if (!_initializedWithInitialLeave) {
              if (_isEditMode && widget.initialLeave != null) {
                final targetApproverId = widget.initialLeave!.assignToId;
                if (targetApproverId != null) {
                  _selectedApproverId = targetApproverId;
                  // If not present in fetched list, synthesize from initialLeave
                  if (!_approvers.any((a) => a.employeeId == targetApproverId) &&
                      widget.initialLeave?.assignToName != null) {
                    _approvers.insert(
                      0,
                      LeaveApproverModel(
                        employeeId: targetApproverId,
                        name: widget.initialLeave!.assignToName!,
                      ),
                    );
                  }
                }

                final targetHandoverId = widget.initialLeave!.handoverId;
                if (targetHandoverId != null) {
                  _selectedHandoverId = targetHandoverId;
                  if (!_handoverEmployees.any((h) => h.employeeId == targetHandoverId) &&
                      widget.initialLeave?.handoverName != null) {
                    _handoverEmployees.insert(
                      0,
                      EmployeeItemModel(
                        employeeId: targetHandoverId,
                        name: widget.initialLeave!.handoverName!,
                      ),
                    );
                  }
                }
              }

              if ((_selectedApproverId == null || _selectedApproverId!.isEmpty) &&
                  _approvers.isNotEmpty) {
                _selectedApproverId = _approvers.first.employeeId;
              }
              _initializedWithInitialLeave = true;
            }
          }

          final isSubmitting = state is ApplyFormSubmitting;

          // Safe value check for approver dropdown
          final safeApproverValue = _approvers.any((a) => a.employeeId == _selectedApproverId)
              ? _selectedApproverId
              : (_approvers.isNotEmpty ? _approvers.first.employeeId : null);

          // Safe value check for handover dropdown
          final safeHandoverValue = (_selectedHandoverId != null &&
                  _handoverEmployees.any((h) => h.employeeId == _selectedHandoverId))
              ? _selectedHandoverId
              : null;

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.h(14),
                vertical: Responsive.h(12),
              ),
              children: [
                // 1. Leave Type as Dropdown (Requested)
                _buildCardSection(
                  title: 'Leave Type',
                  icon: Icons.beach_access_rounded,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedLeaveType,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.h(12)),
                    elevation: 6,
                    menuMaxHeight: Responsive.h(260),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF2563EB),
                      size: Responsive.h(20),
                    ),
                    decoration: _customInputDecoration(
                      hint: 'Select Leave Type',
                      prefixIcon: Icons.beach_access_rounded,
                    ),
                    items: _leaveTypes.map((type) {
                      final isSel = type == _selectedLeaveType;
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: Responsive.h(12.5),
                                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (isSel)
                              Icon(
                                Icons.check_circle_rounded,
                                size: Responsive.h(16),
                                color: const Color(0xFF2563EB),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLeaveType = val);
                    },
                  ),
                ),

                SizedBox(height: Responsive.h(10)),

                // 2. Approver & Handover Dropdowns
                _buildCardSection(
                  title: 'Approver & Handover',
                  icon: Icons.people_outline_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Approver Dropdown (Required)
                      Text(
                        'Assign Approver *',
                        style: TextStyle(
                          fontSize: Responsive.h(11.5),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: Responsive.h(5)),
                      DropdownButtonFormField<String>(
                        initialValue: safeApproverValue,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(Responsive.h(12)),
                        elevation: 6,
                        menuMaxHeight: Responsive.h(300),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF2563EB),
                          size: Responsive.h(20),
                        ),
                        decoration: _customInputDecoration(
                          hint: 'Select Manager / Approver',
                          prefixIcon: Icons.verified_user_outlined,
                        ),
                        items: _approvers.map((approver) {
                          final isSel = approver.employeeId == safeApproverValue;
                          final initial = approver.name.isNotEmpty
                              ? approver.name[0].toUpperCase()
                              : 'A';
                          final roleText = approver.role != null && approver.role!.isNotEmpty
                              ? approver.role!
                              : null;

                          return DropdownMenuItem<String>(
                            value: approver.employeeId,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    approver.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: Responsive.h(12.5),
                                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (roleText != null) ...[
                                  SizedBox(width: Responsive.h(6)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.h(6),
                                      vertical: Responsive.h(2),
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(Responsive.h(4)),
                                    ),
                                    child: Text(
                                      roleText,
                                      style: TextStyle(
                                        fontSize: Responsive.h(9.5),
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                                if (isSel) ...[
                                  SizedBox(width: Responsive.h(6)),
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: Responsive.h(16),
                                    color: const Color(0xFF2563EB),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedApproverId = val);
                        },
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Please select an approver' : null,
                      ),

                      SizedBox(height: Responsive.h(10)),

                      // Handover Dropdown (Optional)
                      Text(
                        'Handover Colleague (Optional)',
                        style: TextStyle(
                          fontSize: Responsive.h(11.5),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: Responsive.h(5)),
                      DropdownButtonFormField<String?>(
                        initialValue: safeHandoverValue,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(Responsive.h(12)),
                        elevation: 6,
                        menuMaxHeight: Responsive.h(300),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF2563EB),
                          size: Responsive.h(20),
                        ),
                        decoration: _customInputDecoration(
                          hint: 'Select Colleague for Handover',
                          prefixIcon: Icons.people_outline_rounded,
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'None (No Handover)',
                                    style: TextStyle(
                                      fontSize: Responsive.h(12),
                                      color: const Color(0xFF94A3B8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                if (safeHandoverValue == null)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: Responsive.h(16),
                                    color: const Color(0xFF2563EB),
                                  ),
                              ],
                            ),
                          ),
                          ..._handoverEmployees.map((emp) {
                            final isSel = emp.employeeId == safeHandoverValue;
                            final initial = emp.name.isNotEmpty
                                ? emp.name[0].toUpperCase()
                                : 'E';
                            return DropdownMenuItem<String?>(
                              value: emp.employeeId,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      emp.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: Responsive.h(12.5),
                                        fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  if (isSel)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: Responsive.h(16),
                                      color: const Color(0xFF2563EB),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedHandoverId = val);
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Responsive.h(10)),

                // 3. Separate Start Date & End Date fields (Requested)
                _buildCardSection(
                  title: 'Leave Dates & Day Breakdown',
                  icon: Icons.calendar_month_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Separate Start Date Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Date *',
                                  style: TextStyle(
                                    fontSize: Responsive.h(11.5),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                SizedBox(height: Responsive.h(5)),
                                InkWell(
                                  onTap: _selectStartDate,
                                  borderRadius: BorderRadius.circular(Responsive.h(8)),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.h(10),
                                      vertical: Responsive.h(9.5),
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(Responsive.h(8)),
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: Responsive.h(14),
                                          color: const Color(0xFF2563EB),
                                        ),
                                        SizedBox(width: Responsive.h(6)),
                                        Expanded(
                                          child: Text(
                                            _startDate != null
                                                ? DateFormat('dd MMM yyyy').format(_startDate!)
                                                : 'Select Date',
                                            style: TextStyle(
                                              fontSize: Responsive.h(12),
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: Responsive.h(10)),

                          // Separate End Date Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Date *',
                                  style: TextStyle(
                                    fontSize: Responsive.h(11.5),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                SizedBox(height: Responsive.h(5)),
                                InkWell(
                                  onTap: _selectEndDate,
                                  borderRadius: BorderRadius.circular(Responsive.h(8)),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.h(10),
                                      vertical: Responsive.h(9.5),
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(Responsive.h(8)),
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.event_available_rounded,
                                          size: Responsive.h(15),
                                          color: const Color(0xFF2563EB),
                                        ),
                                        SizedBox(width: Responsive.h(6)),
                                        Expanded(
                                          child: Text(
                                            _endDate != null
                                                ? DateFormat('dd MMM yyyy').format(_endDate!)
                                                : 'Select Date',
                                            style: TextStyle(
                                              fontSize: Responsive.h(12),
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Responsive.h(10)),

                      // Total Days Calculated Pill
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.h(10),
                          vertical: Responsive.h(6.5),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(Responsive.h(6)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Days Count',
                              style: TextStyle(
                                fontSize: Responsive.h(11.5),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E3A8A),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.h(7),
                                vertical: Responsive.h(2.5),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(Responsive.h(4)),
                              ),
                              child: Text(
                                '$_totalDaysCount Days',
                                style: TextStyle(
                                  fontSize: Responsive.h(11),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.h(10)),

                      // Individual Days Breakdown with Full/Half Day toggle
                      Text(
                        'Day Breakdown (Toggle for Half Day)',
                        style: TextStyle(
                          fontSize: Responsive.h(11),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: Responsive.h(5)),
                      ..._leaveDays.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final day = entry.value;
                        final isHalfDay = day.leaveDayType == 'HALF_DAY';

                        DateTime? parsedDt;
                        try {
                          parsedDt = DateTime.parse(day.date);
                        } catch (_) {}

                        final dayLabel = parsedDt != null
                            ? DateFormat('dd MMM (EEE)').format(parsedDt)
                            : day.date;

                        return Container(
                          margin: EdgeInsets.only(bottom: Responsive.h(5)),
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.h(10),
                            vertical: Responsive.h(5.5),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(Responsive.h(6)),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dayLabel,
                                style: TextStyle(
                                  fontSize: Responsive.h(12),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Row(
                                children: [
                                  _buildMiniChoiceChip(
                                    label: 'Full Day',
                                    selected: !isHalfDay,
                                    selectedColor: const Color(0xFF2563EB),
                                    onTap: () {
                                      setState(() {
                                        _leaveDays[idx] = day.copyWith(
                                          leaveDayType: 'FULL_DAY',
                                        );
                                      });
                                    },
                                  ),
                                  SizedBox(width: Responsive.h(5)),
                                  _buildMiniChoiceChip(
                                    label: 'Half Day',
                                    selected: isHalfDay,
                                    selectedColor: const Color(0xFFD97706),
                                    onTap: () {
                                      setState(() {
                                        _leaveDays[idx] = day.copyWith(
                                          leaveDayType: 'HALF_DAY',
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                SizedBox(height: Responsive.h(10)),

                // 4. Reason for Leave
                _buildCardSection(
                  title: 'Reason for Leave *',
                  icon: Icons.edit_note_rounded,
                  child: TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: Responsive.h(12.5),
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Please describe the reason for your leave...',
                      hintStyle: TextStyle(
                        fontSize: Responsive.h(12),
                        color: const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.all(Responsive.h(10)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.h(8)),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.h(8)),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.h(8)),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter the reason for leave';
                      }
                      if (val.trim().length < 4) {
                        return 'Reason is too short';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: Responsive.h(10)),

                // 5. Supporting Document (Optional)
                _buildCardSection(
                  title: 'Supporting Document (Optional)',
                  icon: Icons.attach_file_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_pickedFile != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.h(10),
                            vertical: Responsive.h(7),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(Responsive.h(8)),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_present_rounded,
                                color: const Color(0xFF2563EB),
                                size: Responsive.h(18),
                              ),
                              SizedBox(width: Responsive.h(7)),
                              Expanded(
                                child: Text(
                                  _pickedFile!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: Responsive.h(12),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  setState(() => _pickedFile = null);
                                },
                              ),
                            ],
                          ),
                        )
                      else if (_existingAttachmentUrl != null &&
                          _existingAttachmentUrl!.isNotEmpty &&
                          !_existingAttachmentRemoved)
                        _buildExistingAttachmentPreview()
                      else
                        InkWell(
                          onTap: _pickAttachment,
                          borderRadius: BorderRadius.circular(Responsive.h(8)),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.h(12),
                              vertical: Responsive.h(10),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(Responsive.h(8)),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file_rounded,
                                  size: Responsive.h(18),
                                  color: const Color(0xFF2563EB),
                                ),
                                SizedBox(width: Responsive.h(6)),
                                Text(
                                  'Upload Document or Slip',
                                  style: TextStyle(
                                    fontSize: Responsive.h(12),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: Responsive.h(18)),

                // 6. Primary Action Button
                ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.h(10)),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Update Leave Request' : 'Submit Leave Application',
                          style: TextStyle(
                            fontSize: Responsive.h(13.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),

                SizedBox(height: Responsive.h(24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExistingAttachmentPreview() {
    final raw = _existingAttachmentUrl!;
    final fullUrl = LeaveRequestModel.formatAttachmentUrl(raw);
    final lower = raw.toLowerCase();
    final isImg = lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(Responsive.h(8)),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isImg)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.h(8))),
              child: Image.network(
                fullUrl,
                height: Responsive.h(110),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.h(8),
              vertical: Responsive.h(6),
            ),
            child: Row(
              children: [
                Icon(
                  isImg ? Icons.image_rounded : Icons.attach_file_rounded,
                  size: Responsive.h(16),
                  color: const Color(0xFF2563EB),
                ),
                SizedBox(width: Responsive.h(6)),
                Expanded(
                  child: Text(
                    raw,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.h(11.5),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _pickAttachment,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.h(6)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Change', style: TextStyle(fontSize: 11)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                  onPressed: () {
                    setState(() => _existingAttachmentRemoved = true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChoiceChip({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.h(8),
          vertical: Responsive.h(3),
        ),
        decoration: BoxDecoration(
          color: selected ? selectedColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(Responsive.h(5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: Responsive.h(10.5),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.h(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.h(10)),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: Responsive.h(15), color: const Color(0xFF2563EB)),
              SizedBox(width: Responsive.h(5)),
              Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.h(12.5),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          child,
        ],
      ),
    );
  }

  InputDecoration _customInputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: Responsive.h(12),
        color: const Color(0xFF94A3B8),
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: Responsive.h(16),
        color: const Color(0xFF2563EB),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.h(12),
        vertical: Responsive.h(10),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.h(10)),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.h(10)),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.h(10)),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
