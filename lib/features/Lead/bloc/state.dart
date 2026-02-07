import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/Lead/data/model/all_lead_model.dart';
import 'package:xpertbiz/features/Lead/data/model/lead_details_model.dart';
import 'package:xpertbiz/features/Lead/data/model/reminder_model.dart';
import '../data/model/lead_status_model.dart';

// Add this import
import 'package:xpertbiz/features/Lead/data/model/activity_log_model.dart';

abstract class LeadState extends Equatable {
  const LeadState();

  @override
  List<Object?> get props => [];
}

class LeadInitial extends LeadState {}

class LeadLoading extends LeadState {}

class LeadLoaded extends LeadState {
  final List<LeadStatusModel> leads;

  const LeadLoaded(this.leads);

  @override
  List<Object?> get props => [leads];
}

class LeadError extends LeadState {
  final String message;

  const LeadError(this.message);

  @override
  List<Object?> get props => [message];
}

class AllLeadInitial extends LeadState {}

class AllLeadLoading extends LeadState {}

class AllLeadState extends LeadState {
  final List<LeadModel> leads;
  final List<StatusCountModel> statusAndCount;
  final List<LeadModel> filteredLeads;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;
  final DateTime? selectedDate;
  final String? status;
  final bool isSearching;
  final bool isDateFiltered;
  final LeadDetailsModel? leadDetailsModel;
  final bool leadDetailsLoader;
  final List<ActivityLogModel> activityLogs; // Add activity logs
  final bool activityLogsLoader; // Add activity logs loader
  final List<ReminderModel>? remindermodel;
  final bool? reminder;
  final bool createReminder;
  final String? createReminderError;

  const AllLeadState({
    required this.statusAndCount,
    required this.leads,
    required this.hasMore,
    required this.currentPage,
    this.createReminder = false,
    this.createReminderError,
    this.leadDetailsModel,
    this.leadDetailsLoader = false,
    this.activityLogs = const [], // Initialize empty
    this.activityLogsLoader = false, // Initialize false
    this.searchQuery,
    this.selectedDate,
    this.status,
    this.filteredLeads = const [],
    this.isSearching = false,
    this.isDateFiltered = false,
    this.reminder,
    this.remindermodel,
  });

  AllLeadState copyWith({
    List<StatusCountModel>? statusAndCount,
    List<LeadModel>? leads,
    List<LeadModel>? filteredLeads,
    bool? createReminder,
    String? createReminderError,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    DateTime? selectedDate,
    String? status,
    bool? isSearching,
    bool? isDateFiltered,
    LeadDetailsModel? leadDetailsModel,
    bool? leadDetailsLoader,
    List<ActivityLogModel>? activityLogs,
    bool? activityLogsLoader,
    List<ReminderModel>? remindermodel,
    bool? reminder,
  }) {
    return AllLeadState(
      statusAndCount: statusAndCount?? this.statusAndCount,
      createReminder: createReminder ?? this.createReminder,
      createReminderError: createReminderError ?? this.createReminderError,
      reminder: reminder ?? this.reminder,
      remindermodel: remindermodel ?? remindermodel,
      leads: leads ?? this.leads,
      filteredLeads: filteredLeads ?? this.filteredLeads,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDate: selectedDate ?? this.selectedDate,
      status: status ?? this.status,
      isSearching: isSearching ?? this.isSearching,
      isDateFiltered: isDateFiltered ?? this.isDateFiltered,
      leadDetailsModel: leadDetailsModel ?? this.leadDetailsModel,
      leadDetailsLoader: leadDetailsLoader ?? this.leadDetailsLoader,
      activityLogs: activityLogs ?? this.activityLogs,
      activityLogsLoader: activityLogsLoader ?? this.activityLogsLoader,
    );
  }

  @override
  List<Object?> get props => [
        reminder,
        createReminder,
        createReminderError,
        remindermodel,
        leads,
        filteredLeads,
        hasMore,
        currentPage,
        searchQuery,
        selectedDate,
        status,
        isSearching,
        isDateFiltered,
        leadDetailsModel,
        leadDetailsLoader,
        activityLogs,
        activityLogsLoader,
      ];
}

class AllLeadError extends LeadState {
  final String message;
  const AllLeadError(this.message);
}

class CreateLeadInitial extends LeadState {}

class CreateLeadLoading extends LeadState {}

class CreateLeadSuccess extends LeadState {}

class CreateLeadError extends LeadState {
  final String message;
  const CreateLeadError(this.message);
}