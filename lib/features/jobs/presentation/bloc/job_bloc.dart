import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  JobBloc({required this.repository}) : super(const JobInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<LoadFeaturedJobs>(_onLoadFeaturedJobs);
    on<LoadJobDetails>(_onLoadJobDetails);
    on<CreateJob>(_onCreateJob);
    on<UpdateJob>(_onUpdateJob);
    on<DeleteJob>(_onDeleteJob);
    on<ToggleJobActive>(_onToggleJobActive);
    on<PublishJob>(_onPublishJob);
    on<CloseJob>(_onCloseJob);
    on<ArchiveJob>(_onArchiveJob);
    on<ApplyToJob>(_onApplyToJob);
    on<WithdrawApplication>(_onWithdrawApplication);
    on<LoadMyApplications>(_onLoadMyApplications);
    on<LoadJobApplications>(_onLoadJobApplications);
    on<UpdateApplicationStatus>(_onUpdateApplicationStatus);
    on<ScheduleInterview>(_onScheduleInterview);
    on<SendJobOffer>(_onSendJobOffer);
    on<AcceptApplication>(_onAcceptApplication);
    on<ToggleSaveJob>(_onToggleSaveJob);
    on<LoadSavedJobs>(_onLoadSavedJobs);
    on<SearchJobs>(_onSearchJobs);
    on<LoadCompanyJobs>(_onLoadCompanyJobs);
    on<LoadApplicationDetails>(_onLoadApplicationDetails);
  }

  final JobRepository repository;

  Future<void> _onLoadJobs(
    LoadJobs event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final jobs = await repository.getJobs(
        companyId: event.companyId,
        jobType: event.jobType,
        location: event.location,
        isRemote: event.isRemote,
        minExperience: event.minExperience,
        searchQuery: event.searchQuery,
        limit: event.limit,
        offset: event.offset,
      );
      emit(JobsLoaded(jobs: jobs, hasMore: jobs.length >= event.limit));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onLoadFeaturedJobs(
    LoadFeaturedJobs event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final jobs = await repository.getFeaturedJobs(limit: event.limit);
      emit(FeaturedJobsLoaded(jobs: jobs));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onLoadJobDetails(
    LoadJobDetails event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final job = await repository.getJobById(event.jobId);
      if (job == null) {
        emit(const JobError(message: 'Job not found'));
        return;
      }

      await repository.incrementViewCount(event.jobId);

      final hasApplied = await repository.hasApplied(event.jobId);
      final isSaved = await repository.isJobSaved(event.jobId);
      final myApplication = hasApplied
          ? await repository.getMyApplication(event.jobId)
          : null;

      emit(JobDetailsLoaded(
        job: job,
        hasApplied: hasApplied,
        isSaved: isSaved,
        myApplication: myApplication,
      ));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onCreateJob(
    CreateJob event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final job = await repository.createJob(event.params);
      emit(JobCreated(job: job));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onUpdateJob(
    UpdateJob event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final job = await repository.updateJob(event.jobId, event.params);
      emit(JobUpdated(job: job));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onDeleteJob(
    DeleteJob event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      await repository.deleteJob(event.jobId);
      emit(JobDeleted(jobId: event.jobId));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onToggleJobActive(
    ToggleJobActive event,
    Emitter<JobState> emit,
  ) async {
    try {
      final job = await repository.toggleJobActive(event.jobId);
      emit(JobUpdated(job: job));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onApplyToJob(
    ApplyToJob event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final application = await repository.applyToJob(event.params);
      emit(ApplicationSubmitted(application: application));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onWithdrawApplication(
    WithdrawApplication event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final application = await repository.withdrawApplication(event.applicationId);
      emit(ApplicationWithdrawn(application: application));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyApplications(
    LoadMyApplications event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final applications = await repository.getMyApplications(
        status: event.status,
        limit: event.limit,
        offset: event.offset,
      );
      emit(MyApplicationsLoaded(
        applications: applications,
        hasMore: applications.length >= event.limit,
      ));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onLoadJobApplications(
    LoadJobApplications event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final applications = await repository.getJobApplications(
        event.jobId,
        status: event.status,
        limit: event.limit,
        offset: event.offset,
      );
      emit(JobApplicationsLoaded(
        jobId: event.jobId,
        applications: applications,
        hasMore: applications.length >= event.limit,
      ));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onUpdateApplicationStatus(
    UpdateApplicationStatus event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final application = await repository.updateApplicationStatus(
        event.applicationId,
        event.status,
        notes: event.notes,
        rejectionReason: event.rejectionReason,
      );
      emit(ApplicationStatusUpdated(application: application));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onScheduleInterview(
    ScheduleInterview event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final application = await repository.scheduleInterview(
        event.applicationId,
        interviewDate: event.interviewDate,
        location: event.location,
        notes: event.notes,
      );
      emit(InterviewScheduled(application: application));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onSendJobOffer(
    SendJobOffer event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final application = await repository.sendOffer(
        event.applicationId,
        offeredSalary: event.offeredSalary,
      );
      emit(OfferSent(application: application));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onAcceptApplication(
    AcceptApplication event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final success = await repository.acceptApplication(
        event.applicationId,
        offeredSalary: event.offeredSalary,
      );
      if (success) {
        emit(ApplicationAccepted(applicationId: event.applicationId));
      } else {
        emit(const JobError(message: 'لا توجد شواغر متاحة'));
      }
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onToggleSaveJob(
    ToggleSaveJob event,
    Emitter<JobState> emit,
  ) async {
    try {
      final isSaved = await repository.isJobSaved(event.jobId);
      if (isSaved) {
        await repository.unsaveJob(event.jobId);
      } else {
        await repository.saveJob(event.jobId);
      }
      emit(JobSaveToggled(jobId: event.jobId, isSaved: !isSaved));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onLoadSavedJobs(
    LoadSavedJobs event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final jobs = await repository.getSavedJobs();
      emit(SavedJobsLoaded(jobs: jobs));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onSearchJobs(
    SearchJobs event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final jobs = await repository.getJobs(
        searchQuery: event.query,
        jobType: event.jobType,
        location: event.location,
        isRemote: event.isRemote,
        limit: event.limit,
      );
      emit(JobSearchResults(
        jobs: jobs,
        query: event.query,
        hasMore: jobs.length >= event.limit,
      ));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onPublishJob(
    PublishJob event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final job = await repository.publishJob(event.jobId);
      emit(JobPublished(job: job));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onCloseJob(
    CloseJob event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final job = await repository.closeJob(event.jobId);
      emit(JobClosed(job: job));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onArchiveJob(
    ArchiveJob event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final job = await repository.archiveJob(event.jobId);
      emit(JobArchived(job: job));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onLoadCompanyJobs(
    LoadCompanyJobs event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final jobs = await repository.getCompanyJobs(
        companyId: event.companyId,
        status: event.status,
        limit: event.limit,
        offset: event.offset,
      );
      emit(CompanyJobsLoaded(
        companyId: event.companyId,
        jobs: jobs,
        hasMore: jobs.length >= event.limit,
      ));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onLoadApplicationDetails(
    LoadApplicationDetails event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());
    try {
      final application = await repository.getApplicationById(event.applicationId);
      if (application == null) {
        emit(const JobError(message: 'الطلب غير موجود'));
        return;
      }
      emit(ApplicationDetailsLoaded(application: application));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }
}
