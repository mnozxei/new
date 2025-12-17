import 'dart:io';

import '../entities/job_entity.dart';

abstract class JobRepository {
  /// Get jobs with filters
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
  });

  /// Get featured jobs
  Future<List<JobEntity>> getFeaturedJobs({int limit = 10});

  /// Get job by ID
  Future<JobEntity?> getJobById(String id);

  /// Create a new job
  Future<JobEntity> createJob(CreateJobParams params);

  /// Update a job
  Future<JobEntity> updateJob(String id, UpdateJobParams params);

  /// Delete a job
  Future<void> deleteJob(String id);

  /// Toggle job active status
  Future<JobEntity> toggleJobActive(String id);

  /// Check if user has applied to a job
  Future<bool> hasApplied(String jobId);

  /// Get user's application for a job
  Future<JobApplicationEntity?> getMyApplication(String jobId);

  /// Apply to a job
  Future<JobApplicationEntity> applyToJob(ApplyToJobParams params);

  /// Withdraw application
  Future<JobApplicationEntity> withdrawApplication(String applicationId);

  /// Get my applications
  Future<List<JobApplicationEntity>> getMyApplications({
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  });

  /// Get applications for a job (company side)
  Future<List<JobApplicationEntity>> getJobApplications(
    String jobId, {
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  });

  /// Update application status
  Future<JobApplicationEntity> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? notes,
    String? rejectionReason,
  });

  /// Schedule interview
  Future<JobApplicationEntity> scheduleInterview(
    String applicationId, {
    required DateTime interviewDate,
    String? location,
    String? notes,
  });

  /// Send job offer
  Future<JobApplicationEntity> sendOffer(
    String applicationId, {
    required double offeredSalary,
  });

  /// Accept job application (atomic operation)
  /// Returns false if no vacancy available
  Future<bool> acceptApplication(
    String applicationId, {
    double? offeredSalary,
  });

  /// Save job
  Future<void> saveJob(String jobId);

  /// Unsave job
  Future<void> unsaveJob(String jobId);

  /// Check if job is saved
  Future<bool> isJobSaved(String jobId);

  /// Get saved jobs
  Future<List<JobEntity>> getSavedJobs();

  /// Increment view count
  Future<void> incrementViewCount(String jobId);
}

class CreateJobParams {
  const CreateJobParams({
    required this.companyId,
    required this.title,
    required this.description,
    this.requirements,
    this.responsibilities,
    required this.jobType,
    this.location,
    this.isRemote = false,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'SAR',
    this.showSalary = true,
    this.experienceYearsMin = 0,
    this.experienceYearsMax,
    this.educationLevel,
    this.skillsRequired = const [],
    this.benefits = const [],
    required this.vacancyCount,
    this.applicationDeadline,
  });

  final String companyId;
  final String title;
  final String description;
  final String? requirements;
  final String? responsibilities;
  final JobType jobType;
  final String? location;
  final bool isRemote;
  final double? salaryMin;
  final double? salaryMax;
  final String salaryCurrency;
  final bool showSalary;
  final int experienceYearsMin;
  final int? experienceYearsMax;
  final String? educationLevel;
  final List<String> skillsRequired;
  final List<String> benefits;
  final int vacancyCount;
  final DateTime? applicationDeadline;

  Map<String, dynamic> toJson() => {
        'company_id': companyId,
        'title': title,
        'description': description,
        if (requirements != null) 'requirements': requirements,
        if (responsibilities != null) 'responsibilities': responsibilities,
        'job_type': jobType.value,
        if (location != null) 'location': location,
        'is_remote': isRemote,
        if (salaryMin != null) 'salary_min': salaryMin,
        if (salaryMax != null) 'salary_max': salaryMax,
        'salary_currency': salaryCurrency,
        'show_salary': showSalary,
        'experience_years_min': experienceYearsMin,
        if (experienceYearsMax != null) 'experience_years_max': experienceYearsMax,
        if (educationLevel != null) 'education_level': educationLevel,
        'skills_required': skillsRequired,
        'benefits': benefits,
        'vacancy_count': vacancyCount,
        if (applicationDeadline != null)
          'application_deadline': applicationDeadline!.toIso8601String(),
      };
}

class UpdateJobParams {
  const UpdateJobParams({
    this.title,
    this.description,
    this.requirements,
    this.responsibilities,
    this.jobType,
    this.location,
    this.isRemote,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
    this.showSalary,
    this.experienceYearsMin,
    this.experienceYearsMax,
    this.educationLevel,
    this.skillsRequired,
    this.benefits,
    this.vacancyCount,
    this.applicationDeadline,
    this.isActive,
  });

  final String? title;
  final String? description;
  final String? requirements;
  final String? responsibilities;
  final JobType? jobType;
  final String? location;
  final bool? isRemote;
  final double? salaryMin;
  final double? salaryMax;
  final String? salaryCurrency;
  final bool? showSalary;
  final int? experienceYearsMin;
  final int? experienceYearsMax;
  final String? educationLevel;
  final List<String>? skillsRequired;
  final List<String>? benefits;
  final int? vacancyCount;
  final DateTime? applicationDeadline;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (requirements != null) json['requirements'] = requirements;
    if (responsibilities != null) json['responsibilities'] = responsibilities;
    if (jobType != null) json['job_type'] = jobType!.value;
    if (location != null) json['location'] = location;
    if (isRemote != null) json['is_remote'] = isRemote;
    if (salaryMin != null) json['salary_min'] = salaryMin;
    if (salaryMax != null) json['salary_max'] = salaryMax;
    if (salaryCurrency != null) json['salary_currency'] = salaryCurrency;
    if (showSalary != null) json['show_salary'] = showSalary;
    if (experienceYearsMin != null) json['experience_years_min'] = experienceYearsMin;
    if (experienceYearsMax != null) json['experience_years_max'] = experienceYearsMax;
    if (educationLevel != null) json['education_level'] = educationLevel;
    if (skillsRequired != null) json['skills_required'] = skillsRequired;
    if (benefits != null) json['benefits'] = benefits;
    if (vacancyCount != null) json['vacancy_count'] = vacancyCount;
    if (applicationDeadline != null) {
      json['application_deadline'] = applicationDeadline!.toIso8601String();
    }
    if (isActive != null) json['is_active'] = isActive;
    return json;
  }
}

class ApplyToJobParams {
  const ApplyToJobParams({
    required this.jobId,
    this.coverLetter,
    this.resumeFile,
    this.expectedSalary,
    this.availabilityDate,
    this.answers = const {},
  });

  final String jobId;
  final String? coverLetter;
  final File? resumeFile;
  final double? expectedSalary;
  final DateTime? availabilityDate;
  final Map<String, dynamic> answers;
}
