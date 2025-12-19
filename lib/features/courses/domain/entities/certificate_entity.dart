import 'package:equatable/equatable.dart';

/// Certificate status
enum CertificateStatus {
  pending,
  issued,
  revoked;

  static CertificateStatus fromString(String value) {
    return CertificateStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => CertificateStatus.pending,
    );
  }

  bool get isIssued => this == CertificateStatus.issued;
  bool get isRevoked => this == CertificateStatus.revoked;
}

/// Certificate entity representing a course completion certificate
class CertificateEntity extends Equatable {
  const CertificateEntity({
    required this.id,
    required this.enrollmentId,
    required this.courseId,
    required this.userId,
    required this.serialNumber,
    this.status = CertificateStatus.issued,
    this.courseName,
    this.studentName,
    this.instructorName,
    this.companyName,
    this.pdfUrl,
    this.verificationUrl,
    this.qrCodeData,
    required this.issuedAt,
    this.revokedAt,
    this.revokedReason,
    required this.createdAt,
  });

  final String id;
  final String enrollmentId;
  final String courseId;
  final String userId;

  /// Unique serial number (e.g., "TAMAD-2024-ABC123")
  final String serialNumber;

  final CertificateStatus status;

  /// Cached data for display (may be null)
  final String? courseName;
  final String? studentName;
  final String? instructorName;
  final String? companyName;

  /// URL to the generated PDF certificate
  final String? pdfUrl;

  /// URL for verification (e.g., "https://tamad.hub/verify/TAMAD-2024-ABC123")
  final String? verificationUrl;

  /// QR code data (typically the verification URL)
  final String? qrCodeData;

  final DateTime issuedAt;
  final DateTime? revokedAt;
  final String? revokedReason;
  final DateTime createdAt;

  /// Check if certificate is valid (issued and not revoked)
  bool get isValid => status == CertificateStatus.issued;

  /// Get verification URL or generate from serial
  String getVerificationUrl(String baseUrl) {
    return verificationUrl ?? '$baseUrl/verify/$serialNumber';
  }

  CertificateEntity copyWith({
    String? id,
    String? enrollmentId,
    String? courseId,
    String? userId,
    String? serialNumber,
    CertificateStatus? status,
    String? courseName,
    String? studentName,
    String? instructorName,
    String? companyName,
    String? pdfUrl,
    String? verificationUrl,
    String? qrCodeData,
    DateTime? issuedAt,
    DateTime? revokedAt,
    String? revokedReason,
    DateTime? createdAt,
  }) {
    return CertificateEntity(
      id: id ?? this.id,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      courseName: courseName ?? this.courseName,
      studentName: studentName ?? this.studentName,
      instructorName: instructorName ?? this.instructorName,
      companyName: companyName ?? this.companyName,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      verificationUrl: verificationUrl ?? this.verificationUrl,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      issuedAt: issuedAt ?? this.issuedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedReason: revokedReason ?? this.revokedReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        enrollmentId,
        courseId,
        userId,
        serialNumber,
        status,
        courseName,
        studentName,
        instructorName,
        companyName,
        pdfUrl,
        verificationUrl,
        qrCodeData,
        issuedAt,
        revokedAt,
        revokedReason,
        createdAt,
      ];
}

/// Certificate serial number generator
class CertificateSerialGenerator {
  CertificateSerialGenerator._();

  static const String _prefix = 'TAMAD';
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Generate a unique serial number
  /// Format: TAMAD-{YEAR}-{RANDOM6}
  /// Example: TAMAD-2024-ABC123
  static String generate() {
    final year = DateTime.now().year;
    final random = _generateRandomString(6);
    return '$_prefix-$year-$random';
  }

  static String _generateRandomString(int length) {
    final random = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      final index = (random ~/ (i + 1) + i * 7) % _chars.length;
      buffer.write(_chars[index]);
    }

    return buffer.toString();
  }

  /// Validate a serial number format
  static bool isValid(String serial) {
    final pattern = RegExp(r'^TAMAD-\d{4}-[A-Z0-9]{6}$');
    return pattern.hasMatch(serial);
  }
}

/// Verification result when checking a certificate
class CertificateVerificationResult extends Equatable {
  const CertificateVerificationResult({
    required this.isValid,
    this.certificate,
    this.errorMessage,
  });

  final bool isValid;
  final CertificateEntity? certificate;
  final String? errorMessage;

  factory CertificateVerificationResult.valid(CertificateEntity certificate) {
    return CertificateVerificationResult(
      isValid: true,
      certificate: certificate,
    );
  }

  factory CertificateVerificationResult.invalid(String message) {
    return CertificateVerificationResult(
      isValid: false,
      errorMessage: message,
    );
  }

  factory CertificateVerificationResult.notFound() {
    return const CertificateVerificationResult(
      isValid: false,
      errorMessage: 'الشهادة غير موجودة',
    );
  }

  factory CertificateVerificationResult.revoked(String reason) {
    return CertificateVerificationResult(
      isValid: false,
      errorMessage: 'الشهادة ملغاة: $reason',
    );
  }

  @override
  List<Object?> get props => [isValid, certificate, errorMessage];
}
