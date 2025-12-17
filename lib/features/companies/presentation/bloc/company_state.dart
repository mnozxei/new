part of 'company_bloc.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {
  const CompanyInitial();
}

class CompanyLoading extends CompanyState {
  const CompanyLoading();
}

class CompanyUploading extends CompanyState {
  const CompanyUploading({required this.type});

  final String type;

  @override
  List<Object?> get props => [type];
}

class CompanyError extends CompanyState {
  const CompanyError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class MyCompaniesLoaded extends CompanyState {
  const MyCompaniesLoaded({required this.companies});

  final List<CompanyEntity> companies;

  @override
  List<Object?> get props => [companies];
}

class CompanyDetailsLoaded extends CompanyState {
  const CompanyDetailsLoaded({
    required this.company,
    required this.isAdmin,
    required this.isFollowing,
  });

  final CompanyEntity company;
  final bool isAdmin;
  final bool isFollowing;

  @override
  List<Object?> get props => [company, isAdmin, isFollowing];
}

class VerifiedCompaniesLoaded extends CompanyState {
  const VerifiedCompaniesLoaded({required this.companies});

  final List<CompanyEntity> companies;

  @override
  List<Object?> get props => [companies];
}

class CompanySearchResults extends CompanyState {
  const CompanySearchResults({
    required this.companies,
    required this.query,
  });

  final List<CompanyEntity> companies;
  final String query;

  @override
  List<Object?> get props => [companies, query];
}

class CompanyCreated extends CompanyState {
  const CompanyCreated({required this.company});

  final CompanyEntity company;

  @override
  List<Object?> get props => [company];
}

class CompanyUpdated extends CompanyState {
  const CompanyUpdated({required this.company});

  final CompanyEntity company;

  @override
  List<Object?> get props => [company];
}

class CompanyDeleted extends CompanyState {
  const CompanyDeleted({required this.companyId});

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

class CompanyUploadComplete extends CompanyState {
  const CompanyUploadComplete({
    required this.type,
    required this.url,
  });

  final String type;
  final String url;

  @override
  List<Object?> get props => [type, url];
}

class VerificationSubmitted extends CompanyState {
  const VerificationSubmitted({required this.company});

  final CompanyEntity company;

  @override
  List<Object?> get props => [company];
}

class FollowToggled extends CompanyState {
  const FollowToggled({
    required this.companyId,
    required this.isFollowing,
  });

  final String companyId;
  final bool isFollowing;

  @override
  List<Object?> get props => [companyId, isFollowing];
}

class PendingVerificationsLoaded extends CompanyState {
  const PendingVerificationsLoaded({required this.companies});

  final List<CompanyEntity> companies;

  @override
  List<Object?> get props => [companies];
}

class VerificationApproved extends CompanyState {
  const VerificationApproved({required this.company});

  final CompanyEntity company;

  @override
  List<Object?> get props => [company];
}

class VerificationRejected extends CompanyState {
  const VerificationRejected({required this.company});

  final CompanyEntity company;

  @override
  List<Object?> get props => [company];
}
