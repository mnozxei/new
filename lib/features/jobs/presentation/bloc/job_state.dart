part of 'job_bloc.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {
  const JobInitial();
}

class JobLoading extends JobState {
  const JobLoading();
}

class JobError extends JobState {
  const JobError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class JobsLoaded extends JobState {
  const JobsLoaded({
    required this.jobs,
    this.hasMore = false,
  });

  final List<JobEntity> jobs;
  final bool hasMore;

  @override
  List<Object?> get props => [jobs, hasMore];
}

class FeaturedJobsLoaded extends JobState {
  const FeaturedJobsLoaded({required this.jobs});

  final List<JobEntity> jobs;

  @override
  List<Object?> get props => [jobs];
}

class JobDetailsLoaded extends JobState {
  const JobDetailsLoaded({
    required this.job,
    required this.hasApplied,
    required this.isSaved,
    this.myApplication,
  });

  final JobEntity job;
  final bool hasApplied;
  final bool isSaved;
  final JobApplicationEntity? myApplication;

  @override
  List<Object?> get props => [job, hasApplied, isSaved, myApplication];
}

class JobCreated extends JobState {
  const JobCreated({required this.job});

  final JobEntity job;

  @override
  List<Object?> get props => [job];
}

class JobUpdated extends JobState {
  const JobUpdated({required this.job});

  final JobEntity job;

  @override
  List<Object?> get props => [job];
}

class JobDeleted extends JobState {
  const JobDeleted({required this.jobId});

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class ApplicationSubmitted extends JobState {
  const ApplicationSubmitted({required this.application});

  final JobApplicationEntity application;

  @override
  List<Object?> get props => [application];
}

class ApplicationWithdrawn extends JobState {
  const ApplicationWithdrawn({required this.application});

  final JobApplicationEntity application;

  @override
  List<Object?> get props => [application];
}

class MyApplicationsLoaded extends JobState {
  const MyApplicationsLoaded({
    required this.applications,
    this.hasMore = false,
  });

  final List<JobApplicationEntity> applications;
  final bool hasMore;

  @override
  List<Object?> get props => [applications, hasMore];
}

class JobApplicationsLoaded extends JobState {
  const JobApplicationsLoaded({
    required this.jobId,
    required this.applications,
    this.hasMore = false,
  });

  final String jobId;
  final List<JobApplicationEntity> applications;
  final bool hasMore;

  @override
  List<Object?> get props => [jobId, applications, hasMore];
}

class ApplicationStatusUpdated extends JobState {
  const ApplicationStatusUpdated({required this.application});

  final JobApplicationEntity application;

  @override
  List<Object?> get props => [application];
}

class InterviewScheduled extends JobState {
  const InterviewScheduled({required this.application});

  final JobApplicationEntity application;

  @override
  List<Object?> get props => [application];
}

class OfferSent extends JobState {
  const OfferSent({required this.application});

  final JobApplicationEntity application;

  @override
  List<Object?> get props => [application];
}

class ApplicationAccepted extends JobState {
  const ApplicationAccepted({required this.applicationId});

  final String applicationId;

  @override
  List<Object?> get props => [applicationId];
}

class JobSaveToggled extends JobState {
  const JobSaveToggled({
    required this.jobId,
    required this.isSaved,
  });

  final String jobId;
  final bool isSaved;

  @override
  List<Object?> get props => [jobId, isSaved];
}

class SavedJobsLoaded extends JobState {
  const SavedJobsLoaded({required this.jobs});

  final List<JobEntity> jobs;

  @override
  List<Object?> get props => [jobs];
}

class JobSearchResults extends JobState {
  const JobSearchResults({
    required this.jobs,
    required this.query,
    this.hasMore = false,
  });

  final List<JobEntity> jobs;
  final String query;
  final bool hasMore;

  @override
  List<Object?> get props => [jobs, query, hasMore];
}
