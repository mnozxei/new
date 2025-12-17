import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../models/job_model.dart';

abstract class JobRemoteDataSource {
  Future<List<JobModel>> getJobs({
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
  Future<List<JobModel>> getFeaturedJobs({int limit = 10});
  Future<JobModel?> getJobById(String id);
  Future<JobModel> createJob(CreateJobParams params);
  Future<JobModel> updateJob(String id, UpdateJobParams params);
  Future<void> deleteJob(String id);
  Future<JobModel> toggleJobActive(String id);
  Future<bool> hasApplied(String jobId);
  Future<JobApplicationModel?> getMyApplication(String jobId);
  Future<JobApplicationModel> applyToJob(ApplyToJobParams params);
  Future<JobApplicationModel> withdrawApplication(String applicationId);
  Future<List<JobApplicationModel>> getMyApplications({
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  });
  Future<List<JobApplicationModel>> getJobApplications(
    String jobId, {
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  });
  Future<JobApplicationModel> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? notes,
    String? rejectionReason,
  });
  Future<JobApplicationModel> scheduleInterview(
    String applicationId, {
    required DateTime interviewDate,
    String? location,
    String? notes,
  });
  Future<JobApplicationModel> sendOffer(
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
  Future<List<JobModel>> getSavedJobs();
  Future<void> incrementViewCount(String jobId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  JobRemoteDataSourceImpl({required this.supabase});

  final SupabaseClient supabase;

  String get _userId => supabase.auth.currentUser!.id;

  static const String _jobsSelect = '''
    *,
    companies:company_id (
      id,
      name,
      logo_url,
      status
    )
  ''';

  static const String _applicationSelect = '''
    *,
    jobs:job_id (
      *,
      companies:company_id (
        id,
        name,
        logo_url,
        status
      )
    ),
    profiles:user_id (
      id,
      full_name,
      email,
      avatar_url,
      headline
    )
  ''';

  @override
  Future<List<JobModel>> getJobs({
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
    var query = supabase
        .from('jobs')
        .select(_jobsSelect)
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
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    final response = await query
        .order('is_featured', ascending: false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => JobModel.fromJson(json)).toList();
  }

  @override
  Future<List<JobModel>> getFeaturedJobs({int limit = 10}) async {
    final response = await supabase
        .from('jobs')
        .select(_jobsSelect)
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => JobModel.fromJson(json)).toList();
  }

  @override
  Future<JobModel?> getJobById(String id) async {
    final response = await supabase
        .from('jobs')
        .select(_jobsSelect)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return JobModel.fromJson(response);
  }

  @override
  Future<JobModel> createJob(CreateJobParams params) async {
    final data = {
      ...params.toJson(),
      'posted_by': _userId,
    };

    final response = await supabase
        .from('jobs')
        .insert(data)
        .select(_jobsSelect)
        .single();

    return JobModel.fromJson(response);
  }

  @override
  Future<JobModel> updateJob(String id, UpdateJobParams params) async {
    final response = await supabase
        .from('jobs')
        .update(params.toJson())
        .eq('id', id)
        .select(_jobsSelect)
        .single();

    return JobModel.fromJson(response);
  }

  @override
  Future<void> deleteJob(String id) async {
    await supabase.from('jobs').delete().eq('id', id);
  }

  @override
  Future<JobModel> toggleJobActive(String id) async {
    final job = await getJobById(id);
    if (job == null) throw Exception('Job not found');

    final response = await supabase
        .from('jobs')
        .update({'is_active': !job.isActive})
        .eq('id', id)
        .select(_jobsSelect)
        .single();

    return JobModel.fromJson(response);
  }

  @override
  Future<bool> hasApplied(String jobId) async {
    final response = await supabase
        .from('job_applications')
        .select('id')
        .eq('job_id', jobId)
        .eq('user_id', _userId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<JobApplicationModel?> getMyApplication(String jobId) async {
    final response = await supabase
        .from('job_applications')
        .select(_applicationSelect)
        .eq('job_id', jobId)
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return JobApplicationModel.fromJson(response);
  }

  @override
  Future<JobApplicationModel> applyToJob(ApplyToJobParams params) async {
    String? resumeUrl;
    if (params.resumeFile != null) {
      final fileName = 'resumes/$_userId/${params.jobId}_${DateTime.now().millisecondsSinceEpoch}.${params.resumeFile!.path.split('.').last}';
      await supabase.storage.from('job-applications').upload(fileName, params.resumeFile!);
      resumeUrl = supabase.storage.from('job-applications').getPublicUrl(fileName);
    }

    final data = {
      'job_id': params.jobId,
      'user_id': _userId,
      'status': 'pending',
      if (params.coverLetter != null) 'cover_letter': params.coverLetter,
      if (resumeUrl != null) 'resume_url': resumeUrl,
      if (params.expectedSalary != null) 'expected_salary': params.expectedSalary,
      if (params.availabilityDate != null)
        'availability_date': params.availabilityDate!.toIso8601String(),
      if (params.answers.isNotEmpty) 'answers': params.answers,
    };

    final response = await supabase
        .from('job_applications')
        .insert(data)
        .select(_applicationSelect)
        .single();

    // Increment application count
    await supabase.rpc('increment', params: {
      'table_name': 'jobs',
      'row_id': params.jobId,
      'column_name': 'application_count',
    });

    return JobApplicationModel.fromJson(response);
  }

  @override
  Future<JobApplicationModel> withdrawApplication(String applicationId) async {
    final response = await supabase
        .from('job_applications')
        .update({
          'status': 'withdrawn',
          'withdrawn_at': DateTime.now().toIso8601String(),
        })
        .eq('id', applicationId)
        .select(_applicationSelect)
        .single();

    return JobApplicationModel.fromJson(response);
  }

  @override
  Future<List<JobApplicationModel>> getMyApplications({
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = supabase
        .from('job_applications')
        .select(_applicationSelect)
        .eq('user_id', _userId);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => JobApplicationModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<JobApplicationModel>> getJobApplications(
    String jobId, {
    ApplicationStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = supabase
        .from('job_applications')
        .select(_applicationSelect)
        .eq('job_id', jobId);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => JobApplicationModel.fromJson(json))
        .toList();
  }

  @override
  Future<JobApplicationModel> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? notes,
    String? rejectionReason,
  }) async {
    final data = <String, dynamic>{
      'status': status.value,
    };

    if (notes != null) data['notes'] = notes;
    if (rejectionReason != null) data['rejection_reason'] = rejectionReason;

    if (status == ApplicationStatus.rejected) {
      data['rejected_at'] = DateTime.now().toIso8601String();
    }

    final response = await supabase
        .from('job_applications')
        .update(data)
        .eq('id', applicationId)
        .select(_applicationSelect)
        .single();

    return JobApplicationModel.fromJson(response);
  }

  @override
  Future<JobApplicationModel> scheduleInterview(
    String applicationId, {
    required DateTime interviewDate,
    String? location,
    String? notes,
  }) async {
    final response = await supabase
        .from('job_applications')
        .update({
          'status': 'interview',
          'interview_date': interviewDate.toIso8601String(),
          if (location != null) 'interview_location': location,
          if (notes != null) 'interview_notes': notes,
        })
        .eq('id', applicationId)
        .select(_applicationSelect)
        .single();

    return JobApplicationModel.fromJson(response);
  }

  @override
  Future<JobApplicationModel> sendOffer(
    String applicationId, {
    required double offeredSalary,
  }) async {
    final response = await supabase
        .from('job_applications')
        .update({
          'status': 'offered',
          'offered_salary': offeredSalary,
          'offer_date': DateTime.now().toIso8601String(),
        })
        .eq('id', applicationId)
        .select(_applicationSelect)
        .single();

    return JobApplicationModel.fromJson(response);
  }

  @override
  Future<bool> acceptApplication(
    String applicationId, {
    double? offeredSalary,
  }) async {
    // Use the atomic function for acceptance
    final result = await supabase.rpc('accept_job_application', params: {
      'p_application_id': applicationId,
      if (offeredSalary != null) 'p_offered_salary': offeredSalary,
    });

    return result as bool;
  }

  @override
  Future<void> saveJob(String jobId) async {
    await supabase.from('saved_jobs').insert({
      'job_id': jobId,
      'user_id': _userId,
    });
  }

  @override
  Future<void> unsaveJob(String jobId) async {
    await supabase
        .from('saved_jobs')
        .delete()
        .eq('job_id', jobId)
        .eq('user_id', _userId);
  }

  @override
  Future<bool> isJobSaved(String jobId) async {
    final response = await supabase
        .from('saved_jobs')
        .select('id')
        .eq('job_id', jobId)
        .eq('user_id', _userId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<JobModel>> getSavedJobs() async {
    final response = await supabase
        .from('saved_jobs')
        .select('''
          job_id,
          jobs:job_id (
            $_jobsSelect
          )
        ''')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => JobModel.fromJson(json['jobs'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> incrementViewCount(String jobId) async {
    await supabase.rpc('increment', params: {
      'table_name': 'jobs',
      'row_id': jobId,
      'column_name': 'view_count',
    });
  }
}
