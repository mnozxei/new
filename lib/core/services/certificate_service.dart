import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Certificate entity for PDF generation
class CertificateData {
  const CertificateData({
    required this.id,
    required this.verifyCode,
    required this.holderName,
    required this.courseName,
    required this.instructorName,
    required this.issuerName,
    required this.issueDate,
    this.completionDate,
    this.score,
    this.courseHours,
    this.serialNumber,
  });

  final String id;
  final String verifyCode;
  final String holderName;
  final String courseName;
  final String instructorName;
  final String issuerName;
  final DateTime issueDate;
  final DateTime? completionDate;
  final double? score;
  final int? courseHours;
  final String? serialNumber;
}

/// Service for generating and managing certificates
class CertificateService {
  CertificateService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _uuid = Uuid();

  /// Generate a unique verification code
  String generateVerifyCode() {
    final uuid = _uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase();
    return 'TH-$uuid';
  }

  /// Generate certificate PDF
  Future<Uint8List> generatePdf(CertificateData certificate) async {
    final doc = pw.Document();

    // Load fonts
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  AppConstants.appName,
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: 28,
                    color: PdfColors.purple800,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'شهادة إتمام دورة تدريبية',
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: 24,
                    color: PdfColors.grey800,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 30),

                // Decorative line
                pw.Container(
                  width: 200,
                  height: 3,
                  color: PdfColors.purple300,
                ),
                pw.SizedBox(height: 30),

                // Certificate body
                pw.Text(
                  'تشهد منصة ${AppConstants.appName} بأن',
                  style: pw.TextStyle(font: arabicFont, fontSize: 16),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  certificate.holderName,
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: 32,
                    color: PdfColors.purple900,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'قد أتم بنجاح دورة',
                  style: pw.TextStyle(font: arabicFont, fontSize: 16),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  certificate.courseName,
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: 24,
                    color: PdfColors.purple700,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'المقدمة من: ${certificate.instructorName}',
                  style: pw.TextStyle(font: arabicFont, fontSize: 14),
                  textDirection: pw.TextDirection.rtl,
                ),
                if (certificate.courseHours != null) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'عدد الساعات: ${certificate.courseHours} ساعة',
                    style: pw.TextStyle(font: arabicFont, fontSize: 12, color: PdfColors.grey600),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
                if (certificate.score != null) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'الدرجة: ${certificate.score!.toStringAsFixed(1)}%',
                    style: pw.TextStyle(font: arabicFont, fontSize: 12, color: PdfColors.grey600),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
                pw.Spacer(),

                // Footer with signature
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // QR Code placeholder
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Center(
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              'QR',
                              style: pw.TextStyle(font: arabicFontBold, fontSize: 12),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              certificate.verifyCode,
                              style: pw.TextStyle(font: arabicFont, fontSize: 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Issue info
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'تاريخ الإصدار: ${dateFormat.format(certificate.issueDate)}',
                          style: pw.TextStyle(font: arabicFont, fontSize: 10),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'رمز التحقق: ${certificate.verifyCode}',
                          style: pw.TextStyle(font: arabicFont, fontSize: 10),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          '${AppConstants.appWebUrl}/verify/${certificate.verifyCode}',
                          style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.blue700),
                        ),
                      ],
                    ),
                    // Signature
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 100,
                          height: 1,
                          color: PdfColors.grey400,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          certificate.issuerName,
                          style: pw.TextStyle(font: arabicFont, fontSize: 10),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.Text(
                          'المدرب',
                          style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey500),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  /// Issue a new certificate
  Future<CertificateData?> issueCertificate({
    required String enrollmentId,
    required String courseId,
    required String userId,
    required String issuedBy,
    required String courseName,
    required String holderName,
    required String instructorName,
    required String issuerType,
    String? companyId,
    String? companyName,
    double? score,
    int? courseHours,
  }) async {
    try {
      final now = DateTime.now();

      final response = await _client.from('certificates').insert({
        'enrollment_id': enrollmentId,
        'course_id': courseId,
        'user_id': userId,
        'issued_by': issuedBy,
        'recipient_name': holderName,
        'course_title': courseName,
        'issuer_name': instructorName,
        'issuer_type': issuerType,
        'company_id': companyId,
        'company_name': companyName,
        'final_quiz_score': score,
        'issued_at': now.toIso8601String(),
        'status': 'issued',
      }).select().single();

      return CertificateData(
        id: response['id'] as String,
        verifyCode: response['verification_token'] as String,
        holderName: holderName,
        courseName: courseName,
        instructorName: instructorName,
        issuerName: instructorName,
        issueDate: now,
        score: score,
        courseHours: courseHours,
        serialNumber: response['serial_number'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  /// Verify a certificate by code
  Future<CertificateData?> verifyCertificate(String verifyCode) async {
    try {
      final response = await _client
          .from('certificates')
          .select()
          .eq('verification_token', verifyCode)
          .eq('status', 'issued')
          .maybeSingle();

      if (response == null) return null;

      return CertificateData(
        id: response['id'] as String,
        verifyCode: response['verification_token'] as String,
        holderName: response['recipient_name'] as String,
        courseName: response['course_title'] as String,
        instructorName: response['issuer_name'] as String,
        issuerName: response['issuer_name'] as String,
        issueDate: DateTime.parse(response['issued_at'] as String),
        score: (response['final_quiz_score'] as num?)?.toDouble(),
        serialNumber: response['serial_number'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  /// Revoke a certificate
  Future<bool> revokeCertificate(String certificateId, {String? reason, required String revokedBy}) async {
    try {
      await _client.from('certificates').update({
        'status': 'revoked',
        'revoked_at': DateTime.now().toIso8601String(),
        'revoked_by': revokedBy,
        'revocation_reason': reason,
      }).eq('id', certificateId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's certificates
  Future<List<CertificateData>> getUserCertificates(String userId) async {
    try {
      final response = await _client
          .from('certificates')
          .select()
          .eq('user_id', userId)
          .eq('status', 'issued')
          .order('issued_at', ascending: false);

      return (response as List).map((json) {
        return CertificateData(
          id: json['id'] as String,
          verifyCode: json['verification_token'] as String,
          holderName: json['recipient_name'] as String,
          courseName: json['course_title'] as String,
          instructorName: json['issuer_name'] as String,
          issuerName: json['issuer_name'] as String,
          issueDate: DateTime.parse(json['issued_at'] as String),
          score: (json['final_quiz_score'] as num?)?.toDouble(),
          serialNumber: json['serial_number'] as String?,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Print or share certificate
  Future<void> printCertificate(CertificateData certificate) async {
    final pdfBytes = await generatePdf(certificate);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Certificate-${certificate.verifyCode}',
    );
  }

  /// Share certificate as PDF
  Future<void> shareCertificate(CertificateData certificate) async {
    final pdfBytes = await generatePdf(certificate);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Certificate-${certificate.verifyCode}.pdf',
    );
  }
}
