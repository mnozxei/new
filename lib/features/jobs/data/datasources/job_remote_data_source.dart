import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';

abstract class JobRemoteDataSource {
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
  Future<List<JobEntity>> getFeaturedJobs({int limit = 10});
  Future<JobEntity?> getJobById(String id);
  Future<JobEntity> createJob(CreateJobParams params);
  Future<JobEntity> updateJob(String id, UpdateJobParams params);
  Future<void> deleteJob(String id);
  Future<JobEntity> toggleJobActive(String id);
  Future<bool> hasApplied(String jobId);
  Future<JobApplicationEntity?> getMyApplication(String jobId);
  Future<JobApplicationEntity> applyToJob(ApplyToJobParams params);
  Future<JobApplicationEntity> withdrawApplication(String applicationId);
  Future<List<JobApplicationEntity>> getMyApplications({
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  });
  Future<List<JobApplicationEntity>> getJobApplications(
    String jobId, {
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  });
  Future<JobApplicationEntity> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? notes,
    String? rejectionReason,
  });
  Future<JobApplicationEntity> scheduleInterview(
    String applicationId, {
    required DateTime interviewDate,
    String? location,
    String? notes,
  });
  Future<JobApplicationEntity> sendOffer(
    String applicationId, {
    required double offeredSalary,
  });
  Future<bool> acceptApplication(
    String applicationId, {
    double? offeredSalary,
  });
  Future<void> saveJob(String jobId);
  Future<void> unsaveJob(String jobId);
  Future<bool> isJobSaved(String jobId);
  Future<List<JobEntity>> getSavedJobs();
  Future<void> incrementViewCount(String jobId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  JobRemoteDataSourceImpl({required this.supabaseClient});

  final SupabaseClient supabaseClient;

  String get _userId => supabaseClient.auth.currentUser!.id;

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
  }) async {
    var query = supabaseClient
        .from('jobs')
        .select('*, company:companies(*)')
        .eq('is_active', true);

    if (companyId != null) {
      query = query.eq('company_id', companyId);
    }
    if (jobType != null) {
      query = query.eq('job_type', jobType.value);
    }
    if (location != null) {
      query = query.ilike('location', '%$location%');
    }
    if (isRemote != null) {
      query = query.eq('is_remote', isRemote);
    }
    if (minExperience != null) {
      query = query.gte('experience_years_min', minExperience);
    }
    if (maxExperience != null) {
      query = query.lte('experience_years_max', maxExperience);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => JobEntity.fromJson(json)).toList();
  }

  @override
  Future<List<JobEntity>> getFeaturedJobs({int limit = 10}) async {
    final response = await supabaseClient
        .from('jobs')
        .select('*, company:companies(*)')
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => JobEntity.fromJson(json)).toList();
  }

  @override
  Future<JobEntity?> getJobById(String id) async {
    final response = await supabaseClient
        .from('jobs')
        .select('*, company:companies(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return JobEntity.fromJson(response);
  }

  @override
  Future<JobEntity> createJob(CreateJobParams params) async {
    final response = await supabaseClient
        .from('jobs')
        .insert(params.toJson())
        .select('*, company:companies(*)')
        .single();

    return JobEntity.fromJson(response);
  }

  @override
  Future<JobEntity> updateJob(String id, UpdateJobParams params) async {
    final response = await supabaseClient
        .from('jobs')
        .update(params.toJson())
        .eq('id', id)
        .select('*, company:companies(*)')
        .single();

    return JobEntity.fromJson(response);
  }

  @override
  Future<void> deleteJob(String id) async {
    await supabaseClient.from('jobs').delete().eq('id', id);
  }

  @override
  Future<JobEntity> toggleJobActive(String id) async {
    final current = await getJobById(id);
    if (current == null) {
      throw Exception('Job not found');
    }

    final response = await supabaseClient
        .from('jobs')
        .update({'is_active': !current.isActive})
        .eq('id', id)
        .select('*, company:companies(*)')
        .single();

    return JobEntity.fromJson(response);
  }

  @override
  Future<bool> hasApplied(String jobId) async {
    final response = await supabaseClient
        .from('job_applications')
        .select('id')
        .eq('job_id', jobId)
        .eq('applicant_id', _userId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<JobApplicationEntity?> getMyApplication(String jobId) async {
    final response = await supabaseClient
        .from('job_applications')
        .select('*, job:jobs(*, company:companies(*))')
        .eq('job_id', jobId)
        .eq('applicant_id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return JobApplicationEntity.fromJson(response);
  }

  @override
  Future<JobApplicationEntity> applyToJob(ApplyToJobParams params) async {
    String? resumeUrl;
    if (params.resumeFile != null) {
      final fileName = '${_userId}_${params.jobId}_${DateTime.now().millisecondsSinceEpoch}.${params.resumeFile!.path.split('.').last}';
      final path = 'applications/$_userId/$fileName';

      await supabaseClient.storage.from('resumes').upload(path, params.resumeFile!);
      resumeUrl = supabaseClient.storage.from('resumes').getPublicUrl(path);
    }

    final response = await supabaseClient.from('job_applications').insert({
      'job_id': params.jobId,
      'applicant_id': _userId,
      if (params.coverLetter != null) 'cover_letter': params.coverLetter,
      if (resumeUrl != null) 'resume_url': resumeUrl,
      if (params.expectedSalary != null) 'expected_salary': params.expectedSalary,
      if (params.availabilityDate != null)
        'availability_date': params.availabilityDate!.toIso8601String(),
      if (params.answers.isNotEmpty) 'answers': params.answers,
    }).select('*, job:jobs(*, company:companies(*))').single();

    return JobApplicationEntity.fromJson(response);
  }

  @override
  Future<JobApplicationEntity> withdrawApplication(String applicationId) async {
    final response = await supabaseClient
        .from('job_applications')
        .update({'status': 'withdrawn'})
        .eq('id', applicationId)
        .select('*, job:jobs(*, company:companies(*))')
        .single();

    return JobApplicationEntity.fromJson(response);
  }

  @override
  Future<List<JobApplicationEntity>> getMyApplications({
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = supabaseClient
        .from('job_applications')
        .select('*, job:jobs(*, company:companies(*))')
        .eq('applicant_id', _userId);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => JobApplicationEntity.fromJson(json)).toList();
  }

  @override
  Future<List<JobApplicationEntity>> getJobApplications(
    String jobId, {
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = supabaseClient
        .from('job_applications')
        .select('*, job:jobs(*, company:companies(*)), applicant:profiles(*)')
        .eq('job_id', jobId);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => JobApplicationEntity.fromJson(json)).toList();
  }

  @override
  Future<JobApplicationEntity> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? notes,
    String? rejectionReason,
  }) async {
    final response = await supabaseClient
        .from('job_applications')
        .update({
          'status': status.value,
          if (notes != null) 'notes': notes,
          if (rejectionReason != null) 'rejection_reason': rejectionReason,
        })
        .eq('id', applicationId)
        .select('*, job:jobs(*, company:companies(*))')
        .single();

    return JobApplicationEntity.fromJson(response);
  }

  @override
  Future<JobApplicationEntity> scheduleInterview(
    String applicationId, {
    required DateTime interviewDate,
    String? location,
    String? notes,
  }) async {
    final response = await supabaseClient
        .from('job_applications')
        .update({
          'status': 'interview_scheduled',
          'interview_date': interviewDate.toIso8601String(),
          if (location != null) 'interview_location': location,
          if (notes != null) 'notes': notes,
        })
        .eq('id', applicationId)
        .select('*, job:jobs(*, company:companies(*))')
        .single();

    return JobApplicationEntity.fromJson(response);
  }

  @override
  Future<JobApplicationEntity> sendOffer(
    String applicationId, {
    required double offeredSalary,
  }) async {
    final response = await supabaseClient
        .from('job_applications')
        .update({
          'status': 'offer_sent',
          'offered_salary': offeredSalary,
        })
        .eq('id', applicationId)
        .select('*, job:jobs(*, company:companies(*))')
        .single();

    return JobApplicationEntity.fromJson(response);
  }

  @override
  Future<bool> acceptApplication(
    String applicationId, {
    double? offeredSalary,
  }) async {
    final result = await supabaseClient.rpc('accept_job_application', params: {
      'p_application_id': applicationId,
      if (offeredSalary != null) 'p_offered_salary': offeredSalary,
    });

    return result == true;
  }

  @override
  Future<void> saveJob(String jobId) async {
    await supabaseClient.from('saved_jobs').insert({
      'job_id': jobId,
      'user_id': _userId,
    });
  }

  @override
  Future<void> unsaveJob(String jobId) async {
    await supabaseClient
        .from('saved_jobs')
        .delete()
        .eq('job_id', jobId)
        .eq('user_id', _userId);
  }

  @override
  Future<bool> isJobSaved(String jobId) async {
    final response = await supabaseClient
        .from('saved_jobs')
        .select('id')
        .eq('job_id', jobId)
        .eq('user_id', _userId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<JobEntity>> getSavedJobs() async {
    final response = await supabaseClient
        .from('saved_jobs')
        .select('job:jobs(*, company:companies(*))')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => JobEntity.fromJson(json['job']))
        .toList();
  }

  @override
  Future<void> incrementViewCount(String jobId) async {
    await supabaseClient.rpc('increment_job_view_count', params: {
      'p_job_id': jobId,
    });
  }
}
