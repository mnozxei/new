import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';

part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc({required this.repository}) : super(const CompanyInitial()) {
    on<LoadMyCompanies>(_onLoadMyCompanies);
    on<LoadCompanyDetails>(_onLoadCompanyDetails);
    on<LoadVerifiedCompanies>(_onLoadVerifiedCompanies);
    on<SearchCompanies>(_onSearchCompanies);
    on<CreateCompany>(_onCreateCompany);
    on<UpdateCompany>(_onUpdateCompany);
    on<DeleteCompany>(_onDeleteCompany);
    on<UploadCompanyLogo>(_onUploadCompanyLogo);
    on<UploadCompanyCover>(_onUploadCompanyCover);
    on<UploadVerificationDocument>(_onUploadVerificationDocument);
    on<SubmitVerification>(_onSubmitVerification);
    on<ToggleFollow>(_onToggleFollow);
    on<LoadPendingVerifications>(_onLoadPendingVerifications);
    on<ApproveVerification>(_onApproveVerification);
    on<RejectVerification>(_onRejectVerification);
  }

  final CompanyRepository repository;

  Future<void> _onLoadMyCompanies(
    LoadMyCompanies event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final companies = await repository.getMyCompanies();
      emit(MyCompaniesLoaded(companies: companies));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onLoadCompanyDetails(
    LoadCompanyDetails event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final company = await repository.getCompanyById(event.companyId);
      if (company == null) {
        emit(const CompanyError(message: 'Company not found'));
        return;
      }
      final isAdmin = await repository.isCompanyAdmin(event.companyId);
      final isFollowing = await repository.isFollowing(event.companyId);
      emit(CompanyDetailsLoaded(
        company: company,
        isAdmin: isAdmin,
        isFollowing: isFollowing,
      ));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onLoadVerifiedCompanies(
    LoadVerifiedCompanies event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final companies = await repository.getVerifiedCompanies(
        industry: event.industry,
        city: event.city,
        limit: event.limit,
        offset: event.offset,
      );
      emit(VerifiedCompaniesLoaded(companies: companies));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onSearchCompanies(
    SearchCompanies event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final companies = await repository.searchCompanies(event.query);
      emit(CompanySearchResults(companies: companies, query: event.query));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onCreateCompany(
    CreateCompany event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final company = await repository.createCompany(event.params);
      emit(CompanyCreated(company: company));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCompany(
    UpdateCompany event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final company = await repository.updateCompany(event.companyId, event.params);
      emit(CompanyUpdated(company: company));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCompany(
    DeleteCompany event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      await repository.deleteCompany(event.companyId);
      emit(CompanyDeleted(companyId: event.companyId));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onUploadCompanyLogo(
    UploadCompanyLogo event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyUploading(type: 'logo'));
    try {
      final url = await repository.uploadLogo(event.companyId, event.file);
      emit(CompanyUploadComplete(type: 'logo', url: url));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onUploadCompanyCover(
    UploadCompanyCover event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyUploading(type: 'cover'));
    try {
      final url = await repository.uploadCover(event.companyId, event.file);
      emit(CompanyUploadComplete(type: 'cover', url: url));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onUploadVerificationDocument(
    UploadVerificationDocument event,
    Emitter<CompanyState> emit,
  ) async {
    final typeStr = switch (event.type) {
      VerificationDocumentType.commercialRegister => 'commercial_register',
      VerificationDocumentType.taxCertificate => 'tax_certificate',
      VerificationDocumentType.authorizationLetter => 'authorization_letter',
    };
    emit(CompanyUploading(type: typeStr));
    try {
      final url = await repository.uploadVerificationDocument(
        event.companyId,
        event.file,
        event.type,
      );
      emit(CompanyUploadComplete(type: typeStr, url: url));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onSubmitVerification(
    SubmitVerification event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final company = await repository.submitVerification(
        event.companyId,
        event.documents,
      );
      emit(VerificationSubmitted(company: company));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onToggleFollow(
    ToggleFollow event,
    Emitter<CompanyState> emit,
  ) async {
    try {
      final isCurrentlyFollowing = await repository.isFollowing(event.companyId);
      if (isCurrentlyFollowing) {
        await repository.unfollowCompany(event.companyId);
      } else {
        await repository.followCompany(event.companyId);
      }
      emit(FollowToggled(
        companyId: event.companyId,
        isFollowing: !isCurrentlyFollowing,
      ));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onLoadPendingVerifications(
    LoadPendingVerifications event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final companies = await repository.getPendingVerifications();
      emit(PendingVerificationsLoaded(companies: companies));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onApproveVerification(
    ApproveVerification event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final company = await repository.approveVerification(
        event.companyId,
        notes: event.notes,
      );
      emit(VerificationApproved(company: company));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }

  Future<void> _onRejectVerification(
    RejectVerification event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());
    try {
      final company = await repository.rejectVerification(
        event.companyId,
        reason: event.reason,
      );
      emit(VerificationRejected(company: company));
    } catch (e) {
      emit(CompanyError(message: e.toString()));
    }
  }
}
