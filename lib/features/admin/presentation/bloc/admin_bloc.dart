import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({required AdminRepository repository})
      : _repository = repository,
        super(const AdminInitial()) {
    on<LoadAdminDashboard>(_onLoadDashboard);
    on<LoadPendingVerifications>(_onLoadPendingVerifications);
    on<ApproveVerification>(_onApproveVerification);
    on<RejectVerification>(_onRejectVerification);
    on<LoadPendingCourses>(_onLoadPendingCourses);
    on<ApproveCourse>(_onApproveCourse);
    on<RejectCourse>(_onRejectCourse);
    on<LoadContentReports>(_onLoadContentReports);
    on<ResolveReport>(_onResolveReport);
    on<DismissReport>(_onDismissReport);
    on<SuspendUser>(_onSuspendUser);
    on<UnsuspendUser>(_onUnsuspendUser);
    on<DeleteUser>(_onDeleteUser);
    on<SuspendCompany>(_onSuspendCompany);
    on<UnsuspendCompany>(_onUnsuspendCompany);
    on<UnpublishCourse>(_onUnpublishCourse);
    on<DeleteCourse>(_onDeleteCourse);
  }

  final AdminRepository _repository;

  Future<void> _onLoadDashboard(
    LoadAdminDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final stats = await _repository.getAdminStats();
      final activity = await _repository.getRecentActivity();
      final verifications = await _repository.getPendingVerifications(limit: 5);
      emit(AdminDashboardLoaded(
        stats: stats,
        recentActivity: activity,
        pendingVerifications: verifications,
      ));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadPendingVerifications(
    LoadPendingVerifications event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final verifications = await _repository.getPendingVerifications(
        type: event.type,
        limit: event.limit,
        offset: event.offset,
      );
      emit(PendingVerificationsLoaded(verifications));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onApproveVerification(
    ApproveVerification event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.approveVerification(event.id, notes: event.notes);
      emit(VerificationApproved(event.id));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onRejectVerification(
    RejectVerification event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.rejectVerification(event.id, event.reason);
      emit(VerificationRejected(event.id));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadPendingCourses(
    LoadPendingCourses event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final courses = await _repository.getPendingCourseReviews(
        limit: event.limit,
        offset: event.offset,
      );
      emit(PendingCoursesLoaded(courses));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onApproveCourse(
    ApproveCourse event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.approveCourse(event.courseId);
      emit(CourseApprovedState(event.courseId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onRejectCourse(
    RejectCourse event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.rejectCourse(event.courseId, event.reason);
      emit(CourseRejectedState(event.courseId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadContentReports(
    LoadContentReports event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final reports = await _repository.getContentReports(
        status: event.status,
        contentType: event.contentType,
        limit: event.limit,
        offset: event.offset,
      );
      emit(ContentReportsLoaded(reports));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onResolveReport(
    ResolveReport event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.resolveReport(event.reportId, event.resolution);
      emit(ReportResolved(event.reportId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDismissReport(
    DismissReport event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.dismissReport(event.reportId, event.reason);
      emit(ReportDismissed(event.reportId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onSuspendUser(
    SuspendUser event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.suspendUser(event.userId, event.reason, until: event.until);
      emit(UserSuspended(event.userId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUnsuspendUser(
    UnsuspendUser event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.unsuspendUser(event.userId);
      emit(UserUnsuspended(event.userId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.deleteUser(event.userId);
      emit(UserDeletedState(event.userId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onSuspendCompany(
    SuspendCompany event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.suspendCompany(event.companyId, event.reason);
      emit(CompanySuspended(event.companyId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUnsuspendCompany(
    UnsuspendCompany event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.unsuspendCompany(event.companyId);
      emit(CompanyUnsuspended(event.companyId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUnpublishCourse(
    UnpublishCourse event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.unpublishCourse(event.courseId, event.reason);
      emit(CourseUnpublishedState(event.courseId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteCourse(
    DeleteCourse event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminOperationLoading());
    try {
      await _repository.deleteCourse(event.courseId);
      emit(CourseDeletedState(event.courseId));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
