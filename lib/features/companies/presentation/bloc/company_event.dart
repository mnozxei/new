part of 'company_bloc.dart';

abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyCompanies extends CompanyEvent {
  const LoadMyCompanies();
}

class LoadCompanyDetails extends CompanyEvent {
  const LoadCompanyDetails({required this.companyId});

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

class LoadVerifiedCompanies extends CompanyEvent {
  const LoadVerifiedCompanies({
    this.industry,
    this.city,
    this.limit = 20,
    this.offset = 0,
  });

  final String? industry;
  final String? city;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [industry, city, limit, offset];
}

class SearchCompanies extends CompanyEvent {
  const SearchCompanies({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class CreateCompany extends CompanyEvent {
  const CreateCompany({required this.params});

  final CreateCompanyParams params;

  @override
  List<Object?> get props => [params];
}

class UpdateCompany extends CompanyEvent {
  const UpdateCompany({
    required this.companyId,
    required this.params,
  });

  final String companyId;
  final UpdateCompanyParams params;

  @override
  List<Object?> get props => [companyId, params];
}

class DeleteCompany extends CompanyEvent {
  const DeleteCompany({required this.companyId});

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

class UploadCompanyLogo extends CompanyEvent {
  const UploadCompanyLogo({
    required this.companyId,
    required this.file,
  });

  final String companyId;
  final File file;

  @override
  List<Object?> get props => [companyId, file];
}

class UploadCompanyCover extends CompanyEvent {
  const UploadCompanyCover({
    required this.companyId,
    required this.file,
  });

  final String companyId;
  final File file;

  @override
  List<Object?> get props => [companyId, file];
}

class UploadVerificationDocument extends CompanyEvent {
  const UploadVerificationDocument({
    required this.companyId,
    required this.file,
    required this.type,
  });

  final String companyId;
  final File file;
  final VerificationDocumentType type;

  @override
  List<Object?> get props => [companyId, file, type];
}

class SubmitVerification extends CompanyEvent {
  const SubmitVerification({
    required this.companyId,
    required this.documents,
  });

  final String companyId;
  final VerificationDocuments documents;

  @override
  List<Object?> get props => [companyId, documents];
}

class ToggleFollow extends CompanyEvent {
  const ToggleFollow({required this.companyId});

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

class LoadPendingVerifications extends CompanyEvent {
  const LoadPendingVerifications();
}

class ApproveVerification extends CompanyEvent {
  const ApproveVerification({
    required this.companyId,
    this.notes,
  });

  final String companyId;
  final String? notes;

  @override
  List<Object?> get props => [companyId, notes];
}

class RejectVerification extends CompanyEvent {
  const RejectVerification({
    required this.companyId,
    this.reason,
  });

  final String companyId;
  final String? reason;

  @override
  List<Object?> get props => [companyId, reason];
}
