part of 'verification_bloc.dart';

enum VerificationStateStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
}

class VerificationState extends Equatable {
  const VerificationState({
    this.status = VerificationStateStatus.initial,
    this.verificationStatus = VerificationStatus.notSubmitted,
    this.instructorApplication,
    this.companyVerification,
    this.documents = const [],
    this.pendingInstructorApplications = const [],
    this.pendingCompanyVerifications = const [],
    this.canApplyAsInstructor = true,
    this.instructorRequirements = const [],
    this.companyRequirements = const [],
    this.errorMessage,
    this.successMessage,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  final VerificationStateStatus status;
  final VerificationStatus verificationStatus;
  final InstructorApplication? instructorApplication;
  final CompanyVerificationRequest? companyVerification;
  final List<VerificationDocument> documents;
  final List<InstructorApplication> pendingInstructorApplications;
  final List<CompanyVerificationRequest> pendingCompanyVerifications;
  final bool canApplyAsInstructor;
  final List<VerificationRequirement> instructorRequirements;
  final List<VerificationRequirement> companyRequirements;
  final String? errorMessage;
  final String? successMessage;
  final bool isUploading;
  final double uploadProgress;

  bool get isLoading => status == VerificationStateStatus.loading;
  bool get isSubmitting => status == VerificationStateStatus.submitting;
  bool get hasApplication => instructorApplication != null;
  bool get hasPendingApplication =>
      instructorApplication?.status == VerificationStatus.pending;
  bool get isApproved =>
      verificationStatus == VerificationStatus.approved;
  bool get isRejected =>
      verificationStatus == VerificationStatus.rejected;
  bool get isPending =>
      verificationStatus == VerificationStatus.pending;

  VerificationState copyWith({
    VerificationStateStatus? status,
    VerificationStatus? verificationStatus,
    InstructorApplication? instructorApplication,
    CompanyVerificationRequest? companyVerification,
    List<VerificationDocument>? documents,
    List<InstructorApplication>? pendingInstructorApplications,
    List<CompanyVerificationRequest>? pendingCompanyVerifications,
    bool? canApplyAsInstructor,
    List<VerificationRequirement>? instructorRequirements,
    List<VerificationRequirement>? companyRequirements,
    String? errorMessage,
    String? successMessage,
    bool? isUploading,
    double? uploadProgress,
    bool clearApplication = false,
    bool clearCompanyVerification = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return VerificationState(
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      instructorApplication: clearApplication
          ? null
          : (instructorApplication ?? this.instructorApplication),
      companyVerification: clearCompanyVerification
          ? null
          : (companyVerification ?? this.companyVerification),
      documents: documents ?? this.documents,
      pendingInstructorApplications:
          pendingInstructorApplications ?? this.pendingInstructorApplications,
      pendingCompanyVerifications:
          pendingCompanyVerifications ?? this.pendingCompanyVerifications,
      canApplyAsInstructor: canApplyAsInstructor ?? this.canApplyAsInstructor,
      instructorRequirements:
          instructorRequirements ?? this.instructorRequirements,
      companyRequirements: companyRequirements ?? this.companyRequirements,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object?> get props => [
        status,
        verificationStatus,
        instructorApplication,
        companyVerification,
        documents,
        pendingInstructorApplications,
        pendingCompanyVerifications,
        canApplyAsInstructor,
        instructorRequirements,
        companyRequirements,
        errorMessage,
        successMessage,
        isUploading,
        uploadProgress,
      ];
}
