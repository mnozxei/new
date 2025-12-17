part of 'job_bloc.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobs extends JobEvent {
  const LoadJobs({
    this.companyId,
    this.jobType,
    this.location,
    this.isRemote,
    this.minExperience,
    this.searchQuery,
    this.limit = 20,
    this.offset = 0,
  });

  final String? companyId;
  final JobType? jobType;
  final String? location;
  final bool? isRemote;
  final int? minExperience;
  final String? searchQuery;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [
        companyId,
        jobType,
        location,
        isRemote,
        minExperience,
        searchQuery,
        limit,
        offset,
      ];
}

class LoadFeaturedJobs extends JobEvent {
  const LoadFeaturedJobs({this.limit = 10});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class LoadJobDetails extends JobEvent {
  const LoadJobDetails({required this.jobId});

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class CreateJob extends JobEvent {
  const CreateJob({required this.params});

  final CreateJobParams params;

  @override
  List<Object?> get props => [params];
}

class UpdateJob extends JobEvent {
  const UpdateJob({
    required this.jobId,
    required this.params,
  });

  final String jobId;
  final UpdateJobParams params;

  @override
  List<Object?> get props => [jobId, params];
}

class DeleteJob extends JobEvent {
  const DeleteJob({required this.jobId});

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class ToggleJobActive extends JobEvent {
  const ToggleJobActive({required this.jobId});

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class ApplyToJob extends JobEvent {
  const ApplyToJob({required this.params});

  final ApplyToJobParams params;

  @override
  List<Object?> get props => [params];
}

class WithdrawApplication extends JobEvent {
  const WithdrawApplication({required this.applicationId});

  final String applicationId;

  @override
  List<Object?> get props => [applicationId];
}

class LoadMyApplications extends JobEvent {
  const LoadMyApplications({
    this.status,
    this.limit = 20,
    this.offset = 0,
  });

  final ApplicationStatus? status;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [status, limit, offset];
}

class LoadJobApplications extends JobEvent {
  const LoadJobApplications({
    required this.jobId,
    this.status,
    this.limit = 20,
    this.offset = 0,
  });

  final String jobId;
  final ApplicationStatus? status;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [jobId, status, limit, offset];
}

class UpdateApplicationStatus extends JobEvent {
  const UpdateApplicationStatus({
    required this.applicationId,
    required this.status,
    this.notes,
    this.rejectionReason,
  });

  final String applicationId;
  final ApplicationStatus status;
  final String? notes;
  final String? rejectionReason;

  @override
  List<Object?> get props => [applicationId, status, notes, rejectionReason];
}

class ScheduleInterview extends JobEvent {
  const ScheduleInterview({
    required this.applicationId,
    required this.interviewDate,
    this.location,
    this.notes,
  });

  final String applicationId;
  final DateTime interviewDate;
  final String? location;
  final String? notes;

  @override
  List<Object?> get props => [applicationId, interviewDate, location, notes];
}

class SendJobOffer extends JobEvent {
  const SendJobOffer({
    required this.applicationId,
    required this.offeredSalary,
  });

  final String applicationId;
  final double offeredSalary;

  @override
  List<Object?> get props => [applicationId, offeredSalary];
}

class AcceptApplication extends JobEvent {
  const AcceptApplication({
    required this.applicationId,
    this.offeredSalary,
  });

  final String applicationId;
  final double? offeredSalary;

  @override
  List<Object?> get props => [applicationId, offeredSalary];
}

class ToggleSaveJob extends JobEvent {
  const ToggleSaveJob({required this.jobId});

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class LoadSavedJobs extends JobEvent {
  const LoadSavedJobs();
}

class SearchJobs extends JobEvent {
  const SearchJobs({
    required this.query,
    this.jobType,
    this.location,
    this.isRemote,
    this.limit = 20,
  });

  final String query;
  final JobType? jobType;
  final String? location;
  final bool? isRemote;
  final int limit;

  @override
  List<Object?> get props => [query, jobType, location, isRemote, limit];
}
