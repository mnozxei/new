import 'package:equatable/equatable.dart';

enum JobType {
  fullTime('full_time', 'دوام كامل'),
  partTime('part_time', 'دوام جزئي'),
  contract('contract', 'عقد'),
  remote('remote', 'عن بعد'),
  internship('internship', 'تدريب');

  const JobType(this.value, this.label);
  final String value;
  final String label;

  static JobType fromString(String value) {
    return JobType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => JobType.fullTime,
    );
  }
}

enum JobStatus {
  draft('draft', 'مسودة'),
  published('published', 'منشور'),
  closed('closed', 'مغلق'),
  archived('archived', 'مؤرشف'),
  hidden('hidden', 'مخفي');

  const JobStatus(this.value, this.label);
  final String value;
  final String label;

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => JobStatus.draft,
    );
  }

  bool get isVisible => this == JobStatus.published;
  bool get canEdit => this == JobStatus.draft || this == JobStatus.published;
  bool get canPublish => this == JobStatus.draft;
  bool get canClose => this == JobStatus.published;
}

enum ExperienceLevel {
  entry('entry', 'مبتدئ'),
  junior('junior', 'خبرة بسيطة'),
  mid('mid', 'متوسط'),
  senior('senior', 'خبير'),
  lead('lead', 'قائد فريق'),
  manager('manager', 'مدير'),
  director('director', 'مدير تنفيذي'),
  executive('executive', 'تنفيذي أعلى');

  const ExperienceLevel(this.value, this.label);
  final String value;
  final String label;

  static ExperienceLevel fromString(String value) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExperienceLevel.mid,
    );
  }
}

enum LocationType {
  onsite('onsite', 'حضوري'),
  remote('remote', 'عن بعد'),
  hybrid('hybrid', 'هجين');

  const LocationType(this.value, this.label);
  final String value;
  final String label;

  static LocationType fromString(String value) {
    return LocationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LocationType.onsite,
    );
  }
}

enum ApplicationStatus {
  pending('pending', 'قيد المراجعة'),
  reviewing('reviewing', 'تحت المراجعة'),
  shortlisted('shortlisted', 'في القائمة المختصرة'),
  interview('interview', 'مقابلة'),
  offered('offered', 'عرض وظيفي'),
  accepted('accepted', 'مقبول'),
  rejected('rejected', 'مرفوض'),
  withdrawn('withdrawn', 'منسحب');

  const ApplicationStatus(this.value, this.label);
  final String value;
  final String label;

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ApplicationStatus.pending,
    );
  }

  bool get isActive => [
        ApplicationStatus.pending,
        ApplicationStatus.reviewing,
        ApplicationStatus.shortlisted,
        ApplicationStatus.interview,
        ApplicationStatus.offered,
      ].contains(this);

  bool get isFinal => [
        ApplicationStatus.accepted,
        ApplicationStatus.rejected,
        ApplicationStatus.withdrawn,
      ].contains(this);
}

class JobEntity extends Equatable {
  const JobEntity({
    required this.id,
    required this.companyId,
    this.postedBy,
    required this.title,
    required this.description,
    this.requirements,
    this.responsibilities,
    required this.jobType,
    this.status = JobStatus.draft,
    this.experienceLevel = ExperienceLevel.mid,
    this.locationType = LocationType.onsite,
    this.location,
    this.city,
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
    this.tags = const [],
    required this.vacancyCount,
    this.acceptedCount = 0,
    this.applicationDeadline,
    this.isActive = true,
    this.isFeatured = false,
    this.viewCount = 0,
    this.applicationCount = 0,
    this.publishedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.isSaved = false,
  });

  final String id;
  final String companyId;
  final String? postedBy;
  final String title;
  final String description;
  final String? requirements;
  final String? responsibilities;
  final JobType jobType;
  final JobStatus status;
  final ExperienceLevel experienceLevel;
  final LocationType locationType;
  final String? location;
  final String? city;
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
  final List<String> tags;
  final int vacancyCount;
  final int acceptedCount;
  final DateTime? applicationDeadline;
  final bool isActive;
  final bool isFeatured;
  final int viewCount;
  final int applicationCount;
  final DateTime? publishedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CompanyInfo? company;
  final bool isSaved;

  int get remainingVacancies => vacancyCount - acceptedCount;
  bool get hasAvailableVacancies => remainingVacancies > 0;
  bool get isExpired =>
      applicationDeadline != null && applicationDeadline!.isBefore(DateTime.now());
  bool get canApply => isActive && hasAvailableVacancies && !isExpired;

  String get salaryRange {
    if (!showSalary || (salaryMin == null && salaryMax == null)) {
      return 'غير محدد';
    }
    if (salaryMin != null && salaryMax != null) {
      return '${salaryMin!.toStringAsFixed(0)} - ${salaryMax!.toStringAsFixed(0)} $salaryCurrency';
    }
    if (salaryMin != null) {
      return 'من ${salaryMin!.toStringAsFixed(0)} $salaryCurrency';
    }
    return 'حتى ${salaryMax!.toStringAsFixed(0)} $salaryCurrency';
  }

  String get experienceRange {
    if (experienceYearsMax != null) {
      return '$experienceYearsMin - $experienceYearsMax سنوات';
    }
    if (experienceYearsMin > 0) {
      return '$experienceYearsMin+ سنوات';
    }
    return 'بدون خبرة';
  }

