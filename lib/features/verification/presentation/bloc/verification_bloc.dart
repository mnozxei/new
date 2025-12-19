import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/verification_gate.dart';
import '../../domain/entities/verification_entity.dart';
import '../../domain/repositories/verification_repository.dart';

part 'verification_event.dart';
part 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc({
    required VerificationRepository repository,
  })  : _repository = repository,
        super(const VerificationState()) {
    on<LoadVerificationStatus>(_onLoadVerificationStatus);
    on<LoadInstructorApplication>(_onLoadInstructorApplication);
    on<SubmitInstructorApplication>(_onSubmitInstructorApplication);
    on<UpdateInstructorApplication>(_onUpdateInstructorApplication);
    on<WithdrawInstructorApplication>(_onWithdrawInstructorApplication);
    on<UploadVerificationDocument>(_onUploadVerificationDocument);
    on<DeleteVerificationDocument>(_onDeleteVerificationDocument);
    on<ReplaceVerificationDocument>(_onReplaceVerificationDocument);
    on<LoadCompanyVerification>(_onLoadCompanyVerification);
    on<SubmitCompanyVerification>(_onSubmitCompanyVerification);
    on<LoadPendingInstructorApplications>(_onLoadPendingInstructorApplications);
    on<LoadPendingCompanyVerifications>(_onLoadPendingCompanyVerifications);
    on<ApproveInstructorApplication>(_onApproveInstructorApplication);
    on<RejectInstructorApplication>(_onRejectInstructorApplication);
    on<ApproveCompanyVerification>(_onApproveCompanyVerification);
    on<RejectCompanyVerification>(_onRejectCompanyVerification);
  }

  final VerificationRepository _repository;

  Future<void> _onLoadVerificationStatus(
    LoadVerificationStatus event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.loading, clearError: true));

    try {
      final status = await _repository.getMyVerificationStatus();
      final canApply = await _repository.canApplyAsInstructor();
      final instructorReqs = _repository.getInstructorRequirements();
      final companyReqs = _repository.getCompanyRequirements();

      emit(state.copyWith(
        status: VerificationStateStatus.loaded,
        verificationStatus: status,
        canApplyAsInstructor: canApply,
        instructorRequirements: instructorReqs,
        companyRequirements: companyReqs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: 'فشل تحميل حالة التوثيق',
      ));
    }
  }

  Future<void> _onLoadInstructorApplication(
    LoadInstructorApplication event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.loading, clearError: true));

    try {
      final application = await _repository.getMyInstructorApplication();
      List<VerificationDocument> documents = [];

      if (application != null) {
        documents = await _repository.getApplicationDocuments(application.id);
      }

      emit(state.copyWith(
        status: VerificationStateStatus.loaded,
        instructorApplication: application,
        documents: documents,
        verificationStatus: application?.status ?? VerificationStatus.notSubmitted,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: 'فشل تحميل طلب التوثيق',
      ));
    }
  }

  Future<void> _onSubmitInstructorApplication(
    SubmitInstructorApplication event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.submitInstructorApplication(
      bio: event.bio,
      expertiseAreas: event.expertiseAreas,
      yearsOfExperience: event.yearsOfExperience,
      portfolioUrl: event.portfolioUrl,
      linkedinUrl: event.linkedinUrl,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: VerificationStateStatus.success,
        instructorApplication: result.data,
        verificationStatus: VerificationStatus.pending,
        canApplyAsInstructor: false,
        successMessage: 'تم تقديم طلب التوثيق بنجاح',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل تقديم الطلب',
      ));
    }
  }

  Future<void> _onUpdateInstructorApplication(
    UpdateInstructorApplication event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.updateInstructorApplication(
      applicationId: event.applicationId,
      bio: event.bio,
      expertiseAreas: event.expertiseAreas,
      yearsOfExperience: event.yearsOfExperience,
      portfolioUrl: event.portfolioUrl,
      linkedinUrl: event.linkedinUrl,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: VerificationStateStatus.success,
        instructorApplication: result.data,
        successMessage: 'تم تحديث الطلب بنجاح',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل تحديث الطلب',
      ));
    }
  }

  Future<void> _onWithdrawInstructorApplication(
    WithdrawInstructorApplication event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.withdrawInstructorApplication(event.applicationId);

    if (result.isSuccess) {
      emit(state.copyWith(
        status: VerificationStateStatus.success,
        verificationStatus: VerificationStatus.notSubmitted,
        canApplyAsInstructor: true,
        clearApplication: true,
        successMessage: 'تم سحب الطلب بنجاح',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل سحب الطلب',
      ));
    }
  }

  Future<void> _onUploadVerificationDocument(
    UploadVerificationDocument event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(isUploading: true, uploadProgress: 0.0, clearError: true));

    final result = await _repository.uploadDocument(
      file: event.file,
      documentType: event.documentType,
      applicationId: event.applicationId,
      verificationId: event.verificationId,
      companyId: event.companyId,
      expiryDate: event.expiryDate,
    );

    if (result.isSuccess) {
      final updatedDocuments = [...state.documents, result.data!];
      emit(state.copyWith(
        documents: updatedDocuments,
        isUploading: false,
        uploadProgress: 1.0,
        successMessage: 'تم رفع المستند بنجاح',
      ));
    } else {
      emit(state.copyWith(
        isUploading: false,
        errorMessage: result.errorMessage ?? 'فشل رفع المستند',
      ));
    }
  }

  Future<void> _onDeleteVerificationDocument(
    DeleteVerificationDocument event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.deleteDocument(event.documentId);

    if (result.isSuccess) {
      final updatedDocuments = state.documents
          .where((doc) => doc.id != event.documentId)
          .toList();
      emit(state.copyWith(
        status: VerificationStateStatus.success,
        documents: updatedDocuments,
        successMessage: 'تم حذف المستند',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل حذف المستند',
      ));
    }
  }

  Future<void> _onReplaceVerificationDocument(
    ReplaceVerificationDocument event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(isUploading: true, clearError: true));

    final result = await _repository.replaceDocument(
      documentId: event.documentId,
      newFile: event.newFile,
      newExpiryDate: event.newExpiryDate,
    );

    if (result.isSuccess) {
      final updatedDocuments = state.documents.map((doc) {
        if (doc.id == event.documentId) {
          return result.data!;
        }
        return doc;
      }).toList();

      emit(state.copyWith(
        documents: updatedDocuments,
        isUploading: false,
        successMessage: 'تم تحديث المستند',
      ));
    } else {
      emit(state.copyWith(
        isUploading: false,
        errorMessage: result.errorMessage ?? 'فشل تحديث المستند',
      ));
    }
  }

  Future<void> _onLoadCompanyVerification(
    LoadCompanyVerification event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.loading, clearError: true));

    try {
      final verification = await _repository.getCompanyVerification(event.companyId);
      List<VerificationDocument> documents = [];

      if (verification != null) {
        documents = await _repository.getCompanyDocuments(verification.id);
      }

      emit(state.copyWith(
        status: VerificationStateStatus.loaded,
        companyVerification: verification,
        documents: documents,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: 'فشل تحميل توثيق الشركة',
      ));
    }
  }

  Future<void> _onSubmitCompanyVerification(
    SubmitCompanyVerification event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.submitCompanyVerification(
      companyId: event.companyId,
      companyType: event.companyType,
      employeeCountRange: event.employeeCountRange,
      industry: event.industry,
      websiteUrl: event.websiteUrl,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: VerificationStateStatus.success,
        companyVerification: result.data,
        successMessage: 'تم تقديم طلب توثيق الشركة',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل تقديم الطلب',
      ));
    }
  }

  // ==================== Admin Handlers ====================

  Future<void> _onLoadPendingInstructorApplications(
    LoadPendingInstructorApplications event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.loading, clearError: true));

    try {
      final applications = await _repository.getPendingInstructorApplications(
        limit: event.limit,
        offset: event.offset,
      );

      emit(state.copyWith(
        status: VerificationStateStatus.loaded,
        pendingInstructorApplications: applications,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: 'فشل تحميل طلبات التوثيق',
      ));
    }
  }

  Future<void> _onLoadPendingCompanyVerifications(
    LoadPendingCompanyVerifications event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.loading, clearError: true));

    try {
      final verifications = await _repository.getPendingCompanyVerifications(
        limit: event.limit,
        offset: event.offset,
      );

      emit(state.copyWith(
        status: VerificationStateStatus.loaded,
        pendingCompanyVerifications: verifications,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: 'فشل تحميل طلبات توثيق الشركات',
      ));
    }
  }

  Future<void> _onApproveInstructorApplication(
    ApproveInstructorApplication event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.approveInstructorApplication(
      applicationId: event.applicationId,
      adminNotes: event.adminNotes,
    );

    if (result.isSuccess) {
      // Remove from pending list
      final updatedPending = state.pendingInstructorApplications
          .where((app) => app.id != event.applicationId)
          .toList();

      emit(state.copyWith(
        status: VerificationStateStatus.success,
        pendingInstructorApplications: updatedPending,
        successMessage: 'تم قبول طلب التوثيق',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل قبول الطلب',
      ));
    }
  }

  Future<void> _onRejectInstructorApplication(
    RejectInstructorApplication event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.rejectInstructorApplication(
      applicationId: event.applicationId,
      reason: event.reason,
      adminNotes: event.adminNotes,
    );

    if (result.isSuccess) {
      // Remove from pending list
      final updatedPending = state.pendingInstructorApplications
          .where((app) => app.id != event.applicationId)
          .toList();

      emit(state.copyWith(
        status: VerificationStateStatus.success,
        pendingInstructorApplications: updatedPending,
        successMessage: 'تم رفض طلب التوثيق',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل رفض الطلب',
      ));
    }
  }

  Future<void> _onApproveCompanyVerification(
    ApproveCompanyVerification event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.approveCompanyVerification(
      verificationId: event.verificationId,
      adminNotes: event.adminNotes,
    );

    if (result.isSuccess) {
      // Remove from pending list
      final updatedPending = state.pendingCompanyVerifications
          .where((ver) => ver.id != event.verificationId)
          .toList();

      emit(state.copyWith(
        status: VerificationStateStatus.success,
        pendingCompanyVerifications: updatedPending,
        successMessage: 'تم قبول توثيق الشركة',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل قبول التوثيق',
      ));
    }
  }

  Future<void> _onRejectCompanyVerification(
    RejectCompanyVerification event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: VerificationStateStatus.submitting, clearError: true));

    final result = await _repository.rejectCompanyVerification(
      verificationId: event.verificationId,
      reason: event.reason,
      adminNotes: event.adminNotes,
    );

    if (result.isSuccess) {
      // Remove from pending list
      final updatedPending = state.pendingCompanyVerifications
          .where((ver) => ver.id != event.verificationId)
          .toList();

      emit(state.copyWith(
        status: VerificationStateStatus.success,
        pendingCompanyVerifications: updatedPending,
        successMessage: 'تم رفض توثيق الشركة',
      ));
    } else {
      emit(state.copyWith(
        status: VerificationStateStatus.failure,
        errorMessage: result.errorMessage ?? 'فشل رفض التوثيق',
      ));
    }
  }
}
