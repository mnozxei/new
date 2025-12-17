import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  JobRepositoryImpl({required this.remoteDataSource});

  final JobRemoteDataSource remoteDataSource;

  @override
  Future<List<JobEntity>> getJobs({
    String? companyId,
    JobType? jobType,
    String? location,
    bool? isRemote,
    int? minExperience,
    int? maxExperience,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) {
    return remoteDataSource.getJobs(
      companyId: companyId,
      jobType: jobType,
      location: location,
      isRemote: isRemote,
      minExperience: minExperience,
      maxExperience: maxExperience,
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<JobEntity>> getFeaturedJobs({int limit = 10}) {
    return remoteDataSource.getFeaturedJobs(limit: limit);
  }

  @override
  Future<JobEntity?> getJobById(String id) {
    return remoteDataSource.getJobById(id);
  }

  @override
  Future<JobEntity> createJob(CreateJobParams params) {
    return remoteDataSource.createJob(params);
  }

  @override
  Future<JobEntity> updateJob(String id, UpdateJobParams params) {
    return remoteDataSource.updateJob(id, params);
  }

  @override
  Future<void> deleteJob(String id) {
    return remoteDataSource.deleteJob(id);
  }

  @override
  Future<JobEntity> toggleJobActive(String id) {
    return remoteDataSource.toggleJobActive(id);
  }

  @override
  Future<bool> hasApplied(String jobId) {
    return remoteDataSource.hasApplied(jobId);
  }

  @override
  Future<JobApplicationEntity?> getMyApplication(String jobId) {
    return remoteDataSource.getMyApplication(jobId);
  }

  @override
  Future<JobApplicationEntity> applyToJob(ApplyToJobParams params) {
    return remoteDataSource.applyToJob(params);
  }

  @override
  Future<JobApplicationEntity> withdrawApplication(String applicationId) {
    return remoteDataSource.withdrawApplication(applicationId);
  }

  @override
  Future<List<JobApplicationEntity>> getMyApplications({
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  }) {
    return remoteDataSource.getMyApplications(
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<JobApplicationEntity>> getJobApplications(
    String jobId, {
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  }) {
    return remoteDataSource.getJobApplications(
      jobId,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<JobApplicationEntity> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? notes,
    String? rejectionReason,
  }) {
    return remoteDataSource.updateApplicationStatus(
      applicationId,
      status,
      notes: notes,
      rejectionReason: rejectionReason,
    );
  }

  @override
  Future<JobApplicationEntity> scheduleInterview(
    String applicationId, {
    required DateTime interviewDate,
    String? location,
    String? notes,
  }) {
    return remoteDataSource.scheduleInterview(
      applicationId,
      interviewDate: interviewDate,
      location: location,
      notes: notes,
    );
  }

  @override
  Future<JobApplicationEntity> sendOffer(
    String applicationId, {
    required double offeredSalary,
  }) {
    return remoteDataSource.sendOffer(
      applicationId,
      offeredSalary: offeredSalary,
    );
  }

  @override
  Future<bool> acceptApplication(
    String applicationId, {
    double? offeredSalary,
  }) {
    return remoteDataSource.acceptApplication(
      applicationId,
      offeredSalary: offeredSalary,
    );
  }

  @override
  Future<void> saveJob(String jobId) {
    return remoteDataSource.saveJob(jobId);
  }

  @override
  Future<void> unsaveJob(String jobId) {
    return remoteDataSource.unsaveJob(jobId);
  }

  @override
  Future<bool> isJobSaved(String jobId) {
    return remoteDataSource.isJobSaved(jobId);
  }

  @override
  Future<List<JobEntity>> getSavedJobs() {
    return remoteDataSource.getSavedJobs();
  }

  @override
  Future<void> incrementViewCount(String jobId) {
    return remoteDataSource.incrementViewCount(jobId);
  }
}
