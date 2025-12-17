import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.companyId,
    super.postedBy,
    required super.title,
    required super.description,
    super.requirements,
    super.responsibilities,
    required super.jobType,
    super.location,
    super.isRemote,
    super.salaryMin,
    super.salaryMax,
    super.salaryCurrency,
    super.showSalary,
    super.experienceYearsMin,
    super.experienceYearsMax,
    super.educationLevel,
    super.skillsRequired,
    super.benefits,
    required super.vacancyCount,
    super.acceptedCount,
    super.applicationDeadline,
    super.isActive,
    super.isFeatured,
    super.viewCount,
    super.applicationCount,
    required super.createdAt,
    required super.updatedAt,
    super.company,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    CompanyInfo? company;
    if (json['companies'] != null) {
      final c = json['companies'] as Map<String, dynamic>;
      company = CompanyInfo(
        id: c['id'] as String,
        name: c['name'] as String,
        logoUrl: c['logo_url'] as String?,
        isVerified: c['status'] == 'verified',
      );
    }

    return JobModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      postedBy: json['posted_by'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      requirements: json['requirements'] as String?,
      responsibilities: json['responsibilities'] as String?,
      jobType: JobType.fromString(json['job_type'] as String),
      location: json['location'] as String?,
      isRemote: json['is_remote'] as bool? ?? false,
      salaryMin: (json['salary_min'] as num?)?.toDouble(),
      salaryMax: (json['salary_max'] as num?)?.toDouble(),
      salaryCurrency: json['salary_currency'] as String? ?? 'SAR',
      showSalary: json['show_salary'] as bool? ?? true,
      experienceYearsMin: json['experience_years_min'] as int? ?? 0,
      experienceYearsMax: json['experience_years_max'] as int?,
      educationLevel: json['education_level'] as String?,
      skillsRequired: (json['skills_required'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      vacancyCount: json['vacancy_count'] as int? ?? 1,
      acceptedCount: json['accepted_count'] as int? ?? 0,
      applicationDeadline: json['application_deadline'] != null
          ? DateTime.parse(json['application_deadline'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      applicationCount: json['application_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      company: company,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'posted_by': postedBy,
      'title': title,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'job_type': jobType.value,
      'location': location,
      'is_remote': isRemote,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_currency': salaryCurrency,
      'show_salary': showSalary,
      'experience_years_min': experienceYearsMin,
      'experience_years_max': experienceYearsMax,
      'education_level': educationLevel,
      'skills_required': skillsRequired,
      'benefits': benefits,
      'vacancy_count': vacancyCount,
      'accepted_count': acceptedCount,
      'application_deadline': applicationDeadline?.toIso8601String(),
      'is_active': isActive,
      'is_featured': isFeatured,
      'view_count': viewCount,
      'application_count': applicationCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class JobApplicationModel extends JobApplicationEntity {
  const JobApplicationModel({
    required super.id,
    required super.jobId,
    required super.userId,
    required super.status,
    super.coverLetter,
    super.resumeUrl,
    super.expectedSalary,
    super.availabilityDate,
    super.answers,
    super.notes,
    super.rejectionReason,
    super.interviewDate,
    super.interviewLocation,
    super.interviewNotes,
    super.offeredSalary,
    super.offerDate,
    super.acceptedAt,
    super.rejectedAt,
    super.withdrawnAt,
    required super.createdAt,
    required super.updatedAt,
    super.job,
    super.applicant,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    JobEntity? job;
    if (json['jobs'] != null) {
      job = JobModel.fromJson(json['jobs'] as Map<String, dynamic>);
    }

    ApplicantInfo? applicant;
    if (json['profiles'] != null) {
      final p = json['profiles'] as Map<String, dynamic>;
      applicant = ApplicantInfo(
        id: p['id'] as String,
        fullName: p['full_name'] as String,
        email: p['email'] as String?,
        avatarUrl: p['avatar_url'] as String?,
        headline: p['headline'] as String?,
      );
    }

    return JobApplicationModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      userId: json['user_id'] as String,
      status: ApplicationStatus.fromString(json['status'] as String),
      coverLetter: json['cover_letter'] as String?,
      resumeUrl: json['resume_url'] as String?,
      expectedSalary: (json['expected_salary'] as num?)?.toDouble(),
      availabilityDate: json['availability_date'] != null
          ? DateTime.parse(json['availability_date'] as String)
          : null,
      answers: (json['answers'] as Map<String, dynamic>?) ?? {},
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      interviewDate: json['interview_date'] != null
          ? DateTime.parse(json['interview_date'] as String)
          : null,
      interviewLocation: json['interview_location'] as String?,
      interviewNotes: json['interview_notes'] as String?,
      offeredSalary: (json['offered_salary'] as num?)?.toDouble(),
      offerDate: json['offer_date'] != null
          ? DateTime.parse(json['offer_date'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      withdrawnAt: json['withdrawn_at'] != null
          ? DateTime.parse(json['withdrawn_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      job: job,
      applicant: applicant,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'user_id': userId,
      'status': status.value,
      'cover_letter': coverLetter,
      'resume_url': resumeUrl,
      'expected_salary': expectedSalary,
      'availability_date': availabilityDate?.toIso8601String(),
      'answers': answers,
      'notes': notes,
      'rejection_reason': rejectionReason,
      'interview_date': interviewDate?.toIso8601String(),
      'interview_location': interviewLocation,
      'interview_notes': interviewNotes,
      'offered_salary': offeredSalary,
      'offer_date': offerDate?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'withdrawn_at': withdrawnAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