  JobEntity copyWith({
    String? id,
    String? companyId,
    String? postedBy,
    String? title,
    String? description,
    String? requirements,
    String? responsibilities,
    JobType? jobType,
    JobStatus? status,
    ExperienceLevel? experienceLevel,
    LocationType? locationType,
    String? location,
    String? city,
    bool? isRemote,
    double? salaryMin,
    double? salaryMax,
    String? salaryCurrency,
    bool? showSalary,
    int? experienceYearsMin,
    int? experienceYearsMax,
    String? educationLevel,
    List<String>? skillsRequired,
    List<String>? benefits,
    List<String>? tags,
    int? vacancyCount,
    int? acceptedCount,
    DateTime? applicationDeadline,
    bool? isActive,
    bool? isFeatured,
    int? viewCount,
    int? applicationCount,
    DateTime? publishedAt,
    DateTime? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    CompanyInfo? company,
    bool? isSaved,
  }) {
    return JobEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      postedBy: postedBy ?? this.postedBy,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      jobType: jobType ?? this.jobType,
      status: status ?? this.status,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      locationType: locationType ?? this.locationType,
      location: location ?? this.location,
      city: city ?? this.city,
      isRemote: isRemote ?? this.isRemote,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      showSalary: showSalary ?? this.showSalary,
      experienceYearsMin: experienceYearsMin ?? this.experienceYearsMin,
      experienceYearsMax: experienceYearsMax ?? this.experienceYearsMax,
      educationLevel: educationLevel ?? this.educationLevel,
      skillsRequired: skillsRequired ?? this.skillsRequired,
      benefits: benefits ?? this.benefits,
      tags: tags ?? this.tags,
      vacancyCount: vacancyCount ?? this.vacancyCount,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      applicationCount: applicationCount ?? this.applicationCount,
      publishedAt: publishedAt ?? this.publishedAt,
      closedAt: closedAt ?? this.closedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      company: company ?? this.company,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        postedBy,
        title,
        description,
        requirements,
        responsibilities,
        jobType,
        status,
        experienceLevel,
        locationType,
        location,
        city,
        isRemote,
        salaryMin,
        salaryMax,
        salaryCurrency,
        showSalary,
        experienceYearsMin,
        experienceYearsMax,
        educationLevel,
        skillsRequired,
        benefits,
        tags,
        vacancyCount,
        acceptedCount,
        applicationDeadline,
        isActive,
        isFeatured,
        viewCount,
        applicationCount,
        publishedAt,
        closedAt,
        createdAt,
        updatedAt,
        company,
        isSaved,
      ];
}

class CompanyInfo extends Equatable {
  const CompanyInfo({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isVerified = false,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final bool isVerified;

  @override
  List<Object?> get props => [id, name, logoUrl, isVerified];
}

class JobApplicationEntity extends Equatable {
  const JobApplicationEntity({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.status,
    this.coverLetter,
    this.resumeUrl,
    this.expectedSalary,
    this.availabilityDate,
    this.answers = const {},
    this.notes,
    this.rejectionReason,
    this.interviewDate,
    this.interviewLocation,
    this.interviewNotes,
    this.offeredSalary,
    this.offerDate,
    this.acceptedAt,
    this.rejectedAt,
    this.withdrawnAt,
    required this.createdAt,
    required this.updatedAt,
    this.job,
    this.applicant,
  });

  final String id;
  final String jobId;
  final String userId;
  final ApplicationStatus status;
  final String? coverLetter;
  final String? resumeUrl;
  final double? expectedSalary;
  final DateTime? availabilityDate;
  final Map<String, dynamic> answers;
  final String? notes;
  final String? rejectionReason;
  final DateTime? interviewDate;
  final String? interviewLocation;
  final String? interviewNotes;
  final double? offeredSalary;
  final DateTime? offerDate;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? withdrawnAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final JobEntity? job;
  final ApplicantInfo? applicant;

  bool get canWithdraw => status.isActive;
  bool get canAcceptOffer => status == ApplicationStatus.offered;

  JobApplicationEntity copyWith({
    String? id,
    String? jobId,
    String? userId,
    ApplicationStatus? status,
    String? coverLetter,
    String? resumeUrl,
    double? expectedSalary,
    DateTime? availabilityDate,
    Map<String, dynamic>? answers,
    String? notes,
    String? rejectionReason,
    DateTime? interviewDate,
    String? interviewLocation,
    String? interviewNotes,
    double? offeredSalary,
    DateTime? offerDate,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? withdrawnAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    JobEntity? job,
    ApplicantInfo? applicant,
  }) {
    return JobApplicationEntity(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      availabilityDate: availabilityDate ?? this.availabilityDate,
      answers: answers ?? this.answers,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      interviewNotes: interviewNotes ?? this.interviewNotes,
      offeredSalary: offeredSalary ?? this.offeredSalary,
      offerDate: offerDate ?? this.offerDate,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      withdrawnAt: withdrawnAt ?? this.withdrawnAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      job: job ?? this.job,
      applicant: applicant ?? this.applicant,
    );
  }

  @override
  List<Object?> get props => [
        id,
        jobId,
        userId,
        status,
        coverLetter,
        resumeUrl,
        expectedSalary,
        availabilityDate,
        answers,
        notes,
        rejectionReason,
        interviewDate,
        interviewLocation,
        interviewNotes,
        offeredSalary,
        offerDate,
        acceptedAt,
        rejectedAt,
        withdrawnAt,
        createdAt,
        updatedAt,
        job,
        applicant,
      ];
}

class ApplicantInfo extends Equatable {
  const ApplicantInfo({
    required this.id,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.headline,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? headline;

  @override
  List<Object?> get props => [id, fullName, email, avatarUrl, headline];
}
